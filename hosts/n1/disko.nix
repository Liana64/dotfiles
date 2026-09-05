{
  disko.devices = {
    disk = {
      boot = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-WD_Blue_SN580_250GB_24526N803348";
        content = {
          type = "gpt";
          partitions = {
            esp = {
              size = "2G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
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
      data = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-WD_BLACK_SN770_1TB_241009808010";
        content = {
          type = "gpt";
          partitions.zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "vms";
            };
          };
        };
      };
    };

    zpool = {
      rpool = {
        type = "zpool";
        options.ashift = "12";

        # unencrypted — future: native zfs encryption, clevis/tang unlock
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
          # router on the os disk: a full vms pool must not take down the wan
          "vms/opnsense-os" = {
            type = "zfs_volume";
            size = "48G";
          };
        };
      };

      # single disk, no redundancy — durability is syncoid to m1 + volsync/B2
      vms = {
        type = "zpool";
        options.ashift = "12";
        rootFsOptions = {
          mountpoint = "none";
          compression = "zstd";
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
          talos-os = {
            type = "zfs_volume";
            size = "128G";
          };
          talos-pool = {
            type = "zfs_volume";
            size = "755G";
          };
        };
      };
    };
  };
}
