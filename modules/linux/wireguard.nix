{config, pkgs, ...}:
let
  dnsEndpoint = "172.17.0.1";
  wireguardConfigFile = "/var/secrets/wireguard/wg0.conf";
  trustedNetworksFile = "/var/secrets/wireguard/trusted-networks";
in
{
  # After spending a lot of time troubleshooting issues with wireguard that only seemed
  # to affect my linux clients, it turns out that you need to reload the wireguard server
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
  # "SomeSSID,SomeBSSID"

  networking.networkmanager.dispatcherScripts = [
    {
      source = pkgs.writeScript "wg-autoconnect" ''
        #!${pkgs.bash}/bin/bash
        
        INTERFACE="$1"
        ACTION="$2"
        WG_INTERFACE="wg0"
        LOGFILE="/tmp/wg-autoconnect.log"
        
        [[ "$CONNECTIVITY_STATE" != "FULL" ]] && exit 0

        is_up() {
          ip link show "$WG_INTERFACE" &>/dev/null
        }
        
        is_trusted() {
          local current_ssid=$(${pkgs.networkmanager}/bin/nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
          
          #echo "  Current: SSID='$current_ssid'" >> "$LOGFILE"

          [[ ! -f "${trustedNetworksFile}" ]] && return 1

          local trusted_ssids=$(cat "${trustedNetworksFile}" | grep -v '^#' | tr '\n' ',' | sed 's/,$//')

          IFS=',' read -r ssids <<< "$trusted_ssids"
          for ssid in "''${ssids[@]}"; do
            ssid=$(echo "$ssid" | xargs)
            [[ "$current_ssid" == "$ssid" ]] && return 0
          done
          
          return 1
        }
        
        case "$ACTION" in
          connectivity-change)
            if is_trusted; then
              #echo "  Trusted network - disconnecting VPN" >> "$LOGFILE"
              if is_up; then
                ${pkgs.wireguard-tools}/bin/wg-quick down "${wireguardConfigFile}"
              fi
            else
              #echo "  Untrusted network - connecting VPN" >> "$LOGFILE"
              if ! is_up; then
                ${pkgs.wireguard-tools}/bin/wg-quick up "${wireguardConfigFile}"
              fi
            fi
            ;;
        esac
      '';
      type = "basic";
    }
  ];

  networking.networkmanager.unmanaged = [ "interface-name:wg0" ];
}
