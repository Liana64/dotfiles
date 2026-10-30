{
  config,
  hardening,
  inputs,
  pkgs,
  ...
}: let
  m1 = inputs.self.network.mgmt.hosts.m1;
  ds = "rpool/var/unifi";
  key = config.sops.secrets."backup/ssh-key".path;
in {
  sops.secrets."backup/ssh-key" = {};

  systemd.services.unifi-backup = {
    startAt = "*-*-* 00:30";
    wants = ["network-online.target"];
    after = ["network-online.target"];
    path = [config.boot.zfs.package pkgs.gawk pkgs.openssh];
    script = ''
      set -o pipefail
      from=$(zfs list -Ho name -t bookmark -s createtxg ${ds} | tail -n1)
      txg=0
      [ -z "$from" ] || txg=$(zfs get -Hpo value createtxg "$from")
      zfs list -Hpo createtxg,name -t snapshot -s createtxg ${ds} \
        | awk -v t="$txg" '$1 > t && $2 ~ /_(daily|monthly)$/ {print $2}' \
        | while read -r snap; do
          zfs send ''${from:+-i "$from"} "$snap" \
            | ssh -i ${key} -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=/var/lib/unifi-backup/known_hosts backup@${m1}
          mark="${ds}#''${snap#*@}"
          zfs bookmark "$snap" "$mark"
          [ -z "$from" ] || zfs destroy "$from"
          from=$mark
        done
    '';
    serviceConfig =
      hardening.zfs
      // {
        Type = "oneshot";
        StateDirectory = "unifi-backup";
        CapabilityBoundingSet = "CAP_SYS_ADMIN";
        RestrictAddressFamilies = ["AF_UNIX" "AF_NETLINK" "AF_INET" "AF_INET6"];
        IPAddressAllow = m1;
      };
  };

  systemd.timers.unifi-backup.timerConfig.Persistent = true;
}
