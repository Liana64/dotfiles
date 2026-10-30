# Layout:
#   /             tmpfs             (ephemeral)
#   /dev/sda
#     ├─ p1  ESP    512M  vfat → /boot
#     └─ p2  btrfs  rest
#         ├─ /@nix      → /nix
#         ├─ /@persist  → /persist
#         └─ /@log      → /var/log
{
  disko.devices = {
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = ["mode=755" "size=512M" "nosuid" "nodev"];
    };

    disk.main = {
      type = "disk";
      device = "/dev/sda";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            size = "512M";
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
              extraArgs = ["-f"];
              subvolumes = {
                "/@nix" = {
                  mountpoint = "/nix";
                  mountOptions = ["compress=zstd" "noatime" "nosuid" "nodev"];
                };
                "/@persist" = {
                  mountpoint = "/persist";
                  mountOptions = ["compress=zstd" "noatime" "nosuid" "nodev" "noexec"];
                };
                "/@log" = {
                  mountpoint = "/var/log";
                  mountOptions = ["compress=zstd" "noatime" "nosuid" "nodev" "noexec"];
                };
              };
            };
          };
        };
      };
    };
  };
}
