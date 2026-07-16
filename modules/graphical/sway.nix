# @desc: Sway WM + session env vars
{...}: {
  flake.modules.homeManager.sway = {
    config,
    lib,
    pkgs,
    osConfig,
    ...
  }: let
    useSway = (osConfig.compositor or "sway") == "sway";
    taskManager = osConfig.taskManager or "taskwarrior";
    taskApp =
      if taskManager == "todoist"
      then "flatpak run com.todoist.Todoist"
      else "kitty --title task taskwarrior-tui";
    app = pkgs.symlinkJoin {
      name = "sway-scripts";
      paths = with pkgs; [
        (writeShellScriptBin "sway-screenshot-all" (builtins.readFile ../../modules/bin/sway-screenshot-all))
        (writeShellScriptBin "sway-screenshot-area" (builtins.readFile ../../modules/bin/sway-screenshot-area))
        (writeShellScriptBin "nix-rebuild-sway" (builtins.readFile ../../modules/bin/nix-rebuild-sway))
        (writeShellScriptBin "caffeinate-toggle" (builtins.readFile ../../modules/bin/caffeinate-toggle))
        usbguard
      ];
      buildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/sway-screenshot-all      --prefix PATH : $out/bin
        wrapProgram $out/bin/sway-screenshot-area     --prefix PATH : $out/bin
        wrapProgram $out/bin/nix-rebuild-sway         --prefix PATH : $out/bin
      '';
    };
    # Cogwheel "task" mode actions. waybar custom/task listens on signal 9.
    taskDisplayToggle = pkgs.writeShellScript "task-display-toggle" ''
      f="$XDG_RUNTIME_DIR/waybar-task-hidden"
      if [ -e "$f" ]; then rm -f "$f"; else : > "$f"; fi
      ${pkgs.procps}/bin/pkill -RTMIN+9 waybar
    '';
    taskStartStop = pkgs.writeShellScript "task-start-stop" ''
      task=${pkgs.taskwarrior3}/bin/task
      if [ -n "$($task rc.context=none +ACTIVE _ids 2>/dev/null)" ]; then
        $task rc.context=none +ACTIVE stop
      else
        id=$($task rc.context=none status:pending -ACTIVE export 2>/dev/null \
          | ${pkgs.jq}/bin/jq -r 'sort_by(-.urgency) | first | .id // empty')
        [ -n "$id" ] && $task rc.context=none "$id" start
      fi
      ${pkgs.procps}/bin/pkill -RTMIN+9 waybar
    '';
    # Floating quick-add: prompt for a description, file it via the active context.
    taskAdd = pkgs.writeShellScript "task-add" ''
      task=${pkgs.taskwarrior3}/bin/task
      printf 'Add task: '
      IFS= read -r desc
      [ -n "$desc" ] && $task add "$desc" && sleep 0.6
    '';
    # Floating fzf picker over all pending tasks; mark the selection done.
    taskDone = pkgs.writeShellScript "task-done" ''
      task=${pkgs.taskwarrior3}/bin/task
      sel=$($task rc.context=none status:pending export 2>/dev/null \
        | ${pkgs.jq}/bin/jq -r '.[] | "\(.id)\t\(.description)"' \
        | ${pkgs.fzf}/bin/fzf --delimiter '\t' --with-nth 2.. --prompt 'done> ') || exit 0
      id=$(printf '%s' "$sel" | ${pkgs.coreutils}/bin/cut -f1)
      [ -n "$id" ] && $task rc.context=none "$id" done && sleep 0.6
    '';
  in {
    programs.swaylock = {
      enable = true;
      settings = {
        daemonize = true;
        indicator-caps-lock = true;
        indicator-radius = 80;
      };
    };

    systemd.user.targets.graphical.Unit.Wants = ["xdg-desktop-autostart.target"];
    wayland.windowManager.sway = {
      enable = useSway;
      systemd = {
        enable = true;
        # Import PATH and XDG_DATA_DIRS so launched apps resolve binaries and desktop entries.
        variables = [
          "DISPLAY"
          "WAYLAND_DISPLAY"
          "SWAYSOCK"
          "XDG_CURRENT_DESKTOP"
          "XDG_SESSION_TYPE"
          "NIXOS_OZONE_WL"
          "XCURSOR_THEME"
          "XCURSOR_SIZE"
          "PATH"
          "XDG_DATA_DIRS"
        ];
      };
      xwayland = false;
      package = pkgs.sway;
      wrapperFeatures.gtk = true;

      extraConfig = ''
        # Inhibit idle if any window is fullscreen
        for_window [app_id=".*"] inhibit_idle fullscreen

        assign [app_id="kitty-startup"] workspace 1:q
        assign [app_id="Thunderbird"] workspace 3:e
        assign [class="Todoist"] workspace 4:a
        assign [app_id="Element"] workspace 5:s
        assign [app_id="signal"] workspace 5:s
        assign [app_id="vesktop"] workspace 5:s
        assign [class="obsidian"] workspace 6:d
        assign [class="Cider"] workspace 7:z

        # Settings
        font pango:JetBrainsMono Nerd Font 10
        #titlebar_padding 3
        #title_align center

        # Draw titlebars
        #default_border normal 2
        #default_floating_border normal 2

        seat * xcursor_theme Bibata-Modern-Classic 16

        # Disable laptop display when using a dock
        bindswitch --reload --locked lid:on output eDP-1 disable
        bindswitch --reload --locked lid:off output eDP-1 enable

        exec_always --no-startup-id autotiling-rs

        exec gnome-keyring-daemon --start --components=secrets,pkcs11
      '';
      config = {
        terminal = "kitty";
        menu = "vicinae toggle";
        startup = [
          {command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";}
          {command = "kitty --class kitty-startup";}
        ];
        window.commands = [
          {
            criteria = {title = "nix-rebuild";};
            command = "floating enable, resize set 800 400";
          }
          {
            criteria = {title = "task-add";};
            command = "floating enable, resize set 600 120, move position center";
          }
          {
            criteria = {title = "task-done";};
            command = "floating enable, resize set 720 500, move position center";
          }
          {
            criteria = {
              app_id = "firefox";
              title = "^(Save|Open|Enter name of|Select).*";
            };
            command = "floating enable, resize set 900 650, move position center";
          }
        ];
        modifier = "Mod1";

        gaps = {
          inner = 4;
          outer = 4;
          #smartGaps = true;
          smartBorders = "on";
        };
        window.titlebar = false;
        window.border = 2;
        floating.border = 2;
        floating.titlebar = false;

        keybindings = let
          cfg = config.wayland.windowManager.sway.config;
          mod = cfg.modifier;
          sup = "Mod4";
        in {
          "${sup}+Escape" = ''mode "power: (p) poweroff · (s) suspend · (h) hibernate · (r) reboot · (g) logout · (l) lock · (c) caffeinate"'';

          "XF86AudioMedia" = ''mode "task: (a) add · (s) start/stop · (h) hide/show · (t) TUI · (d) done · (g) goal · (c) choose"'';

          "print" = "exec '${app}/bin/sway-screenshot-area'";
          "Shift+print" = "exec '${app}/bin/sway-screenshot-all'";

          "${sup}+Shift+1" = "exec '${app}/bin/sway-screenshot-all'";
          "${sup}+Shift+2" = "exec '${app}/bin/sway-screenshot-area'";

          "${sup}+Shift+3" = "exec 'grim - | wl-copy'";
          "${sup}+Shift+4" = "exec 'grim -g \"$(slurp)\" - | wl-copy'";

          "XF86MonBrightnessUp" = "exec 'brightnessctl set 5%+'";
          "XF86MonBrightnessDown" = "exec 'brightnessctl set 5%-'";

          "XF86AudioPlay" = "exec playerctl play-pause";
          "XF86AudioPause" = "exec playerctl play-pause";
          "XF86AudioPrev" = "exec playerctl previous";
          "XF86AudioNext" = "exec playerctl next";
          "XF86AudioStop" = "exec playerctl stop";

          "XF86AudioRaiseVolume" = "exec 'pactl set-sink-volume \\@DEFAULT_SINK@ +5%'";
          "XF86AudioLowerVolume" = "exec 'pactl set-sink-volume \\@DEFAULT_SINK@ -5%'";
          "XF86AudioMute" = "exec 'pactl set-sink-mute \\@DEFAULT_SINK@ toggle'";

          #"${sup}+c" = "exec wtype -P XF56Copy";
          #"${sup}+v" = "exec wtype -P XF56Paste";
          #"${sup}+x" = "exec wtype -P XF56Cut";

          "${mod}+Return" = "exec ${cfg.terminal}";
          "${sup}+Return" = "exec ${cfg.terminal}";
          "${mod}+Shift+Return" = "exec ${cfg.terminal} --session startup.session";

          "${mod}+Shift+r" = "reload";
          "${mod}+Control+Shift+r" = "exec 'kitty --title nix-rebuild ${app}/bin/nix-rebuild-sway'";
          "${sup}+d" = "exec ${cfg.menu}";

          "${mod}+Space" = "exec ${cfg.menu}";
          "${sup}+Space" = "exec ${cfg.menu}";

          "${mod}+Left" = "focus left";
          "${mod}+Down" = "focus down";
          "${mod}+Up" = "focus up";
          "${mod}+Right" = "focus right";

          "${mod}+Shift+Left" = "move left";
          "${mod}+Shift+Down" = "move down";
          "${mod}+Shift+Up" = "move up";
          "${mod}+Shift+Right" = "move right";

          "${mod}+h" = "focus left";
          "${mod}+j" = "focus down";
          "${mod}+k" = "focus up";
          "${mod}+l" = "focus right";

          "${mod}+Tab" = "focus next";
          "${mod}+Shift+Tab" = "focus prev";

          "${mod}+Shift+h" = "move left";
          "${mod}+Shift+j" = "move down";
          "${mod}+Shift+k" = "move up";
          "${mod}+Shift+l" = "move right";

          "${mod}+Shift+m" = "move scratchpad";
          "${mod}+m" = "scratchpad show";

          "${mod}+Shift+b" = "splith";
          "${mod}+Shift+v" = "splitv";
          "${mod}+f" = "fullscreen";
          "${mod}+p" = "focus parent";

          "${mod}+minus" = "resize shrink width 50px";
          "${mod}+plus" = "resize grow width 50px";

          "${mod}+underscore" = "resize shrink height 50px";
          "${mod}+equal" = "resize grow height 50px";

          # "${mod}+g" = "layout stacking";
          # "${mod}+t" = "layout tabbed";

          "${mod}+b" = "layout toggle split";

          "${mod}+Shift+Space" = "floating toggle";
          "${mod}+y" = "focus mode_toggle";

          "${mod}+q" = "workspace 1:q";
          "${mod}+w" = "workspace 2:w";
          "${mod}+e" = "workspace 3:e";
          "${mod}+a" = "workspace 4:a";
          "${mod}+s" = "workspace 5:s";
          "${mod}+d" = "workspace 6:d";
          "${mod}+z" = "workspace 7:z";
          "${mod}+x" = "workspace 8:x";
          "${mod}+c" = "workspace 9:c";

          "${mod}+Shift+q" = "move container to workspace 1:q";
          "${mod}+Shift+w" = "move container to workspace 2:w";
          "${mod}+Control+Shift+w" = "exec 'firefox'";
          "${mod}+Shift+e" = "move container to workspace 3:e";
          "${mod}+Control+Shift+e" = "workspace 3:e; exec flatpak run org.mozilla.Thunderbird";
          "${mod}+Shift+a" = "move container to workspace 4:a";
          "${mod}+Ctrl+Shift+a" = "exec '${taskApp}'";
          "${mod}+Shift+s" = "move container to workspace 5:s";
          "${mod}+Control+Shift+s" = "workspace 5:s; exec flatpak run org.signal.Signal";
          "${mod}+Shift+d" = "move container to workspace 6:d";
          "${mod}+Control+Shift+d" = "workspace 6:d; exec flatpak run md.obsidian.Obsidian";
          "${mod}+Shift+z" = "move container to workspace 7:z";
          "${mod}+Shift+x" = "move container to workspace 8:x";
          "${mod}+Shift+c" = "move container to workspace 9:c";
          "${mod}+Control+Shift+x" = "workspace 8:x; exec thunar";
          "${mod}+Control+Return" = "exec thunar";
          "${mod}+Control+Shift+c" = "workspace 4:a; exec flatpak run com.todoist.Todoist";
          "${mod}+Control+Shift+z" = "exec zoom-web";

          "${sup}+Shift+q" = "kill";
          "${sup}+Shift+e" = "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";
        };

        input = {
          "type:touchpad" = {
            tap = "enabled";
            tap_button_map = "lrm";
            middle_emulation = "enabled";
            natural_scroll = "disabled";
            drag_lock = "disabled";
            scroll_factor = "0.7";
            accel_profile = "adaptive";
            pointer_accel = "0.15";
          };

          "type:pointer" = {
            accel_profile = "flat";
            pointer_accel = "-0.15";
          };

          "*" = {
            xkb_layout = "us";
            repeat_delay = "200";
            repeat_rate = "40";
          };
        };

        output = {
          "eDP-1" = {
            resolution = "2880x1920@120Hz";
            position = "0,0";
            #scale = "1.9";
            scale = "1.8";
          };
          "DP-5" = {
            resolution = "3440x1440@144Hz";
            position = "0,0";
          };
        };

        bars = [];

        modes = {
          "power: (p) poweroff · (s) suspend · (h) hibernate · (r) reboot · (g) logout · (l) lock · (c) caffeinate" = {
            p = "exec swaymsg 'mode default' && systemctl poweroff";
            s = "exec swaymsg 'mode default' && systemctl suspend";
            h = "exec swaymsg 'mode default' && systemctl hibernate";
            r = "exec swaymsg 'mode default' && systemctl reboot";
            g = "exec swaymsg 'mode default' && systemctl --user stop sway-session.target && systemctl --user stop graphical-session.target && swaymsg exit";
            l = "exec swaymsg 'mode default' && swaylock -f";
            c = "exec swaymsg 'mode default' && ${app}/bin/caffeinate-toggle";
            Return = "mode default";
            Escape = "mode default";
          };

          "task: (a) add · (s) start/stop · (h) hide/show · (t) TUI · (d) done · (g) goal · (c) choose" = {
            a = "exec swaymsg 'mode default' && kitty --title task-add ${taskAdd}";
            s = "exec swaymsg 'mode default' && ${taskStartStop}";
            h = "exec swaymsg 'mode default' && ${taskDisplayToggle}";
            t = "exec swaymsg 'mode default' && kitty --title task taskwarrior-tui";
            d = "exec swaymsg 'mode default' && kitty --title task-done ${taskDone}";
            # TODO(unwired): (g) toggle the active-goal waybar display.
            g = "mode default";
            # TODO(unwired): (c) choose/pin the active goal via a picker.
            c = "mode default";
            Return = "mode default";
            Escape = "mode default";
          };
        };
        focus.followMouse = false;
        focus.newWindow = "focus";
      };
    };

    xdg.configFile."autostart/blueman.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Hidden=true
    '';

    home.sessionVariables =
      lib.optionalAttrs useSway {
        DESKTOP_SESSION = "sway";
        XDG_CURRENT_DESKTOP = "sway";
      }
      // {
        XDG_SESSION_TYPE = "wayland";
        XDG_DATA_DIRS = "$HOME/.nix-profile/share:${config.home.profileDirectory}/share:$XDG_DATA_DIRS";

        # Force native Wayland for Electron/Chromium apps (no XWayland fallback)
        ELECTRON_OZONE_PLATFORM_HINT = "wayland";
        OZONE_PLATFORM = "wayland";
        NIXOS_OZONE_WL = "1";

        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        QT_SCALE_FACTOR = 1;
        QT_AUTO_SCREEN_SCALE_FACTOR = "0";
        QT_QPA_PLATFORM = "wayland";
        SDL_VIDEODRIVER = "wayland";
        GDK_SCALE = "1";
        GDK_DPI_SCALE = "1";
        MOZ_ENABLE_WAYLAND = "1";
        _JAVA_AWT_WM_NONREPARENTING = "1";
      };
  };
}
