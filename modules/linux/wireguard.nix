{config, pkgs, ...}:
let
  dnsEndpoint = "172.17.0.1";
  wireguardConfigFile = "/var/secrets/wireguard/wg0.conf";
  trustedNetworksFile = "/var/secrets/wireguard/trusted-networks";
in
{
  # After spending a lot of time troubleshooting issues with wireguard that only seemed
  # to affect the linux clients, it turns out that you need to reload the wireguard server
  # service whenever you add a new peer. I hope that this comment helps someone, somewhere,
  # so that you don't have to go through what I did to figure this out. It hurt.

  networking.wg-quick.interfaces.wg0 = {
    configFile = wireguardConfigFile;
    listenPort = 51824;
    autostart = false;
  };

  # Connect to our VPN whenever we are on a network that isn't trusted. This isn't
  # entirely foolproof because someone could still spoof an SSID and BSSID, but it's
  # good enough for *me*
  #
  # Format for trustedNetworksFile:
  # SSID

  networking.networkmanager.dispatcherScripts = [
    {
      source = pkgs.writeScript "wg-autoconnect" ''
        #!${pkgs.bash}/bin/bash
        # systemd ships `resolvconf` as a symlink to resolvectl; wg-quick's
        # wrapper only appends openresolv to PATH, so without this prepend
        # wg-quick calls resolvectl, hits dbus-org.freedesktop.resolve1, and
        # rolls the tunnel back.
        export PATH=${pkgs.openresolv}/bin:$PATH

        INTERFACE="$1"
        ACTION="$2"
        NM_STATUS=$(${pkgs.networkmanager}/bin/nmcli -t -f type,state,connection dev)

        WG_INTERFACE="wg0"
        
        is_up() {
          ${pkgs.iproute2}/bin/ip link show "$WG_INTERFACE" &>/dev/null
        }

        is_ethernet() {
          echo "$NM_STATUS" | grep -q '^ethernet:connected'
        }

        is_trusted() {
          local current_ssid=$(${pkgs.networkmanager}/bin/nmcli -t -f active,ssid dev wifi | grep '^yes:' | cut -d: -f2-)
          [[ -z "$current_ssid" ]] && return 1
          [[ ! -f "${trustedNetworksFile}" ]] && return 1
          while IFS= read -r ssid; do
            [[ "$ssid" =~ ^#.*$ || -z "$ssid" ]] && continue
            ssid=$(echo "$ssid" | ${pkgs.findutils}/bin/xargs)
            [[ "$current_ssid" == "$ssid" ]] && return 0
          done < "${trustedNetworksFile}"
          return 1
        }
        
        case "$ACTION" in
          up) ;;
          connectivity-change)
            [[ "$CONNECTIVITY_STATE" = "FULL" ]] || exit 0
            ;;
          *) exit 0 ;;
        esac

        if is_ethernet || is_trusted; then
          is_up && ${pkgs.wireguard-tools}/bin/wg-quick down "${wireguardConfigFile}"
        else
          is_up || ${pkgs.wireguard-tools}/bin/wg-quick up "${wireguardConfigFile}"
        fi
      '';
      type = "basic";
    }
  ];

  networking.networkmanager.unmanaged = [ "interface-name:wg0" ];

  # Keep openresolv from invoking systemd-resolved (not enabled on this host);
  # otherwise wg-quick's `resolvconf -a wg0` rolls the tunnel back when the
  # resolvectl/systemd-resolved subscribers try to dbus-activate resolved.
  #networking.resolvconf.extraConfig = ''
  #  resolvectl=NO
  #  systemd_resolved=NO
  #'';
}
