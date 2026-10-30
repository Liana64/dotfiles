{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["fmask=0077" "dmask=0077"];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = ["-L" "catbox" "-f"];
              subvolumes = {
                "/@root" = {
                  mountpoint = "/";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "/@home" = {
                  mountpoint = "/home";
                  mountOptions = ["compress=zstd" "noatime" "nodev"];
                };
                "/@nix" = {
                  mountpoint = "/nix";
                  mountOptions = ["compress=zstd" "noatime" "nosuid" "nodev"];
                };
              };
            };
          };
        };
      };
    };
  };
}
