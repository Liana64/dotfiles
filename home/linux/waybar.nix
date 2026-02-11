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
      target = "graphical-session.target";
    };

    style = ''
      window#waybar {
        background: ${darker};
        color: ${foreground};
      }

      #workspaces {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 14px;
        background-color: ${darker};
        margin : 4px 0;
        border-radius : 4px;
      }

      #workspaces button {
        font-size: 14px;
        background-color: transparent;
        color: ${color7};
        transition: all 0.1s ease;
      }

      #workspaces button.focused {
        font-size: 14px;
        color: ${foreground};
      }

      #workspaces button.persistent {
        color: ${foreground};
        font-size: 12px;
      }

      #custom-launcher {
        background-color: ${darker};
        color: ${color7};
        margin : 4px 4.5px;
        padding : 5px 8px;
        font-size: 14px;
        border-radius : 4px;
      }

      #custom-power {
        color : ${color7};
        background-color: ${darker};
        margin : 4px 4.5px 4px 4.5px;
        padding : 5px 11px 5px 13px;
        border-radius : 4px;
      }

      #custom-vpn {
        color: ${color7};
        background-color: ${darker};
        margin: 4px 2px 4px 4.5px;
        padding: 5px 8px;
        border-radius: 4px 0 0 4px;
      }
      #clock {
        background-color: ${darker};
        color: ${color7};
        margin: 4px 9px;
        padding: 5px 8px;
        border-radius: 4px;
      }
      #network {
        color: ${color7};
        background-color: ${darker};
        margin: 4px 2px;
        padding: 5px 8px;
      }
      #battery {
        color: ${color7};
        background-color: ${darker};
        margin: 4px 2px;
        padding: 5px 8px;
      }
      #pulseaudio {
        color: ${color7};
        background-color: ${darker};
        margin: 4px 2px;
        padding: 5px 8px;
      }
      #tray {
        color: ${color7};
        background-color: ${darker};
        margin: 4px 4.5px 4px 0;
        padding: 5px 8px;
        border-radius: 0 4px 4px 0;
      }
    '';

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 18;
        output = [
          "eDP-1"
          "DP-5"
        ];

        modules-left = [ "custom/launcher" "sway/workspaces" "sway/mode" ];
        modules-center = [ "clock" ];
        modules-right = [ "custom/yubikey" "custom/usbguard" "custom/vpn" "network" "battery" "pulseaudio" "tray" ];
        
        "custom/launcher" = {
          format = " ";
        };

        "custom/power" = {
          format = " ";
        };

        "custom/usbguard" = {
          format-icons = {
            icon = " ";
          };
          format = "{icon}  {text}";
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
          tooltip = true;
          tooltip-format = "{capacity}%";
        };

        "custom/vpn" = {
          exec = "test -e /proc/sys/net/ipv4/conf/wg0 && echo ' ' || echo ' '";
          interval = 5;
        };

        network = {
          interval = 2;
          format-wifi = "     {essid}";
          format-ethernet = "🖧   {ifname}";
          format-linked = "🖧   {ifname}";
          format-disconnected = " ";
          tooltip-format = "{essid} {ifname}";
          #on-click = "nmtui";
        };
        
        pulseaudio = { 
          format = "󱄠  {volume}%";
          format-bluetooth = "{icon} {volume}% {format_source}";
          format-bluetooth-muted = "{icon} {format_source}";
          format-muted = "󰸈 ";
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
          icon-size = 16;
          spacing = 10;
        };
      };
    };
  };
}
