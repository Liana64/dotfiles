{ config, pkgs, colors, ... }: {
  programs.waybar = with colors; {
    enable = true;
    systemd = {
      enable = false;
      target = "graphical-session.target";
    };

    style = ''
      window#waybar {
        background: ${darker};
        color: ${foreground};
      }

      #workspaces {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 16px;
        background-color: ${background};
        margin : 4px 0;
        border-radius : 5px;
      }

      #workspaces button {
        font-size: 16px;
        background-color: transparent;
        color: ${color7};
        transition: all 0.1s ease;
      }

      #workspaces button.focused {
        font-size: 16px;
        color: ${foreground};
      }

      #workspaces button.persistent {
        color: ${foreground};
        font-size: 12px;
      }

      #custom-launcher {
        background-color: ${background};
        color: ${color7};
        margin : 4px 4.5px;
        padding : 5px 8px;
        font-size: 16px;
        border-radius : 5px;
      }

      #custom-power {
        color : ${color7};
        background-color: ${background};
        margin : 4px 4.5px 4px 4.5px;
        padding : 5px 11px 5px 13px;
        border-radius : 5px;
      }

      #custom-vpn {
        color: ${color7};
        background-color: ${background};
        margin: 4px 2px 4px 4.5px;
        padding: 5px 8px;
        border-radius: 5px 0 0 5px;
      }
      #clock {
        background-color: ${background};
        color: ${color7};
        margin: 4px 9px;
        padding: 5px 8px;
        border-radius: 5px;
      }
      #network {
        color: ${color7};
        background-color: ${background};
        margin: 4px 2px;
        padding: 5px 8px;
      }
      #battery {
        color: ${color7};
        background-color: ${background};
        margin: 4px 2px;
        padding: 5px 8px;
      }
      #tray {
        color: ${color7};
        background-color: ${background};
        margin: 4px 4.5px 4px 0;
        padding: 5px 8px;
        border-radius: 0 5px 5px 0;
      }
    '';

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 26;
        output = [
          "eDP-1"
          "DP-5"
        ];

        modules-left = [ "custom/launcher" "sway/workspaces" "sway/mode" ];
        modules-center = [ "clock" ];
        modules-right = [ "custom/vpn" "network" "battery" "tray" ];
        
        "custom/launcher" = {
          #on-click = "eww open --toggle dash";
          format = " ";
        };

        "custom/power" = {
          #on-click = "powermenu &";
          format = " ";
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
          format = "{:%a %b %d %I:%M %p}";
          tooltip-format = "{:%Y-%m-%d | %H:%M}";
        };

        battery = {
          format = "{icon}";
          format-charging = "󰂄";
          format-icons = [ "󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          format-plugged = "󰚦 ";
          states = {
            critical = 15;
            warning = 30;
          };
          tooltip = false;
          #on-click = "upower -i /org/freedesktop/UPower/devices/battery_BAT1";
        };

        "custom/vpn" = {
          exec = "test -e /proc/sys/net/ipv4/conf/wg0 && echo ' ' || echo ' '";
          interval = 5;
        };

        network = {
          interval = 1;
          format-disconnected = "󰤮 ";
          format-wifi = " ";
          #on-click = "nmtui";
        };
        
        pulseaudio = { 
          format = "{icon}  {volume}%";
          format-muted = "";
          format-icons.default = [ "" "" "" ];
          on-click = "pavucontrol";
        };
        tray = {
          icon-size = 16;
          spacing = 10;
        };
      };
    };
  };
}
