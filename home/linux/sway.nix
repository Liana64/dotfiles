
{ config, lib, pkgs, colors, inputs, ... }:
let
  app = pkgs.symlinkJoin {
    name = "sway-scripts";
    paths = with pkgs; [
      (writeShellScriptBin "sway-screenshot-all" (builtins.readFile ../../modules/linux/bin/sway-screenshot-all))
      (writeShellScriptBin "sway-screenshot-area" (builtins.readFile ../../modules/linux/bin/sway-screenshot-area))
      usbguard
    ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/sway-screenshot-all      --prefix PATH : $out/bin
      wrapProgram $out/bin/sway-screenshot-area     --prefix PATH : $out/bin
    '';
  };
in
{
  programs.swaylock = {
    enable = true;
    settings = {
      daemonize = true;
      indicator-caps-lock = true;
      indicator-radius = 80;
    };
  };
  systemd.user.targets.graphical.Unit.Wants = [ "xdg-desktop-autostart.target" ];
  wayland.windowManager.sway = with colors; {
    enable = true;
    systemd.enable = true;
    xwayland = true;
    package = pkgs.sway;
    wrapperFeatures.gtk = true;
    extraConfig = ''
      # Colors
      set $bg-color 	       ${mbg}
      set $inactive-bg-color   ${darker}
      set $text-color          ${white}
      set $inactive-text-color ${white}
      set $urgent-bg-color     ${red}

      # Window Colors
      #                       border              background         text                 indicator

      client.focused          $bg-color           $bg-color          $text-color          $bg-color 
      client.unfocused        $inactive-bg-color $inactive-bg-color $inactive-text-color  $inactive-bg-color
      client.focused_inactive $inactive-bg-color $inactive-bg-color $inactive-text-color  $inactive-bg-color
      client.urgent           $urgent-bg-color    $urgent-bg-color   $text-color          $urgent-bg-color
      
      # Settings
      font pango:JetBrainsMono Nerd Font 11
      titlebar_padding 4
      title_align center
      default_border normal 2
      default_floating_border normal 2
      seat * xcursor_theme Bibata-Modern-Classic 16
      
      # Fix file explorers
      for_window [app_id="xdg-desktop-portal-gtk"] floating enable, resize set 900 600
      for_window [title="(?i)save|open|download"] floating enable, resize set 900 600

      #exec_always --no-startup-id autotiling-rs &

      exec swayidle -w \
        timeout 300 'swaylock -f -c 000000' \
        timeout 600 'swaymsg "output * power off"' \
        resume 'swaymsg "output * power on"' \
        before-sleep 'swaylock -f -c 000000'

      exec dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP
      exec gnome-keyring-daemon --start --components=secrets,ssh,pkcs11
    '';
    config = {
      terminal = "kitty";
      menu = "rofi -show drun";
      #menu = "vicinae toggle";
      modifier = "Mod1";

      keybindings =
        let
          cfg = config.wayland.windowManager.sway.config;
          mod = cfg.modifier;
          sup = "Mod4";
        in
        {
          "print" = "exec '${app}/bin/sway-screenshot-area'";
          "Shift+print" = "exec '${app}/bin/sway-screenshot-all'";

          "${sup}+Shift+3" = "exec 'grim - | wl-copy'";
          "${sup}+Shift+4" = "exec 'grim -g \"$(slurp)\" - | wl-copy";

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

          "${mod}+h"  = "focus left";
          "${mod}+j"  = "focus down";
          "${mod}+k"    = "focus up";
          "${mod}+l" = "focus right";

          "${sup}+Tab" = "focus next";
          "${sup}+Shift+Tab" = "focus prev";

          "${mod}+Shift+h"  = "move left";
          "${mod}+Shift+j"  = "move down";
          "${mod}+Shift+k"    = "move up";
          "${mod}+Shift+l" = "move right";

          "${mod}+Shift+m" = "move scratchpad";
          "${mod}+m" = "scratchpad show";

          "${mod}+Shift+b" = "splith";
          "${mod}+Shift+v" = "splitv";
          "${mod}+f" = "fullscreen";
          "${mod}+p" = "focus parent";

          "${mod}+g" = "layout stacking";
          "${mod}+t" = "layout tabbed";

          "${mod}+b" = "layout toggle split";

          "${mod}+Shift+Space" = "floating toggle";
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
          #scale = "1.85";
        };
        "DP-5" = {
          resolution = "3440x1440@144Hz";
          position = "0,0";
          #scale = "2.0";
        };
      };

      #gaps = {
      #  bottom = 2;
      #  horizontal = 2;
      #  vertical = 2;
      #  inner = 2;
      #  left = 2;
      #  outer = 2;
      #  right = 2;
      #  top = 2;
      #  smartBorders = "off";
      #  smartGaps = false;
      #};
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
    XDG_SESSION_TYPE = "wayland";
    DESKTOP_SESSION = "sway";
    XDG_CURRENT_DESKTOP = "sway";
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
