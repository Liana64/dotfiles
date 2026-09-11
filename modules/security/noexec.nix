# @desc: noexec mounts — /dev/shm, /var/tmp, /var/log, ESPs
{...}: {
  flake.modules.nixos.noexec = {
    config,
    lib,
    ...
  }: let
    esps =
      if config.boot.loader.grub.mirroredBoots == []
      then ["/boot"]
      else map (b: b.efiSysMountPoint) config.boot.loader.grub.mirroredBoots;
  in {
    boot.specialFileSystems."/dev/shm".options = ["noexec"];
    fileSystems =
      {
        "/var/tmp" = {
          device = "/var/tmp";
          fsType = "none";
          options = ["bind" "nosuid" "nodev" "noexec"];
        };
      }
      // lib.optionalAttrs (!(config.impermanence or false)) {
        "/var/log" = {
          device = "/var/log";
          fsType = "none";
          options = ["bind" "nosuid" "nodev" "noexec"];
        };
      }
      // lib.genAttrs esps (_: {options = ["nosuid" "nodev" "noexec"];});
  };
}
