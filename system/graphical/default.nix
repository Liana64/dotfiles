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
      package = pkgs.swayfx;
    };

    niri = {
      enable = useNiri;
    };

    dconf.enable = true;

    # Allow brightness control
    light.enable = true;
  };
  
  services= {
    xserver.enable = true;
    dbus.enable = true;

    displayManager = {
      gdm = {
        enable = true;
        wayland = true;
      };
    };
  };

  xdg.portal = {
    enable = true;
    config = {
      sway = {
        default = lib.mkForce ["wlr" "gtk"];
        "org.freedesktop.impl.portal.Screenshot" = ["wlr"];
        "org.freedesktop.impl.portal.ScreenCast" = ["wlr"];
      };
    };
    wlr.enable = true;
    
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };


  environment.systemPackages = with pkgs; [
    fuzzel
    wl-clipboard
    mako
    playerctl
    grim
    dbus
    slurp
    libsecret
  ] ++ lib.optionals useSway [
    swaybg
    swaylock
    swayidle
  ];
}
