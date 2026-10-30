# @desc: Sway Wayland session: greetd, portals, session tools
{...}: {
  flake.modules.nixos.compositor = {
    lib,
    pkgs,
    ...
  }: {
    hardware = {
      graphics.enable = true;
    };

    programs = {
      sway = {
        enable = true;
        wrapperFeatures.gtk = true;
        package = pkgs.sway;
      };

      dconf.enable = true;
    };

    services.udev.packages = [pkgs.brightnessctl];
    users.users.liana.extraGroups = ["video"];

    services = {
      dbus.enable = true;

      logind.settings.Login = {
        NAutoVTs = 0;
        ReserveVT = 0;
      };

      greetd = {
        enable = true;
        settings.default_session = {
          command = "${pkgs.bash}/bin/sh -c '${pkgs.kbd}/bin/kbd_mode -u; exec ${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd sway'";
          user = "greeter";
        };
      };

      # Unused on sway, creates zombies
      speechd.enable = false;
    };

    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
      config.common.default = lib.mkForce ["gtk"];
    };

    # Disable screencopy
    systemd.user.services."xdg-desktop-portal-wlr" = {
      enable = false;
    };

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
