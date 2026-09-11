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
          };
          luks = {
            priority = 2;
            size = "1477G";
          };
          deckEsp = {
            priority = 3;
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["fmask=0077" "dmask=0077"];
            };
          };
          deckRoot = {
            priority = 4;
            size = "100%";
            content = {
              type = "luks";
              name = "cryptdeck";
              settings.allowDiscards = true;
              content = {
                type = "btrfs";
                extraArgs = ["-L" "deck" "-f"];
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
                  "/@nix" = {
                    mountpoint = "/nix";
                    mountOptions = ["compress=zstd" "noatime" "nosuid" "nodev"];
                  };
                  "/@persist" = {
                    mountpoint = "/persist";
                    mountOptions = ["compress=zstd" "noatime" "nosuid" "nodev"];
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
