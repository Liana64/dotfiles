# @desc: Mako notification daemon
{...}: {
  flake.modules.homeManager.mako = {
    colors,
    config,
    ...
  }: let
    hardening = import ../_lib/systemd-hardening.nix;
  in {
    # Route dbus activation to the unit (XDG_DATA_HOME service files win), so
    # a queued notification can never respawn the unhardened transient
    xdg.dataFile."dbus-1/services/org.freedesktop.Notifications.service".text = ''
      [D-BUS Service]
      Name=org.freedesktop.Notifications
      Exec=${config.services.mako.package}/bin/mako
      SystemdService=mako.service
    '';

    # Real unit instead of dbus activation: the transient dbus-* unit it would
    # otherwise run under takes no hardening
    systemd.user.services.mako = {
      Unit = {
        Description = "Mako notification daemon";
        After = ["graphical-session.target"];
        Requisite = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };
      Install.WantedBy = ["graphical-session.target"];
      Service =
        hardening.confined
        // {
          Type = "dbus";
          BusName = "org.freedesktop.Notifications";
          ExecStart = "${config.services.mako.package}/bin/mako";
          Restart = "on-failure";
          ProtectHome = "read-only";
        };
    };

    services.mako = {
      enable = true;

      settings = with colors; {
        default-timeout = 4000;
        ignore-timeout = false;
        icons = true;

        background-color = darker;
        border-color = highlight;
        text-color = foreground;
        border-size = 1;
        border-radius = 8;
        padding = "10,14";
        font = "Cantarell 11";
        progress-color = "over ${highlight}33";

        # Muted red parallel to waybar @alert = mix(color0, red, 0.5).
        "urgency=high" = {
          background-color = "#93504c";
        };
      };
    };
  };
}
