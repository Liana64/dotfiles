 {
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.compositor;
  useSway = cfg == "sway";
  useNiri = cfg == "niri";
in
{
  options.compositor = lib.mkOption {
    type = lib.types.enum [ "sway" "niri" ];
    default = "sway";
    description = "Wayland compositor to use for the graphical session.";
  };

  config = {

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
      package = pkgs.niri;
    };

    dconf.enable = true;
  };

  services.udev.packages = [ pkgs.brightnessctl ];
  users.users.liana.extraGroups = [ "video" ];
  
  # Don't add sodiboo's cachix; niri comes from nixpkgs (pkgs.niri).
  niri-flake.cache.enable = false;

  services = {
    dbus.enable = true;

    greetd = {
      enable = true;
      settings.default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${if useNiri then "niri-session" else "sway"}";
        user = "greeter";
      };
    };

    # Unused on sway, creates zombies
    speechd.enable = false;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    # niri needs the gnome portal (added by its nixos module) for screencast;
    # forcing gtk-only would shadow it, so scope the force to sway.
    config.common.default = lib.mkIf useSway (lib.mkForce ["gtk"]);
  };
  
  # Disable screencopy
  systemd.user.services."xdg-desktop-portal-wlr" = {
    enable = false;
  };

  # swaybg/swayidle are compositor-agnostic despite the names.
  environment.systemPackages = with pkgs; [
    brightnessctl
    fuzzel
    wl-clipboard
    playerctl
    grim
    dbus
    slurp
    libnotify
    libsecret
    swaybg
    swayidle
  ];
  };
}
