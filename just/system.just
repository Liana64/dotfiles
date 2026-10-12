# Local failed systemd units
[group('system')]
health:
    systemctl --failed
    systemctl --user --failed

# auditd: status | search <key> | ack | rotate
[group('system')]
auditd cmd='status' key='':
    @austatus {{ if cmd == "status" { "" } else if cmd == "search" { key } else { cmd } }}

# Verify nix store integrity
[group('system')]
store-verify:
    sudo systemctl start nix-store-verify
    @cat /var/lib/audit-wall/alerts/store-verify 2>/dev/null || echo "store clean"

# Install, update, and prune flatpaks
[group('system')]
update-flatpaks:
    #!/usr/bin/env sh
    journalctl -fn0 -o cat -u flatpak-repo & trap 'kill $!' EXIT
    sudo systemctl start flatpak-repo

# hardening-probe <preset> [--sweep] -- <cmd>
[group('system')]
probe +args:
    hardening-probe {{ args }}

# List NixOS generations
[group('system')]
generations:
    nixos-rebuild list-generations

# Collect garbage
[confirm("delete old generations + collect garbage?")]
[group('system')]
gc:
    nix-collect-garbage -d
