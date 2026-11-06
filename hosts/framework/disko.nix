{user, ...}: {
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
                  "/@home/.snapshots" = {};
                  "/@cache" = {
                    mountpoint = "/home/${user.name}/.cache";
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
                  "/@persist/.snapshots" = {};
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

  fileSystems."/persist".neededForBoot = true;
}
