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

  hardware = {
    graphics.enable = true;
  };

  programs = {
    sway = {
      enable = useSway;
      wrapperFeatures.gtk = true;
      package = pkgs.sway;
    };

    niri = {
      enable = useNiri;
    };

    dconf.enable = true;

    # Allow brightness control
    light.enable = true;
  };
  
  services= {
    #xserver.enable = true;
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
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = lib.mkForce ["gtk"];
  };
  
  # Disable screencopy
  systemd.user.services."xdg-desktop-portal-wlr" = {
    enable = false;
  };

  environment.systemPackages = with pkgs; [
    fuzzel
    wl-clipboard
    playerctl
    grim
    dbus
    slurp
    libsecret
    imagemagick
  ] ++ lib.optionals useSway [
    swaybg
    swayidle
    #swaylock
  ];
}
