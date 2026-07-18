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
        (writeShellScriptBin "waybar-harness-status" (builtins.readFile ../../modules/bin/waybar-harness-status))
        (writeShellScriptBin "waybar-task" (builtins.readFile ../../modules/bin/waybar-task))
        (writeShellScriptBin "waybar-countdown" (builtins.readFile ../../modules/bin/waybar-countdown))
        (writeShellScriptBin "track-date" (builtins.readFile ../../modules/bin/track-date))
        (writeShellScriptBin "waybar-todoist" (builtins.readFile ../../modules/bin/waybar-todoist))
        (writeShellScriptBin "waybar-sysinfo" (builtins.readFile ../../modules/bin/waybar-sysinfo))
        (writeShellScriptBin "caffeinate-toggle" (builtins.readFile ../../modules/bin/caffeinate-toggle))
        usbguard
      ];
      buildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/waybar-usbguard      --prefix PATH : $out/bin
        wrapProgram $out/bin/waybar-yubikey       --prefix PATH : $out/bin
        wrapProgram $out/bin/waybar-task          --prefix PATH : ${pkgs.lib.makeBinPath (with pkgs; [taskwarrior3 jq coreutils])}
        wrapProgram $out/bin/waybar-harness-status --prefix PATH : ${pkgs.lib.makeBinPath (with pkgs; [jq coreutils gnused procps sway])}
        wrapProgram $out/bin/waybar-countdown     --prefix PATH : ${pkgs.lib.makeBinPath (with pkgs; [jq coreutils])}
        wrapProgram $out/bin/track-date           --prefix PATH : ${pkgs.lib.makeBinPath (with pkgs; [coreutils procps])}
        wrapProgram $out/bin/waybar-todoist       --prefix PATH : ${pkgs.lib.makeBinPath (with pkgs; [todoist jq coreutils gnused gawk])}
        wrapProgram $out/bin/waybar-sysinfo       --prefix PATH : ${pkgs.lib.makeBinPath (with pkgs; [coreutils gnused gawk procps jq])}
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
    # on-click children inherit the unit confinement, bwrap/GPU die there, spawn via the user manager
    launch = cmd: "systemd-run --user --quiet --collect -- ${cmd}";
  in {
    # ProtectHome=true would also mask /run/user: read-only keeps ~/.config and the
    # wayland socket reachable, %t stays writable for the caffeinate flag
    systemd.user.services.waybar.Service =
      hardening.confined
      // {
        ProtectHome = "read-only";
        # launcher sysinfo tooltip reads /proc stat+meminfo, the pid subset masks them
        ProcSubset = "all";
        # todoist sync cache
        ReadWritePaths = "%t %h/.cache/todoist";
      };

    programs.waybar = with colors; {
      enable = true;
      # pow_format fuses number and unit (2.5kb/s), patch in the SI space
      package = pkgs.waybar.overrideAttrs (old: {
        patches = (old.patches or []) ++ [../_lib/waybar-pow-space.patch];
      });
      systemd = {
        enable = true;
        targets = ["graphical-session.target"];
      };

      style = ''
        @define-color surface mix(${darker}, ${highlight}, 0.5);
        @define-color raised  mix(${darker}, ${white}, 0.08);
        @define-color alert   mix(${color0}, ${red}, 0.5);

        * {
          /* propo variant, patched icons get ink-hugging advances, specimen-measured |L-R| <= 1 */
          font-family: "JetBrainsMono Nerd Font Propo";
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

        #custom-clock,
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
        #custom-syncthing,
        #custom-task,
        #custom-countdown,
        #custom-harness-status {
          color: ${white};
          margin: 3px 2px;
          padding: 2px 8px;
          border-radius: 8px;
          transition: background-color 0.15s ease, color 0.15s ease;
        }

        #custom-launcher {
          font-size: 14px;
          margin-left: 5px;
        }

        #custom-clock {
          font-family: "Cantarell";
          font-size: 13px;
          background: @surface;
          padding: 2px 12px;
        }

        #custom-task {
          color: ${tan};
        }

        #custom-harness-status.running {
          color: ${comment};
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
          background: @raised;
          margin-right: 5px;
        }

        #status,
        #hw {
          background: @raised;
          border-radius: 8px;
          margin: 3px 6px;
          /* end slots, filled segments need the same air as inter-icon gaps */
          padding: 0 8px;
        }

        #status #custom-harness-status,
        #status #custom-yubikey,
        #status #custom-usbguard,
        #status #custom-syncthing,
        #status #custom-vpn,
        #status #custom-caffeine,
        #hw #network,
        #hw #battery,
        #hw #bluetooth,
        #hw #pulseaudio {
          margin: 3px 2px;
          padding: 0 6px;
          border-radius: 6px;
        }

        /* the container's rounded end pinches filled corners, clear it */
        #status #custom-vpn.connected,
        #status #custom-vpn.untrusted {
          margin-right: 5px;
        }

        /* the % right bearing is base-font metric, propo does not change it, right stays under left */
        #hw #battery {
          padding: 0 5.5px 0 8px;
        }

        #status #custom-harness-status:hover,
        #status #custom-yubikey:hover,
        #status #custom-usbguard:hover,
        #status #custom-syncthing:hover,
        #status #custom-vpn:hover,
        #status #custom-caffeine:hover,
        #hw #network:hover,
        #hw #battery:hover,
        #hw #bluetooth:hover,
        #hw #pulseaudio:hover {
          background: ${highlightDim};
        }

        #workspaces {
          background: @raised;
          border-radius: 8px;
          margin: 3px 4px;
          padding: 0 2px;
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
        #custom-syncthing:hover,
        #custom-launcher:hover {
          background: @surface;
          color: ${white};
        }

        #workspaces button:hover {
          background: ${highlightDim};
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

        #pulseaudio.muted,
        #bluetooth.off,
        #bluetooth.disabled {
          color: ${comment};
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

        #status #custom-caffeine.active {
          background: ${yellow};
          color: ${darker};
        }
      '';

      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          output = ["*"];

          modules-left = ["custom/launcher"] ++ wsModules;
          modules-center = ["custom/clock"];
          modules-right = ["custom/task" "custom/countdown" "group/status" "group/hw" "tray"];

          # groups stack vertically on a horizontal bar unless told otherwise
          "group/status" = {
            orientation = "horizontal";
            # filled segments read cramped against the rounded end, keep caffeine mid-cluster
            modules = ["custom/harness-status" "custom/yubikey" "custom/usbguard" "custom/syncthing" "custom/caffeine" "custom/vpn"];
          };

          "group/hw" = {
            orientation = "horizontal";
            modules = ["network" "battery" "bluetooth" "pulseaudio"];
          };

          "custom/launcher" = {
            # nixos logo U+F313 is BMP-PUA, edit tools strip it, patch via sed only
            format = " ";
            exec = "${app}/bin/waybar-sysinfo";
            interval = 30;
            return-type = "json";
            on-click = "${pkgs.vicinae}/bin/vicinae toggle";
          };

          # Credit: KyleOndy
          "custom/usbguard" = {
            format = "󰕓{text}";
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
            interval = 900;
            signal = 10;
            format = "{}";
          };

          "custom/caffeine" = {
            exec = "${app}/bin/waybar-caffeine";
            return-type = "json";
            interval = "once";
            signal = 8;
            on-click = "${app}/bin/caffeinate-toggle";
          };

          "custom/harness-status" = {
            exec = "${app}/bin/waybar-harness-status";
            return-type = "json";
            interval = 60;
            signal = 11;
            format = "{}";
            on-click = "${app}/bin/waybar-harness-status focus";
            on-click-right = "${app}/bin/waybar-harness-status clear";
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

          # native clock formatter cannot drop the %I zero-pad, shell date can
          "custom/clock" = {
            exec = "date +'{\"text\": \"%a %b %-d %-I:%M %p\", \"tooltip\": \"%Y-%m-%d | %H:%M\"}'";
            interval = 5;
            return-type = "json";
            on-click = launch "flatpak run org.mozilla.Thunderbird -calendar";
          };

          "custom/task" =
            if taskManager == "todoist"
            then {
              exec = "${app}/bin/waybar-todoist";
              interval = 30;
              signal = 9;
              return-type = "json";
              format = "{}";
              max-length = 50;
              on-click = launch "flatpak run com.todoist.Todoist";
            }
            else {
              exec = "${app}/bin/waybar-task";
              interval = 10;
              signal = 9;
              return-type = "json";
              format = "{}";
              max-length = 50;
              on-click = launch "kitty --title task taskwarrior-tui";
            };

          battery = {
            format = "{icon} {capacity}%";
            format-charging = "󰂄 {capacity}%";
            format-icons = ["󰁺" "󰁼" "󰁾" "󰂀" "󰁹"];
            format-plugged = "󰚥";
            states = {
              critical = 15;
              warning = 35;
            };
            tooltip = true;
            tooltip-format = "{capacity}% — {time} · {power}W";
            tooltip-format-charging = "{capacity}% — {time} until full · {power}W";
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
            on-click = launch "firefox https://127.0.0.1:8384/";
          };

          network = {
            interval = 2;
            format-wifi = "󰖩  {essid}";
            format-ethernet = "󰈀 {ifname}";
            format-linked = "󰌗 {ifname}";
            format-disconnected = "󰖪 ";
            tooltip-format = "ap  {essid} · {signalStrength}%\nif  {ifname} · {ipaddr}/{cidr}\ngw  {gwaddr}\n\n↓ {bandwidthDownBits}\n↑ {bandwidthUpBits}";
            tooltip-format-ethernet = "if  {ifname} · {ipaddr}/{cidr}\ngw  {gwaddr}\n\n↓ {bandwidthDownBits}\n↑ {bandwidthUpBits}";
            on-click = launch "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
          };

          bluetooth = {
            format = "󰂯";
            format-disabled = "󰂲";
            format-connected = "󰂱 {num_connections}";
            tooltip-format = "{controller_alias}\t{controller_address}";
            tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
            tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
            on-click = launch "${pkgs.blueman}/bin/blueman-manager";
            on-click-right = "${btToggle}";
          };

          pulseaudio = {
            format = "{icon} {volume}%";
            format-muted = "󰖁";
            format-source = "󰍬";
            format-source-muted = "󰍭";
            format-icons = {
              headphone = "󰋋";
              phone = "󰏲";
              portable = "󰄜";
              car = "󰄋";
              default = ["󰕿" "󰖀" "󰕾"];
            };
            on-click = launch "pavucontrol";
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
