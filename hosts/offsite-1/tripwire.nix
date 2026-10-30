{
  config,
  hardening,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (inputs.self.network) offsite;
  addr = offsite.hosts.${config.networking.hostName};
  topic = config.networking.hostName;
  list = name: xs: pkgs.writeText name (lib.concatLines xs);
  users = list "users" (lib.attrNames config.users.users);
  peers = list "peers" (map (p: p.PublicKey) config.systemd.network.netdevs."20-wg0".wireguardPeers);
  alt = xs: "(${lib.concatMapStringsSep "|" lib.escapeRegex xs})";
  login = "^Accepted [a-z-]+ for ${alt config.services.openssh.settings.AllowUsers} from ${alt [offsite.hosts.framework]} ";
in {
  systemd.services.tripwire = {
    after = ["ntfy-sh.service"];
    path = with pkgs; [curl gawk wireguard-tools];
    script = ''
      alerts=$(
        cut -d: -f1 /etc/passwd | grep -vxF -f ${users} | sed 's/^/unknown user: /'
        awk -F: '$3 == 0 && $1 != "root" { print "uid 0: " $1 }' /etc/passwd
        wg show wg0 peers | grep -vxF -f ${peers} | sed 's/^/unknown wg peer: /'
        journalctl -b -q -u sshd -o cat -g '^Accepted ' --cursor-file="$RUNTIME_DIRECTORY/cursor" | grep -vE '${login}' || true
      )
      last=$RUNTIME_DIRECTORY/last
      [ -n "$alerts" ] && [ "$alerts" != "$(cat "$last" 2>/dev/null)" ] || exit 0
      curl -fsS -H "Title: ${topic}" -H "Priority: urgent" -d "$alerts" http://${addr}:2586/${topic}
      printf '%s' "$alerts" > "$last"
    '';
    serviceConfig =
      hardening.confined
      // {
        Type = "oneshot";
        CapabilityBoundingSet = "CAP_NET_ADMIN";
        SupplementaryGroups = ["systemd-journal"];
        RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_NETLINK"];
        IPAddressDeny = "any";
        IPAddressAllow = addr;
        RuntimeDirectory = "tripwire";
        RuntimeDirectoryPreserve = true;
      };
  };
  systemd.timers.tripwire = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "5min";
    };
  };
}
