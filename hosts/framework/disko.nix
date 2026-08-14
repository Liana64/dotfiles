# disko layout for framework, sized for impermanence
#
# NEVER RUN destroy/format/default MODE — those rewrite the GPT and take the
# bazzite partitions (3/4) with it. Subvolumes are created by hand and only
# `disko --mode mount` is ever used; see docs/MIGRATION.md
#
# Layout (target):
#   /dev/nvme0n1
#     ├─ p1  ESP   1G       vfat → /boot           (existing)
#     ├─ p2  LUKS  1.3T     → cryptroot            (existing partition, contents restructured)
#     │   └─ btrfs (label: nixos)
#     │       ├─ /@root        → /
#     │       ├─ /@root-blank  →                    (readonly snapshot of empty @root)
#     │       ├─ /@home        → /home
#     │       ├─ /@cache       → /home/liana/.cache   (relatime, never snapshotted)
#     │       ├─ /@nix         → /nix
#     │       ├─ /@persist     → /persist
#     │       ├─ /@log         → /var/log             (journal churn, out of @persist snapshots)
#     │       ├─ /@containers  → /var/lib/containers  (podman storage, holds nested subvolumes)
#     │       └─ /@swap        → /swap              (NOCOW swapfile)
#     ├─ p3  ext4  1G        BZ_BOOT                (Bazzite — leave alone)
#     └─ p4  btrfs 512G      (Bazzite — leave alone)
{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_2000GB_24270X804909";
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
          luks = {
            size = "100%";
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
        };
      };
    };
  };

  # machine-id, host keys, sops live here, mount before stage-2
  fileSystems."/persist".neededForBoot = true;
}
