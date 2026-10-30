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
    startAt = "daily";
    wants = ["network-online.target"];
    after = ["network-online.target"];
    path = [config.boot.zfs.package pkgs.openssh];
    script = ''
      set -o pipefail
      snap=$(zfs list -Ho name -t snapshot -s createtxg ${ds} | tail -n1)
      from=$(zfs list -Ho name -t bookmark -s createtxg ${ds} | tail -n1)
      [ "''${from#*#}" = "''${snap#*@}" ] && exit 0
      zfs send ''${from:+-i "$from"} "$snap" \
        | ssh -i ${key} -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=/var/lib/unifi-backup/known_hosts backup@${m1}
      zfs bookmark "$snap" "${ds}#''${snap#*@}"
      [ -z "$from" ] || zfs destroy "$from"
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
}
