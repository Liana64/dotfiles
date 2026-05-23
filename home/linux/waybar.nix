{ config, pkgs, colors, ... }:
let
  app = pkgs.symlinkJoin {
    name = "waybar-scripts";
    paths = with pkgs; [
      (writeShellScriptBin "waybar-usbguard" (builtins.readFile ../../modules/linux/bin/waybar-usbguard))
      (writeShellScriptBin "waybar-yubikey" (builtins.readFile ../../modules/linux/bin/waybar-yubikey))
      (writeShellScriptBin "waybar-vpn" (builtins.readFile ../../modules/linux/bin/waybar-vpn))
      usbguard
    ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/waybar-usbguard      --prefix PATH : $out/bin
      wrapProgram $out/bin/waybar-yubikey       --prefix PATH : $out/bin
    '';
  };
in
{
  programs.waybar = with colors; {
    enable = true;
    systemd = {
      enable = true;
      target = "sway-session.target";
    };

    style = ''
      @define-color surface mix(${darker}, ${indigo}, 0.5);
      @define-color alert   mix(${color0}, ${red}, 0.5);

      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 12px;
        min-height: 0;
      }

      window#waybar {
        background: ${darker};
        color: ${foreground};
      }

      tooltip {
        background: ${darker};
        border: 1px solid ${color0};
        border-radius: 8px;
      }

      tooltip label {
        color: ${foreground};
      }

      menu,
      menuitem {
        font-family: "Cantarell";
        font-size: 12px;
      }

      #clock,
      #network,
      #battery,
      #bluetooth,
      #pulseaudio,
      #tray,
      #custom-launcher,
      #custom-vpn,
      #custom-usbguard,
      #custom-yubikey,
      #custom-syncthing {
        color: ${white};
        margin: 3px 2px;
        padding: 2px 8px;
        border-radius: 8px;
        transition: background-color 0.15s ease, color 0.15s ease;
      }

      #custom-launcher {
        color: ${white};
        font-size: 14px;
        margin-left: 5px;
      }

      #custom-launcher:hover {
        background: @surface;
        color: ${white};
      }

      #clock {
        font-family: "Cantarell";
        font-size: 13px;
        background: @surface;
        padding: 2px 12px;
      }

      #tray {
        background: @surface;
        margin-right: 5px;
      }

      #workspaces {
        margin: 3px 4px;
      }

      #workspaces button {
        color: ${comment};
        min-width: 16px;
        padding: 1px 8px;
        margin: 0 1px;
        border: none;
        border-radius: 6px;
        box-shadow: none;
      }

      #workspaces button:not(.empty) {
        color: ${white};
      }

      #workspaces button:hover,
      #network:hover,
      #battery:hover,
      #bluetooth:hover,
      #pulseaudio:hover,
      #custom-vpn:hover,
      #custom-usbguard:hover,
      #custom-yubikey:hover,
      #custom-syncthing:hover {
        background: @surface;
        color: ${white};
      }

      #workspaces button.focused {
        background: ${indigo};
        color: ${white};
      }

      #workspaces button.urgent {
        background: @alert;
        color: ${white};
      }

      #network.ethernet,
      #bluetooth.on {
        background: ${tan};
        color: ${darker};
      }

      #network.disconnected,
      #custom-syncthing.disconnected,
      #custom-vpn.untrusted,
      #battery.critical {
        background: @alert;
      }

      #battery.warning,
      #custom-usbguard.blocked {
        background: ${orange};
      }

      #battery.charging,
      #custom-vpn.connected,
      #bluetooth.connected {
        background: ${green};
      }
    '';

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 14;
        output = [ "*" ];

        modules-left = [ "custom/launcher" "sway/workspaces" "sway/mode" ];
        modules-center = [ "clock" ];
        modules-right = [ "custom/yubikey" "custom/usbguard" "custom/syncthing" "custom/vpn" "network" "battery" "bluetooth" "pulseaudio" "tray" ];
        
        "custom/launcher" = {
          format = " ";
          tooltip = false;
          on-click = "${pkgs.vicinae}/bin/vicinae toggle";
        };

        # Credit: KyleOndy
        "custom/usbguard" = {
          format = " {text}";
          exec = "${app}/bin/waybar-usbguard";
          return-type = "json";
          on-click = "${app}/bin/waybar-usbguard allow";
          on-click-right = "${app}/bin/waybar-usbguard reject";
        };

        "custom/yubikey" = {
          exec = "${app}/bin/waybar-yubikey";
          return-type = "json";
        };

        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          sort-by-number = true;
          format = "{name}";
          persistent_workspaces = {
            "1:q" = [];
            "2:w" = [];
            "3:e" = [];
            "4:a" = [];
            "5:s" = [];
            "6:d" = [];
            "7:z" = [];
            "8:x" = [];
            "9:c" = [];
          };
          disable-click = false;
        };

        "sway/mode" = {
          tooltip = false;
        };
        
        clock = {
          format = "{:%a %b %e %I:%M %p}";
          tooltip-format = "{:%Y-%m-%d | %H:%M}";
          on-click = "flatpak run org.mozilla.Thunderbird -calendar";
        };

        battery = {
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-icons = [ "" "" "" "" "" ];
          format-plugged = " ";
          states = {
            critical = 15;
            warning = 35;
          };
          tooltip = true;
          tooltip-format = "{capacity}% — {time}";
          tooltip-format-charging = "{capacity}% — {time} until full";
        };

        "custom/vpn" = {
          exec = "${app}/bin/waybar-vpn";
          return-type = "json";
          interval = 3;
          on-click = "systemctl start vpn-toggle.service";
        };

        "custom/syncthing" = {
          exec = ''
            if pgrep -x syncthing >/dev/null; then
              echo '{"text": "󰓦", "class": "connected"}'
            else
              echo '{"text": "󰓦", "class": "disconnected"}'
            fi
          '';
          return-type = "json";
          interval = 5;
          on-click = "firefox-esr \"https://127.0.0.1:8384/\"";
        };

        network = {
          interval = 2;
          format-wifi = "  {essid}";
          format-ethernet = "󰈀 {ifname}";
          format-linked = "󰌗 {ifname}";
          format-disconnected = " ";
          tooltip-format = "{essid} {ifname}\n{ipaddr}/{cidr}\nvia {gwaddr}\n  {bandwidthDownBits}    {bandwidthUpBits}";
          tooltip-format-ethernet = "{ifname}\n{ipaddr}/{cidr}\nvia {gwaddr}\n  {bandwidthDownBits}    {bandwidthUpBits}";
          on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
        };
        
        bluetooth = {
          format = "󰂯";
          format-disabled = "󰂲";
          format-connected = "󰂱 {num_connections}";
          tooltip-format = "{controller_alias}\t{controller_address}";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          on-click = "${pkgs.blueman}/bin/blueman-manager";
          on-click-right = "${pkgs.util-linux}/bin/rfkill toggle bluetooth";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = " {volume}%";
          format-source = "";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" "" ];
          };
          on-click = "pavucontrol";
        };

        tray = {
          icon-size = 13;
          spacing = 10;
        };
      };
    };
  };
}
