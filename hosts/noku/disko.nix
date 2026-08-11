# Draft — set disk.main.device (by-id) once the TV box's disk is known,
# then partition from the installer: disko --mode destroy,format,mount
{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/CHANGEME";
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
          main = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = ["-L" "nixos" "-f"];
              subvolumes = {
                "/root" = {
                  mountpoint = "/";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "/home" = {
                  mountpoint = "/home";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "/swap" = {
                  mountpoint = "/swap";
                  mountOptions = ["noatime"];
                  swap.swapfile.size = "8G";
                };
              };
            };
          };
        };
      };
    };
  };
}
