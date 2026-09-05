{
  disko.devices = {
    disk = {
      boot = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-KXG50ZNV256G_NVMe_TOSHIBA_256GB_58VB7DBLKAUP";
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
        device = "/dev/disk/by-id/ata-SPCC_Solid_State_Disk_AA000000000000004607";
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
        };
      };

      # talos-pool 512G→128G: quorum-only node (2% used); rest hosts the rhca lab
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
          lab = {
            type = "zfs_fs";
            mountpoint = "/var/lib/lab";
            options.mountpoint = "legacy";
          };
          talos-os = {
            type = "zfs_volume";
            size = "128G";
          };
          talos-pool = {
            type = "zfs_volume";
            size = "128G";
          };
        };
      };
    };
  };
}
