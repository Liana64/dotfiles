{ config, pkgs, colors, ... }:
let
  app = pkgs.symlinkJoin {
    name = "sway-scripts";
    paths = with pkgs; [
      (writeShellScriptBin "sway-screenshot-all" (builtins.readFile ../../modules/linux/bin/sway-screenshot-all))
      (writeShellScriptBin "sway-screenshot-area" (builtins.readFile ../../modules/linux/bin/sway-screenshot-area))
      (writeShellScriptBin "nix-rebuild-sway" (builtins.readFile ../../modules/linux/bin/nix-rebuild-sway))
      usbguard
    ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/sway-screenshot-all      --prefix PATH : $out/bin
      wrapProgram $out/bin/sway-screenshot-area     --prefix PATH : $out/bin
      wrapProgram $out/bin/nix-rebuild-sway         --prefix PATH : $out/bin
    '';
  };
in
{
  programs.swaylock = with colors; {
    enable = true;
    settings = {
      daemonize = true;
      image = "${wallpaper}";
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
      set $inactive-bg-color   ${background}
      set $text-color          ${white}
      set $inactive-text-color ${white}
      set $urgent-bg-color     ${red}

      # Window Colors
      #                       border              background         text                 indicator

      client.focused          $bg-color           $bg-color          $text-color          $bg-color 
      client.unfocused        $inactive-bg-color  $inactive-bg-color $inactive-text-color $inactive-bg-color
      client.focused_inactive $inactive-bg-color  $inactive-bg-color $inactive-text-color $inactive-bg-color
      client.urgent           $urgent-bg-color    $urgent-bg-color   $text-color          $urgent-bg-color
      
      # Settings
      font pango:JetBrainsMono Nerd Font 10
      titlebar_padding 3
      title_align center
      default_border normal 2
      default_floating_border normal 2
      seat * xcursor_theme Bibata-Modern-Classic 16
      
      # Disable laptop display when using a dock
      bindswitch --reload --locked lid:on output eDP-1 disable
      bindswitch --reload --locked lid:off output eDP-1 enable

      exec_always --no-startup-id autotiling-rs

      exec swayidle -w \
        timeout 300 'swaylock -f' \
        timeout 600 'swaymsg "output * power off"' \
        resume 'swaymsg "output * power on"' \
        before-sleep 'swaylock -f -c 000000'

      exec dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP
      exec gnome-keyring-daemon --start --components=secrets,ssh,pkcs11

      for_window [app_id="firefox"] inhibit_idle fullscreen
      for_window [app_id="obsidian"] inhibit_idle fullscreen
      for_window [app_id="vlc"] inhibit_idle fullscreen
    '';
    config = {
      terminal = "kitty";
      menu = "rofi -show drun";
      #menu = "vicinae toggle";
      startup = [
        { command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"; }
      ];
      window.commands = [
        { criteria = { title = "nix-rebuild"; }; command = "floating enable, resize set 800 400"; }
      ];
      modifier = "Mod1";

      keybindings =
        let
          cfg = config.wayland.windowManager.sway.config;
          mod = cfg.modifier;
          sup = "Mod4";
        in
        {

          "${sup}+Escape" = ''mode "(p)oweroff, (s)uspend, (h)ibernate, (r)eboot, (l)ogout"'';

          "print" = "exec '${app}/bin/sway-screenshot-area'";
          "Shift+print" = "exec '${app}/bin/sway-screenshot-all'";

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
          "${mod}+Control+Shift+w" = "exec 'firefox'";
          "${mod}+Shift+e" = "move container to workspace e";
          "${mod}+Shift+a" = "move container to workspace a";
          "${mod}+Control+Shift+a" = "exec 'firefox \"https://claude.ai\"'";
          "${mod}+Shift+s" = "move container to workspace s";
          "${mod}+Control+Shift+s" = "exec 'element-desktop'";
          "${mod}+Shift+d" = "move container to workspace d";
          "${mod}+Control+Shift+d" = "exec 'obsidian'";
          "${mod}+Shift+z" = "move container to workspace z";
          "${mod}+Shift+x" = "move container to workspace x";
          "${mod}+Shift+c" = "move container to workspace c";

          "${sup}+Shift+q" = "kill";
          "${sup}+Shift+e" =
            "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";
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
        };
        "DP-5" = {
          resolution = "3440x1440@144Hz";
          position = "0,0";
        };
      };

      bars = [
        {
          position = "top";
          command = "waybar";
          fonts.names = ["JetBrainsMono Nerd Font"];
        }
      ];

      modes = {
        "(p)oweroff, (s)uspend, (h)ibernate, (r)eboot, (l)ogout" = {
          p = "exec swaymsg 'mode default' && systemctl poweroff";
          s = "exec swaymsg 'mode default' && systemctl suspend-then-hibernate";
          h = "exec swaymsg 'mode default' && systemctl hibernate";
          r = "exec swaymsg 'mode default' && systemctl reboot";
          l = "exec swaymsg 'mode default' && systemctl --user stop sway-session.target && systemctl --user stop graphical-session.target && swaymsg exit";
          Return = "mode default";
          Escape = "mode default";
        };
      };
      focus.followMouse = false;
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };

  home.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    XDG_DATA_DIRS = "$HOME/.nix-profile/share:${config.home.profileDirectory}/share:$XDG_DATA_DIRS";
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
}
