let
  mkBoot = idx: device: {
    type = "disk";
    inherit device;
    content = {
      type = "gpt";
      partitions = {
        esp = {
          size = "2G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot${toString idx}";
            mountOptions = ["umask=0077"];
          };
        };
        zfs = {
          size = "100%";
          content = {
            type = "zfs";
            pool = "rpool";
          };
        };
      };
    };
  };
in {
  disko.devices = {
    disk = {
      boot0 = mkBoot 0 "/dev/disk/by-id/nvme-WD_BLACK_SN770_2TB_244542800309";
      boot1 = mkBoot 1 "/dev/disk/by-id/nvme-Viper_VP4300_2TB_VP4300DFBA2308016025";
    };

    zpool.rpool = {
      type = "zpool";
      mode = "mirror";
      options.ashift = "12";

      # TODO: ZFS encryption, clevis/tang
      rootFsOptions = {
        mountpoint = "none";
        compression = "zstd";
        acltype = "posixacl";
        xattr = "sa";
        atime = "off";
      };
      datasets = {
        reserved = {
          type = "zfs_fs";
          options = {
            mountpoint = "none";
            refreservation = "10G";
          };
        };
        root = {
          type = "zfs_fs";
          mountpoint = "/";
          options.mountpoint = "legacy";
        };
        nix = {
          type = "zfs_fs";
          mountpoint = "/nix";
          options.mountpoint = "legacy";
        };
        var = {
          type = "zfs_fs";
          mountpoint = "/var";
          options.mountpoint = "legacy";
        };
        vms = {
          type = "zfs_fs";
          options.mountpoint = "none";
        };
        "vms/talos-os" = {
          type = "zfs_volume";
          size = "128G";
        };
        "vms/talos-pool" = {
          type = "zfs_volume";
          size = "1280G";
        };
        "vms/opnsense-os" = {
          type = "zfs_volume";
          size = "48G";
        };
      };
    };
  };
}
