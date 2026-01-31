{ lib, config, pkgs, ... }: {
  wayland.windowManager.sway = {
    enable = true;
    config = null;
    #extraConfigEarly = ''
    #  include ~/.config/sway/config
    #'';
    extraConfig = builtins.readFile ./sway/config;
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
    MOZ_ENABLE_WAYLAND = "1"; # Firefox on Wayland
    QT_QPA_PLATFORM = "wayland"; # Qt apps on Wayland
    SDL_VIDEODRIVER = "wayland"; # SDL games on Wayland
    XDG_CURRENT_DESKTOP = "sway"; # Helps some apps recognize Sway
  };

  xdg.configFile."sway/config" = lib.mkForce {
    source = ./sway/config;
  };
  
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
