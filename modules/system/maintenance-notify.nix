# @desc: Sticky desktop notification when weekly maintenance (gc, verify, trim, scrub) starts
{...}: {
  flake.modules.nixos.maintenanceNotify = {
    config,
    lib,
    pkgs,
    utils,
    user,
    hardening,
    ...
  }: let
    scrub = config.services.btrfs.autoScrub;
    units =
      ["nix-store-verify"]
      ++ lib.optional config.nix.gc.automatic "nix-gc"
      ++ lib.optional config.services.fstrim.enable "fstrim"
      ++ lib.optionals scrub.enable (map (fs: "btrfs-scrub-${utils.escapeSystemdPath fs}") scrub.fileSystems);
    bus = "/run/user/${toString user.uid}/bus";
  in {
    systemd.services =
      lib.genAttrs units (_: {wants = ["maintenance-notify@%N.service"];})
      // {
        "maintenance-notify@" = {
          unitConfig.ConditionPathExists = bus;
          environment.DBUS_SESSION_BUS_ADDRESS = "unix:path=${bus}";
          serviceConfig =
            hardening.confined
            // {
              Type = "oneshot";
              User = user.name;
              ProtectHome = "tmpfs";
              BindReadOnlyPaths = [bus];
              PrivateNetwork = true;
              RestrictAddressFamilies = "AF_UNIX";
              ExecStart = "${pkgs.libnotify}/bin/notify-send -t 0 -a maintenance %i running";
            };
        };
      };
  };
}
