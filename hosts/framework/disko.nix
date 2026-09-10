# Layout:
#   /dev/nvme0n1
#     ├─ p1  ESP   1G      vfat → /boot
#     ├─ p2  LUKS  1477G   → cryptroot
#     │   └─ btrfs (label: nixos)
#     │       ├─ /@root        → /
#     │       ├─ /@root-blank  →                      (empty rollback target; set ro after deploy)
#     │       ├─ /@home        → /home
#     │       ├─ /@cache       → /home/liana/.cache   (relatime, never snapshotted)
#     │       ├─ /@nix         → /nix
#     │       ├─ /@persist     → /persist
#     │       ├─ /@log         → /var/log             (journal churn, out of @persist snapshots)
#     │       ├─ /@containers  → /var/lib/containers  (podman storage, holds nested subvolumes)
#     │       └─ /@swap        → /swap                (NOCOW swapfile)
#     ├─ p3  ESP   1G                                 (deck /boot — bare here)
#     └─ p4  btrfs 384G                               (deck root — bare here)
{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_2000GB_24270X804909";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["fmask=0077" "dmask=0077"];
            };
          };
          luks = {
            priority = 2;
            size = "1477G";
            content = {
              type = "luks";
              name = "cryptroot";
              settings.allowDiscards = true;
              content = {
                type = "btrfs";
                extraArgs = ["-L" "nixos" "-f"];
                subvolumes = {
                  "/@root" = {
                    mountpoint = "/";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  "/@root-blank" = {};
                  "/@home" = {
                    mountpoint = "/home";
                    mountOptions = ["compress=zstd" "noatime" "nosuid" "nodev"];
                  };
                  "/@cache" = {
                    mountpoint = "/home/liana/.cache";
                    mountOptions = ["compress=zstd" "relatime" "nosuid" "nodev"];
                  };
                  "/@nix" = {
                    mountpoint = "/nix";
                    mountOptions = ["compress=zstd" "noatime" "nosuid" "nodev"];
                  };
                  "/@persist" = {
                    mountpoint = "/persist";
                    mountOptions = ["compress=zstd" "noatime" "nosuid" "nodev"];
                  };
                  "/@log" = {
                    mountpoint = "/var/log";
                    mountOptions = ["compress=zstd" "noatime" "nosuid" "nodev" "noexec"];
                  };
                  "/@containers" = {
                    mountpoint = "/var/lib/containers";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  "/@swap" = {
                    mountpoint = "/swap";
                    mountOptions = ["noatime" "nosuid" "nodev" "noexec"];
                    swap.swapfile.size = "32G";
                  };
                };
              };
            };
          };
          deckEsp = {
            priority = 3;
            size = "1G";
            type = "EF00";
          };
          deckRoot = {
            priority = 4;
            size = "100%";
          };
        };
      };
    };
  };

  # machine-id, host keys, sops live here, mount before stage-2
  fileSystems."/persist".neededForBoot = true;
}
