{ config, lib, pkgs, colors, inputs, ... }: {
  systemd.user.targets.graphical.Unit.Wants = [ "xdg-desktop-autostart.target" ];
  wayland.windowManager.sway = with colors; {
    enable = true;
    checkConfig = false;
    systemd.enable = true;
    xwayland = true;
    package = pkgs.swayfx;
    wrapperFeatures.gtk = true;
    extraConfig = ''
      ## SWAYFX CONFIG
      corner_radius 4
      shadows on
      shadow_offset 0 0
      shadow_blur_radius 8
      shadow_color #000000BB
      shadow_inactive_color #000000B0

      default_dim_inactive 0.2

      set $bg-color 	       ${mbg}
      set $inactive-bg-color   ${darker}
      set $text-color          ${foreground}
      set $inactive-text-color ${foreground}
      set $urgent-bg-color     ${color9}

      # window colors
      #                       border              background         text                 indicator
      client.focused          $bg-color           $bg-color          $text-color          $bg-color 
      client.unfocused        $inactive-bg-color $inactive-bg-color $inactive-text-color  $inactive-bg-color
      client.focused_inactive $inactive-bg-color $inactive-bg-color $inactive-text-color  $inactive-bg-color
      client.urgent           $urgent-bg-color    $urgent-bg-color   $text-color          $urgent-bg-color
      
      # Settings
      font pango:Product Sans 12
      titlebar_separator enable
      titlebar_padding 6
      title_align center
      default_border normal 2
      default_floating_border normal 2
      seat * xcursor_theme Bibata-Modern-Classic 16
      
      #exec_always --no-startup-id autotiling-rs &
      exec --no-startup-id swayidle -w \
          timeout 360 'waylock' \
          timeout 600 'swaymsg "output * power off"' resume 'swaymsg "output * power on"' \
          before-sleep 'waylock'

      #exec "systemctl --user import-environment {,WAYLAND_}DISPLAY SWAYSOCK; systemctl --user start sway-session.target"
      #exec swaymsg -t subscribe '["shutdown"]' && systemctl --user stop sway-session.target
      #exec dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP
      exec gnome-keyring-daemon --start --components=secrets,ssh,pkcs11

    '';
    config = {
      terminal = "kitty";
      menu = "rofi -show drun";
      modifier = "Mod1";

      keycodebindings =
        let
          cfg = config.wayland.windowManager.sway.config;
          mod = cfg.modifier;
          left = "h";
          down = "j";
          up = "k";
          right = "l";
        in
        {
          #"${mod}+${left}" = "focus left";
          #"${mod}+${down}" = "focus down";
          #"${mod}+${up}" = "focus up";
          #"${mod}+${right}" = "focus right";

          #"${mod}+Shift+${left}" = "move left";
          #"${mod}+Shift+${down}" = "move down";
          #"${mod}+Shift+${up}" = "move up";
          #"${mod}+Shift+${right}" = "move right";
        };

      keybindings =
        let
          cfg = config.wayland.windowManager.sway.config;
          mod = cfg.modifier;
          sup = "Mod4";
        in
        {
          "print" = "exec 'grim -g \"$(slurp)\" - | wl-copy'";
          "Shift+print" = "exec 'grim - | wl-copy'";
          "${sup}+Shift+3" = "exec 'grim - | wl-copy'";
          "${sup}+Shift+4" = "exec 'grim -g \"$(slurp)\" - | wl-copy";

          "XF86MonBrightnessUp" = "exec 'brightnessctl s 5+'";
          "XF86MonBrightnessDown" = "exec 'brightnessctl s 5-'";

          "XF86AudioPlay" = "exec playerctl play-pause";
          "XF86AudioPause" = "exec playerctl play-pause";
          "XF86AudioPrev" = "exec playerctl previous";
          "XF86AudioNext" = "exec playerctl next";
          "XF86AudioStop" = "exec playerctl stop";

          "XF86AudioRaiseVolume" = "exec 'pamixer -u ; pamixer -i 5'";
          "XF86AudioLowerVolume" = "exec 'pamixer -u ; pamixer -d 5'";
          "XF86AudioMute" = "exec 'pamixer -t'";

          "${mod}+Return" = "exec ${cfg.terminal}";
          "${sup}+Return" = "exec ${cfg.terminal}";

          "${mod}+Shift+r" = "reload";
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

          "${mod}+Shift+b" = "splith";
          "${mod}+Shift+v" = "splitv";
          "${mod}+f" = "fullscreen";
          "${mod}+p" = "focus parent";

          "${mod}+g" = "layout stacking";
          "${mod}+t" = "layout tabbed";

          "${mod}+b" = "layout toggle split";

          "${mod}+Shift+y" = "floating toggle";
          "${mod}+y" = "focus mode_toggle";

          "${mod}+q" = "workspace q";
          "${mod}+w" = "workspace w";
          "${mod}+e" = "workspace e";
          "${mod}+a" = "workspace a";
          "${mod}+s" = "workspace s";
          "${mod}+d" = "workspace d";
          "${mod}+z" = "workspace z";
          "${mod}+x" = "workspace x";
          "${mod}+c" = "workspace c";

          "${mod}+Shift+q" = "move container to workspace q";
          "${mod}+Shift+w" = "move container to workspace w";
          "${mod}+Shift+e" = "move container to workspace e";
          "${mod}+Shift+a" = "move container to workspace a";
          "${mod}+Shift+s" = "move container to workspace s";
          "${mod}+Shift+d" = "move container to workspace d";
          "${mod}+Shift+z" = "move container to workspace z";
          "${mod}+Shift+x" = "move container to workspace x";
          "${mod}+Shift+c" = "move container to workspace c";

          "${sup}+Shift+q" = "kill";
          "${sup}+Shift+e" =
            "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";

          "${mod}+r" = "mode resize";
        };
      input = {
        "type:touchpad" = {
          tap = "enabled";
          tap_button_map = "lrm";
          middle_emulation = "enabled";
          natural_scroll = "disabled";
          drag_lock = "disabled";
        };
        "*" = {
          xkb_layout = "us";
        };
      };
      output = {
        "eDP-1" = {
          resolution = "2880x1920@120Hz";
          position = "0,0";
          scale = "1.85";
        };
        "DP-5" = {
          resolution = "5120x1440@144Hz";
          position = "0,0";
          scale = "2.0";
        };
      };

      gaps = {
        bottom = 5;
        horizontal = 5;
        vertical = 5;
        inner = 5;
        left = 5;
        outer = 5;
        right = 5;
        top = 5;
        smartBorders = "off";
        smartGaps = false;
      };
      bars = [
        {
          position = "top";
          command = "waybar";
          fonts.names = ["JetBrainsMono Nerd Font"];
        }
      ];
      focus.followMouse = false;
    };
  };

  #home.packages = with pkgs; [
  #  fuzzel
  #  bemenu
  #  swaylock
  #  swayidle
  #  swaybg
  #  grim
  #  slurp
  #  wl-clipboard
  #  brightnessctl
  #  playerctl
  #  mako
  #];
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_SCALE_FACTOR = 1;
    SDL_VIDEODRIVER = "wayland";
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_TYPE = "wayland";
    DESKTOP_SESSION = "sway";
  };

  #xdg.configFile."sway/config" = lib.mkForce {
  #  source = ./sway/config;
  #};
  
#  programs.i3status = {
#    enable = true;
#    general = {
#      colors = true;
#      interval = 5;
#    };
#    modules = {
#      "wireless _first_" = {
#        position = 1;
#        settings = {
#          format_up = "W: (%quality at %essid) %ip";
#          format_down = "W: down";
#        };
#      };
#      "ethernet _first_" = {
#        position = 2;
#        settings = {
#          format_up = "E: %ip (%speed)";
#          format_down = "E: down";
#        };
#      };
#      "battery all" = {
#        position = 3;
#        settings = {
#          format = "%status %percentage %remaining";
#        };
#      };
#      "disk /" = {
#        position = 4;
#        settings = {
#          format = "%avail";
#        };
#      };
#      "load" = {
#        position = 5;
#        settings = {
#          format = "%1min";
#        };
#      };
#      "memory" = {
#        position = 6;
#        settings = {
#          format = "%used / %available";
#          threshold_degraded = "1G";
#          format_degraded = "MEMORY < %available";
#        };
#      };
#      "tztime local" = {
#        position = 7;
#        settings = {
#          format = "%Y-%m-%d %H:%M:%S";
#        };
#      };
#    };
#  };
  #services.mako.enable = true;
}
