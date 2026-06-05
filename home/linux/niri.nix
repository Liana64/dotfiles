{ config, lib, pkgs, colors, osConfig, ... }:
let
  compositor = osConfig.compositor or "sway";

  app = pkgs.symlinkJoin {
    name = "niri-scripts";
    paths = with pkgs; [
      (writeShellScriptBin "sway-screenshot-all" (builtins.readFile ../../modules/linux/bin/sway-screenshot-all))
      (writeShellScriptBin "sway-screenshot-area" (builtins.readFile ../../modules/linux/bin/sway-screenshot-area))
      (writeShellScriptBin "nix-rebuild-sway" (builtins.readFile ../../modules/linux/bin/nix-rebuild-sway))
    ];
  };

  ws = [ "q" "w" "e" "a" "s" "d" "z" "x" "c" ];
  mod = "Alt";
  sup = "Super";

  # Named-workspace declarations mirroring the sway layout.
  workspaces = lib.genAttrs ws (_: { });

  # Alt+<letter> focuses, Alt+Shift+<letter> moves the window there.
  wsBinds = lib.foldl' (acc: w: acc // {
    "${mod}+${w}".action.focus-workspace = w;
    "${mod}+Shift+${w}".action.move-window-to-workspace = w;
  }) { } ws;
in
{
  config = lib.mkIf (compositor == "niri") {
    programs.niri.settings = {
      environment.NIXOS_OZONE_WL = "1";

      animations.enable = false;

      # Ask clients to omit their own titlebars/decorations.
      prefer-no-csd = true;

      # Border only on the focused window; inactive windows get none.
      # (overrides the stylix niri target, which enables an always-on border)
      layout = {
        border.enable = false;
        focus-ring = {
          enable = true;
          active.color = colors.indigo;
        };
        # New windows open mid-size so they never cover existing ones; niri keeps
        # column widths fixed, so this is one default, not count-driven.
        # Alt+r cycles width; Alt+Shift+f maximizes a lone window.
        default-column-width.proportion = 0.5;
        preset-column-widths = [
          { proportion = 0.5; }
          { proportion = 0.667; }
          { proportion = 1.0; }
        ];
      };

      input = {
        keyboard.xkb.layout = "us";
        keyboard.repeat-delay = 200;
        keyboard.repeat-rate = 40;
        touchpad = {
          tap = true;
          natural-scroll = false;
          tap-button-map = "left-right-middle";
          middle-emulation = true;
          accel-profile = "adaptive";
          scroll-factor = 0.7;
        };
        mouse = {
          natural-scroll = false;
          accel-profile = "flat";
        };
      };

      outputs."eDP-1" = {
        mode = { width = 2880; height = 1920; refresh = 120.0; };
        scale = 1.8;
        position = { x = 0; y = 0; };
      };
      outputs."DP-5" = {
        mode = { width = 3440; height = 1440; refresh = 144.0; };
        position = { x = 0; y = 0; };
      };

      inherit workspaces;

      window-rules = [
        { matches = [ { app-id = "^kitty$"; } ]; open-on-workspace = "q"; }
        { matches = [ { app-id = "firefox"; } ]; open-on-workspace = "w"; }
        { matches = [ { app-id = "[Tt]hunderbird"; } ]; open-on-workspace = "e"; }
        {
          matches = [
            { app-id = "[Ee]lement"; }
            { app-id = "[Ss]ignal"; }
            { app-id = "vesktop"; }
          ];
          open-on-workspace = "s";
        }
        { matches = [ { app-id = "obsidian"; } ]; open-on-workspace = "d"; }
        { matches = [ { app-id = "[Cc]ider"; } ]; open-on-workspace = "z"; }
        { matches = [ { app-id = "[Tt]hunar"; } ]; open-on-workspace = "x"; }
        { matches = [ { app-id = "[Tt]odoist"; } ]; open-on-workspace = "c"; }
      ];

      spawn-at-startup = [
        { argv = [ "kitty" "--session" "startup.session" ]; }
        # niri turns monitors back on with input, so no resume command is needed.
        { sh = "swayidle -w timeout 300 'swaylock -f' timeout 600 'niri msg action power-off-monitors' before-sleep 'swaylock -f'"; }
        # Workaround for waybar duplicating bars across session restarts.
        { sh = "systemctl --user reset-failed waybar.service"; }
      ];

      binds = wsBinds // {
        "${mod}+Return".action.spawn = "kitty";
        "${sup}+Return".action.spawn = "kitty";
        "${mod}+Shift+Return".action.spawn = [ "kitty" "--session" "startup.session" ];

        "${mod}+Space".action.spawn = [ "vicinae" "toggle" ];
        "${sup}+Space".action.spawn = [ "vicinae" "toggle" ];
        "${sup}+d".action.spawn = [ "vicinae" "toggle" ];

        "${mod}+Ctrl+Shift+r".action.spawn = [ "kitty" "--title" "nix-rebuild" "${app}/bin/nix-rebuild-sway" ];

        "${mod}+Left".action.focus-column-left = [ ];
        "${mod}+Right".action.focus-column-right = [ ];
        "${mod}+Up".action.focus-window-up = [ ];
        "${mod}+Down".action.focus-window-down = [ ];
        "${mod}+h".action.focus-column-left = [ ];
        "${mod}+l".action.focus-column-right = [ ];
        "${mod}+k".action.focus-window-up = [ ];
        "${mod}+j".action.focus-window-down = [ ];

        "${mod}+Shift+Left".action.move-column-left = [ ];
        "${mod}+Shift+Right".action.move-column-right = [ ];
        "${mod}+Shift+Up".action.move-window-up = [ ];
        "${mod}+Shift+Down".action.move-window-down = [ ];
        "${mod}+Shift+h".action.move-column-left = [ ];
        "${mod}+Shift+l".action.move-column-right = [ ];
        "${mod}+Shift+k".action.move-window-up = [ ];
        "${mod}+Shift+j".action.move-window-down = [ ];

        "${mod}+Tab".action.focus-column-right-or-first = [ ];
        "${mod}+Shift+Tab".action.focus-column-left-or-last = [ ];

        "${mod}+f".action.fullscreen-window = [ ];
        "${mod}+minus".action.set-column-width = "-10%";
        "${mod}+plus".action.set-column-width = "+10%";
        "${mod}+r".action.switch-preset-column-width = [ ];
        "${mod}+Shift+f".action.maximize-column = [ ];
        "${mod}+t".action.toggle-column-tabbed-display = [ ];
        "${mod}+Shift+Space".action.toggle-window-floating = [ ];
        "${mod}+y".action.switch-focus-between-floating-and-tiling = [ ];

        # App launchers; placement is handled by window-rules above.
        "${mod}+Ctrl+Shift+w".action.spawn = "firefox-esr";
        "${mod}+Ctrl+Shift+e".action.spawn = [ "flatpak" "run" "org.mozilla.Thunderbird" ];
        "${mod}+Ctrl+Shift+a".action.spawn = [ "firefox-esr" "https://claude.ai" ];
        "${mod}+Ctrl+Shift+s".action.spawn = [ "flatpak" "run" "org.signal.Signal" ];
        "${mod}+Ctrl+Shift+d".action.spawn = [ "flatpak" "run" "md.obsidian.Obsidian" ];
        "${mod}+Ctrl+Shift+x".action.spawn = "thunar";
        "${mod}+Ctrl+Return".action.spawn = "thunar";
        "${mod}+Ctrl+Shift+c".action.spawn = [ "flatpak" "run" "com.todoist.Todoist" ];

        "Print".action.spawn = "${app}/bin/sway-screenshot-area";
        "Shift+Print".action.spawn = "${app}/bin/sway-screenshot-all";
        "${sup}+Shift+1".action.spawn = "${app}/bin/sway-screenshot-all";
        "${sup}+Shift+2".action.spawn = "${app}/bin/sway-screenshot-area";
        "${sup}+Shift+3".action.spawn = [ "sh" "-c" "grim - | wl-copy" ];
        "${sup}+Shift+4".action.spawn = [ "sh" "-c" "grim -g \"$(slurp)\" - | wl-copy" ];

        "XF86MonBrightnessUp".action.spawn = [ "brightnessctl" "set" "5%+" ];
        "XF86MonBrightnessDown".action.spawn = [ "brightnessctl" "set" "5%-" ];

        "XF86AudioPlay".action.spawn = [ "playerctl" "play-pause" ];
        "XF86AudioPause".action.spawn = [ "playerctl" "play-pause" ];
        "XF86AudioPrev".action.spawn = [ "playerctl" "previous" ];
        "XF86AudioNext".action.spawn = [ "playerctl" "next" ];
        "XF86AudioStop".action.spawn = [ "playerctl" "stop" ];

        "XF86AudioRaiseVolume".action.spawn = [ "pactl" "set-sink-volume" "@DEFAULT_SINK@" "+5%" ];
        "XF86AudioLowerVolume".action.spawn = [ "pactl" "set-sink-volume" "@DEFAULT_SINK@" "-5%" ];
        "XF86AudioMute".action.spawn = [ "pactl" "set-sink-mute" "@DEFAULT_SINK@" "toggle" ];

        "${sup}+Escape".action.spawn = [ "swaylock" "-f" ];
        "${sup}+Shift+q".action.close-window = [ ];
        "${sup}+Shift+e".action.quit = [ ];

        # niri's default binds are replaced when `binds` is set; restore the help overlay.
        "${sup}+Shift+Slash".action.show-hotkey-overlay = [ ];
      };
    };
  };
}
