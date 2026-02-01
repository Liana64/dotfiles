{ config, pkgs, ... }:
{
  programs.i3status = {
    enable = true;
    general = {
      colors = true;
      color_good = "#ffffff";
      color_degraded = "#ffffff";
      color_bad = "#ffffff";
      interval = 5;
      separator = "  ";
    };
    modules = {
      "ethernet _first_" = {
        enable = false;
      };

      "ipv6" = {
        enable = false;
      };


      "memory" = {
        enable = false;
      };

      "load" = {
        enable = false;
      };

      "disk /" = {
        enable = false;
      };

      "path_exists VPN" = {
        position = 1;
        settings = {
          path = "/proc/sys/net/ipv4/conf/wg0";
          format = " ";
          format_down = " ";
        };
      };

      "wireless _first_" = {
        position = 2;
        settings = {
          format_up = "  %essid ";
          format_down = "󰤮  down";
        };
      };

      "cpu_temperature 0" = {
        position = 3;
        settings = {
          format = "%degrees󰔄 ";
          path = "/sys/class/hwmon/hwmon0/temp1_input";
        };
      };

      "volume master" = {
        position = 4;
        settings = {
          format = "󱄠 %volume ";
          format_muted = "󰸈 ";
          device = "default";
          mixer = "Master";
          mixer_idx = 0;
        };
      };

      "battery all" = {
        position = 5;
        settings = {
          format = "%status %percentage ";
          format_down = "";
          status_chr = "⚡";
          status_bat = "";
          status_unk = "";
          status_full = "";
          low_threshold = 10;
          last_full_capacity = true;
          integer_battery_capacity = true;
        };
      };

      "tztime local" = {
        position = 6;
        settings = {
          format = " 󰔠 %a %b %d %I:%M %p ";
        };
      };
    };
  };
}
