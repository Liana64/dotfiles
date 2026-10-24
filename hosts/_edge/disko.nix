{
  config,
  lib,
  ...
}: let
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
    disk = lib.listToAttrs (lib.imap0 (i: d: lib.nameValuePair "boot${toString i}" (mkBoot i d)) config.edge.disks);

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
          postCreateHook = "zfs snapshot rpool/root@blank";
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
          size = config.edge.talos.poolSize;
        };
        "vms/opnsense-os" = {
          type = "zfs_volume";
          size = "48G";
        };
      };
    };
  };
}
