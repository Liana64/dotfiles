{ config, pkgs, colors, ... }:
let
  app = pkgs.symlinkJoin {
    name = "waybar-scripts";
    paths = with pkgs; [
      (writeShellScriptBin "waybar-usbguard" (builtins.readFile ../../modules/linux/bin/waybar-usbguard))
      (writeShellScriptBin "waybar-yubikey" (builtins.readFile ../../modules/linux/bin/waybar-yubikey))
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
      enable = false;
      target = "sway-session.target";
    };

    style = ''
      * {
        font-size: 12px;
        min-height: 0;
      }

      window#waybar {
        background: ${darker};
        color: ${foreground};
      }

      #workspaces {
        font-family: "JetBrainsMono Nerd Font";
        background-color: ${darker};
        margin: 0;
      }

      #workspaces button {
        background-color: transparent;
        color: ${white};
        transition: all 0.1s ease;
      }

      #workspaces button.focused {
        color: ${color1};
      }

      #workspaces button.persistent {
        color: ${foreground};
      }

      #custom-launcher {
        background-color: ${darker};
        color: ${white};
        margin : 4px 4.5px;
        padding : 2px 4px;
      }

      #clock, #network, #battery, #pulseaudio, #tray, #custom-vpn, #custom-usbguard, #custom-yubikey, #custom-kdeconnect, #custom-syncthing {
        color: ${white};
        background-color: ${darker};
        margin: 4px 2px 4px 4.5px;
        padding: 2px 6px;
      }

      #network.ethernet {
        color: ${darker};
        background-color: ${tan};
        margin: 4px 2px 4px 4.5px;
        padding: 2px 6px;
      }

      #network.disconnected, #custom-syncthing.disconnected, #battery.critical {
        color: ${white};
        background-color: ${red};
        margin: 4px 2px 4px 4.5px;
        padding: 2px 6px;
      }

      #battery.warning, #usbguard.blocked {
        color: ${white};
        background-color: ${orange};
        margin: 4px 2px 4px 4.5px;
        padding: 2px 6px;
      }

      #battery.charging {
        color: ${white};
        background-color: ${green};
        margin: 4px 2px 4px 4.5px;
        padding: 2px 6px;
      }
    '';

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 14;
        output = [
          "eDP-1"
          "DP-5"
        ];

        modules-left = [ "custom/launcher" "sway/workspaces" "sway/mode" ];
        modules-center = [ "clock" ];
        modules-right = [ "custom/yubikey" "custom/usbguard" "custom/syncthing" "custom/kdeconnect" "custom/vpn" "network" "battery" "pulseaudio" "tray" ];
        
        "custom/launcher" = {
          format = " ";
        };

        "custom/power" = {
          format = " ";
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
          persistent_workspaces = {
            "q" = []; 
            "w" = [];
            "e" = [];
            "a" = [];
            "s" = [];
            "d" = [];
            "z" = [];
            "x" = [];
            "c" = [];
          };
          disable-click = true;
        };

        "sway/mode" = {
          tooltip = false;
        };
        
        clock = {
          format = "{:%a %b %e %I:%M %p}";
          tooltip-format = "{:%Y-%m-%d | %H:%M}";
          #on-click = "open some calendar";
        };

        battery = {
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-icons = [ "󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          format-plugged = "󰚦 ";
          states = {
            critical = 15;
            warning = 35;
          };
          tooltip = true;
          tooltip-format = "{capacity}%";
        };

        "custom/vpn" = {
          exec = ''
            if [ -e /proc/sys/net/ipv4/conf/wg0 ]; then
              echo '{"text": " ", "class": "connected"}'
            else
              echo '{"text": " ", "class": "disconnected"}'
            fi
          '';
          return-type = "json";
          interval = 5;
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
          on-click = "firefox \"https://127.0.0.1:8384/\"";
        };

        "custom/kdeconnect" = {
          exec = ''
            if kdeconnect-cli --list-available --id-only 2>/dev/null | grep -q .; then
              echo '{"text": "󰄜", "class": "connected"}'
            else
              echo '{"text": "󰥐", "class": "disconnected"}'
            fi
          '';
          return-type = "json";
          interval = 5;
        };

        network = {
          interval = 2;
          format-wifi = "     {essid}";
          format-ethernet = "󰈀    {ifname}";
          format-linked = "󰌗   {ifname}";
          format-disconnected = " ";
          tooltip-format = "{essid} {ifname}";
        };
        
        pulseaudio = { 
          format = "󱄠  {volume}%";
          format-bluetooth = "{icon} {volume}% {format_source}";
          format-bluetooth-muted = "{icon} {format_source}";
          format-muted = "󰸈";
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
