# @desc: Waybar status bar
{...}: {
  flake.modules.homeManager.waybar = {
    pkgs,
    colors,
    osConfig,
    ...
  }: let
    hardening = import ../_lib/systemd-hardening.nix;
    useNiri = (osConfig.compositor or "sway") == "niri";
    taskManager = osConfig.taskManager or "taskwarrior";
    wsModules =
      if useNiri
      then ["niri/workspaces"]
      else ["sway/workspaces" "sway/mode"];
    app = pkgs.symlinkJoin {
      name = "waybar-scripts";
      paths = with pkgs; [
        (writeShellScriptBin "waybar-usbguard" (builtins.readFile ../../modules/bin/waybar-usbguard))
        (writeShellScriptBin "waybar-yubikey" (builtins.readFile ../../modules/bin/waybar-yubikey))
        (writeShellScriptBin "waybar-vpn" (builtins.readFile ../../modules/bin/waybar-vpn))
        (writeShellScriptBin "waybar-caffeine" (builtins.readFile ../../modules/bin/waybar-caffeine))
        (writeShellScriptBin "waybar-task" (builtins.readFile ../../modules/bin/waybar-task))
        (writeShellScriptBin "waybar-countdown" (builtins.readFile ../../modules/bin/waybar-countdown))
        (writeShellScriptBin "track-date" (builtins.readFile ../../modules/bin/track-date))
        (writeShellScriptBin "waybar-todoist" (builtins.readFile ../../modules/bin/waybar-todoist))
        (writeShellScriptBin "caffeinate-toggle" (builtins.readFile ../../modules/bin/caffeinate-toggle))
        usbguard
      ];
      buildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/waybar-usbguard      --prefix PATH : $out/bin
        wrapProgram $out/bin/waybar-yubikey       --prefix PATH : $out/bin
        wrapProgram $out/bin/waybar-task          --prefix PATH : ${pkgs.lib.makeBinPath (with pkgs; [taskwarrior3 jq coreutils])}
        wrapProgram $out/bin/waybar-countdown     --prefix PATH : ${pkgs.lib.makeBinPath (with pkgs; [jq coreutils])}
        wrapProgram $out/bin/track-date           --prefix PATH : ${pkgs.lib.makeBinPath (with pkgs; [coreutils])}
        wrapProgram $out/bin/waybar-todoist       --prefix PATH : ${pkgs.lib.makeBinPath (with pkgs; [todoist jq coreutils gnused gawk])}
      '';
    };
    # Toggle BT via BlueZ HCI power, never rfkill: rfkill power-gates the MT7925
    # BT-USB function and it fails to re-enumerate on unblock (descriptor read -110).
    btToggle = pkgs.writeShellScript "bt-toggle" ''
      if ${pkgs.bluez}/bin/bluetoothctl show | grep -q 'Powered: yes'; then
        ${pkgs.bluez}/bin/bluetoothctl power off
      else
        ${pkgs.bluez}/bin/bluetoothctl power on
      fi
    '';
  in {
    # ProtectHome=true would also mask /run/user: read-only keeps ~/.config and the
    # wayland socket reachable, %t stays writable for the caffeinate flag
    systemd.user.services.waybar.Service =
      hardening.confined
      // {
        ProtectHome = "read-only";
        # todoist sync cache, and the click-set countdown target
        ReadWritePaths = "%t %h/.cache/todoist -/var/secrets/date";
      };

    programs.waybar = with colors; {
      enable = true;
      systemd = {
        enable = true;
        targets = ["graphical-session.target"];
      };

      style = ''
        @define-color surface mix(${darker}, ${highlight}, 0.5);
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
        #custom-caffeine,
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

        #custom-task {
          color: ${tan};
          margin: 3px 2px;
          padding: 2px 8px;
        }

        #custom-countdown {
          color: ${white};
          margin: 3px 2px;
          padding: 2px 8px;
        }

        #custom-countdown.today {
          color: ${green};
        }

        #custom-countdown.past {
          color: ${comment};
        }

        #custom-task.active {
          color: ${background};
          background: ${highlight};
        }

        #custom-task.due-today {
          color: ${orange};
        }

        #custom-task.overdue {
          color: ${red};
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
          background: ${highlight};
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

        #custom-caffeine.active {
          background: ${yellow};
          color: ${darker};
          padding: 2px 10px 2px 6px;
        }
      '';

      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 14;
          output = ["*"];

          modules-left = ["custom/launcher"] ++ wsModules;
          modules-center = ["clock"];
          modules-right = ["custom/task" "custom/countdown" "custom/yubikey" "custom/usbguard" "custom/syncthing" "custom/vpn" "network" "custom/caffeine" "battery" "bluetooth" "pulseaudio" "tray"];

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

          "custom/countdown" = {
            exec = "${app}/bin/waybar-countdown";
            return-type = "json";
            interval = 3600;
            format = "{}";
          };

          "custom/caffeine" = {
            exec = "${app}/bin/waybar-caffeine";
            return-type = "json";
            interval = "once";
            signal = 8;
            on-click = "${app}/bin/caffeinate-toggle";
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

          "niri/workspaces" = {
            format = "{value}";
          };

          clock = {
            format = "{:%a %b %e %I:%M %p}";
            tooltip-format = "{:%Y-%m-%d | %H:%M}";
            on-click = "flatpak run org.mozilla.Thunderbird -calendar";
          };

          "custom/task" =
            if taskManager == "todoist"
            then {
              exec = "${app}/bin/waybar-todoist";
              interval = 30;
              signal = 9;
              return-type = "json";
              format = "{}";
              on-click = "flatpak run com.todoist.Todoist";
            }
            else {
              exec = "${app}/bin/waybar-task";
              interval = 10;
              signal = 9;
              return-type = "json";
              format = "{}";
              on-click = "kitty --title task taskwarrior-tui";
            };

          battery = {
            format = "{icon}  {capacity}%";
            format-charging = " {capacity}%";
            format-icons = ["" "" "" "" ""];
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
            on-click = "firefox \"https://127.0.0.1:8384/\"";
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
            on-click-right = "${btToggle}";
          };

          pulseaudio = {
            format = "{icon} {volume}%";
            format-muted = "";
            format-source = "";
            format-source-muted = "";
            format-icons = {
              headphone = "";
              phone = "";
              portable = "";
              car = "";
              default = ["" "" ""];
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
  };
}
