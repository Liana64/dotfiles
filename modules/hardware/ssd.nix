# @desc: SSD tuning (fstrim)
{...}: {
  flake.modules.nixos.ssd = {
    lib,
    config,
    utils,
    ...
  }: let
    hardening = import ../_lib/systemd-hardening.nix;
    scrubCfg = config.services.btrfs.autoScrub;
  in {
    services.fstrim.enable = lib.mkDefault true;
    services.smartd.enable = true;

    systemd.services = lib.mkMerge [
      {
        # NVMe SMART ioctls need CAP_SYS_ADMIN (SATA would need SYS_RAWIO);
        # wall notifications are local, so the network can go entirely
        smartd.serviceConfig =
          hardening.base
          // {
            ProtectHome = true;
            PrivateNetwork = true;
            CapabilityBoundingSet = "CAP_SYS_RAWIO CAP_SYS_ADMIN";
            RestrictAddressFamilies = ["AF_UNIX" "AF_NETLINK"];
            RestrictNamespaces = true;
            SystemCallArchitectures = "native";
          };
      }
      # scrub works through CAP_SYS_ADMIN ioctls on the mount point, never /dev
      # or the network; status lands in /var/lib/btrfs (writable under full)
      (lib.mkIf scrubCfg.enable (lib.listToAttrs (map (fs: {
          name = "btrfs-scrub-${utils.escapeSystemdPath fs}";
          value.serviceConfig =
            hardening.base
            // {
              ProtectHome = true;
              PrivateNetwork = true;
              PrivateDevices = true;
              CapabilityBoundingSet = "CAP_SYS_ADMIN";
              RestrictAddressFamilies = "AF_UNIX";
              RestrictNamespaces = true;
              SystemCallArchitectures = "native";
            };
        })
        scrubCfg.fileSystems)))
    ];
  };
}
