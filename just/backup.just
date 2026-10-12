# [{source, t, size}] → newest per source
table := '''
  def age: now - . | if . < 172800 then "\(. / 3600 | floor)h" else "\(. / 86400 | floor)d" end;
  def size: [., "B", "K", "M", "G", "T"] | until(.[0] < 1000 or length == 2; [.[0] / 1000] + .[2:]) | "\(.[0] * 10 | floor / 10)\(.[1])";
  map(select(.source | contains($f))) | group_by(.source) | map(max_by(.t) + {kept: length}) | .[]
  | [.source, (.t | strflocaltime("%F %H:%M")), (.t | age), (.size | size), .kept] | join("|")
'''
columns := "column -t -s '|' -N SOURCE,CREATED,AGE,SIZE,KEPT -R AGE,SIZE,KEPT"

# Latest restic-tank snapshot (m1)
[group('backup')]
restic:
    @ssh -t {{ m1 }} 'sudo -v && echo && sudo restic-tank snapshots --latest 1'

# Latest ZFS snapshot per dataset (m1)
[group('backup')]
sanoid filter='':
    #!/usr/bin/env sh
    set -e
    snaps=$(ssh {{ m1 }} zfs list -Hp -t snapshot -o name,creation,referenced -r tank)
    echo
    printf '%s\n' "$snaps" | jq -R 'split("\t") | {source: (.[0] | split("@")[0]), t: (.[1] | tonumber), size: (.[2] | tonumber)}' \
      | jq -rs --arg f {{ quote(filter) }} '{{ table }}' | {{ columns }}

# Latest kopia snapshot per volsync source (cluster)
[group('backup')]
volsync filter='':
    #!/usr/bin/env sh
    set -e
    echo
    {{ kube }} exec -n volsync-system deploy/kopia -c app -- kopia snapshot list --all --json \
      | jq 'map({source: "\(.source.host)/\(.source.userName)", t: (.startTime[:19] + "Z" | fromdate), size: .stats.totalSize})' \
      | jq -r --arg f {{ quote(filter) }} '{{ table }}' | {{ columns }}
