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
  
  services = {
    dbus.enable = true;

    greetd = {
      enable = true;
      settings.default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd sway";
        user = "greeter";
      };
    };

    # Unused on sway, creates zombies
    speechd.enable = false;
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
    libnotify
    libsecret
  ] ++ lib.optionals useSway [
    swaybg
    swayidle
    #swaylock
  ];
}
