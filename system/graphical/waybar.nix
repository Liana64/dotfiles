{ config, pkgs, ... }: {
  programs.waybar.enable = true;
   
  programs.waybar.settings = {
    mainBar = {
      layer = "top";
      position = "top";
      height = 26;
      output = [
        "eDP-1"
      ];

      modules-left = [ "custom/logo" "sway/workspaces" "sway/mode" ];
      modules-center = [ "clock" ];
      modules-right = [ "pulseaudio" "network" "battery" "tray" ];
      
      "custom/logo" = {
        format = "";
        tooltip = false;
        on-click = ''bemenu-run --accept-single  -n -p "Launch" --hp 4 --hf "#ffffff" --sf "#ffffff" --tf "#ffffff" '';
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
        format = "{:%a %b %d  %H:%M}";
        tooltip-format = "{:%Y-%m-%d}";
      };

      battery = {
        format = "{icon}  {capacity}%";
        format-icons = [ "" "" "" "" "" ];
        tooltip = false;
      };

      network = {
        format-wifi = "  {signalStrength}%";
        format-ethernet = "";
        format-disconnected = "⚠";
        tooltip-format = "{essid} ({ipaddr})";
      };
      
      pulseaudio = {
        format = "{icon}  {volume}%";
        format-muted = "";
        format-icons.default = [ "" "" "" ];
        on-click = "pavucontrol";
      };

      tray = {
        spacing = 8;
      };
    };
  };

  programs.waybar.style = ''
  
  * {
    border: none;
    border-radius: 0;
    padding: 0;
    margin: 0;
    font-size: 11px;
  }

  window#waybar {
    background: #292828;
    color: #ffffff;
  }
  
  #custom-logo {
    font-size: 18px;
    margin: 0;
    margin-left: 7px;
    margin-right: 12px;
    padding: 0;
    font-family: "JetBrainsMono Nerd Font", "NotoSans Nerd Font Mono";
  }
  
  #workspaces button {
    margin-right: 10px;
    color: #ffffff;
  }
  #workspaces button:hover, #workspaces button:active {
    background-color: #292828;
    color: #ffffff;
  }
  #workspaces button.focused {
    background-color: #383737;
  }

  #battery {
    margin-left: 7px;
    margin-right: 3px;
  }
  #network, #pulseaudio {
    margin-right: 7px;
  }

  #tray {
    margin-right: 7px;
  }
  '';
}
