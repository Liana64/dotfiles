 {
  lib,
  pkgs,
  ...
}:
let
  compositor = "sway";
  useSway = compositor == "sway";
  useNiri = compositor == "niri";
in
{
  imports = [
    ./audio.nix
    ./fonts.nix
  ];

  hardware = {
    graphics.enable = true;
  };

  programs = {
    sway = {
      enable = useSway;
      wrapperFeatures.gtk = true;
    };

    niri = {
      enable = useNiri;
    };

    dconf.enable = true;

    # Allow brightness control
    light.enable = true;
  };
  
  services = {
    xserver.enable = true;

    displayManager = {
      gdm = {
        enable = true;
        wayland = true;
      };
    };
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ] ++ lib.optionals useNiri [
      xdg-desktop-portal-gnome
    ];
  };


  environment.systemPackages = with pkgs; [
    fuzzel
    mako
    wl-clipboard
    grim
    slurp
  ] ++ lib.optionals useSway [
    swaybg
    swaylock
    swayidle
  ];
}
