{ inputs, pkgs, lib, colors, osConfig, ... }: let
  # Single literal palette. Stored with `#` for IDE color preview.
  # base16Scheme below strips `#` because stylix wants raw hex.
  palette = {
    base00 = "#222222"; # background
    base01 = "#282828"; # light background
    base02 = "#3c3836"; # selection / gray
    base03 = "#928374"; # comments
    base04 = "#bdae93";
    base05 = "#fffefb"; # light foreground
    base06 = "#ddc7a1";
    base07 = "#ffffff"; # white
    base08 = "#ea6962"; # red
    base09 = "#e79a4e"; # orange
    base0A = "#d8a657"; # yellow
    base0B = "#a9b665"; # green / accent
    base0C = "#89b482"; # aqua
    base0D = "#5b6ee8"; # indigo (primary accent)
    base0E = "#d3869b"; # magenta
    base0F = "#7daea3"; # emerald
  };

  # Named aliases for readability in overrides below.
  background = palette.base00;
  mbg        = palette.base01;
  foreground = palette.base05;
  white      = palette.base07;
  red        = palette.base08;
  orange     = palette.base09;
  green      = palette.base0B;
  indigo     = palette.base0D;
in {
  imports = [ inputs.stylix.homeModules.stylix inputs.niri.homeModules.stylix ];

  stylix = {
    enable = true;
    polarity = "dark";
    image = ../../share/wallpapers/flower.png;

    base16Scheme = lib.mapAttrs (_: lib.removePrefix "#") palette;

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.cantarell-fonts;
        name = "Cantarell";
      };
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 16;
    };

    icons = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
      light = "Papirus";
    };

    # Modules with manual theming today — migrate one at a time.
    targets = {
      # Must be gated: enabling writes programs.niri.settings, which would emit a
      # niri/config.kdl even on sway hosts (settings defaults null → no file).
      niri.enable     = (osConfig.compositor or "sway") == "niri";
      waybar.enable   = false;
      kitty.enable    = false;
      neovim.enable   = false;
      swaylock.enable = false;
      mako.enable     = false;
      obsidian.enable = false;
      firefox.profileNames = [ "liana" ];

      # Thunar (and other GTK apps) use these named colors for view/window bg.
      gtk.extraCss = ''
        @define-color window_bg_color ${colors.background};
        @define-color view_bg_color ${colors.background};
      '';
    };
  };

  # Dark mode for electron flatpaks
  gtk.gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
  gtk.gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;

  # Override stylix' sway colors: translucent indigo on focused, invisible otherwise.
  wayland.windowManager.sway.config.colors = let
    focus = "${indigo}cc";
    invisible = {
      border = "#00000000"; background = "#00000000";
      text = white; indicator = "#00000000"; childBorder = "#00000000";
    };
  in {
    focused         = lib.mkForce { border = focus; background = focus; text = white; indicator = focus; childBorder = focus; };
    focusedInactive = lib.mkForce invisible;
    unfocused       = lib.mkForce invisible;
    urgent          = lib.mkForce { border = red;   background = red;   text = white; indicator = red;   childBorder = red;   };
  };

  # Swaylock: indigo ring, dark inside. Swaylock wants RRGGBBAA (no #).
  programs.swaylock.settings = let
    rgba = hex: (lib.removePrefix "#" hex) + "ff";
    transparent = "00000000";
  in {
    image              = "${../../share/wallpapers/flower.png}";
    color              = rgba background;
    ring-color         = rgba indigo;
    inside-color       = rgba mbg;
    text-color         = rgba foreground;
    line-color         = transparent;
    separator-color    = transparent;
    key-hl-color       = rgba green;
    bs-hl-color        = rgba red;

    ring-ver-color     = rgba orange;
    inside-ver-color   = rgba mbg;
    text-ver-color     = rgba foreground;

    ring-wrong-color   = rgba red;
    inside-wrong-color = rgba mbg;
    text-wrong-color   = rgba foreground;

    ring-clear-color   = rgba green;
    inside-clear-color = rgba mbg;
    text-clear-color   = rgba foreground;

    caps-lock-key-hl-color = rgba orange;
    caps-lock-bs-hl-color  = rgba red;
  };

}
