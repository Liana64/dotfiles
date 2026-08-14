# @desc: noexec mounts — /dev/shm, /var/tmp, /var/log, /boot
{...}: {
  flake.modules.nixos.noexec = {
    config,
    lib,
    ...
  }: {
    boot.specialFileSystems."/dev/shm".options = ["noexec"];
    fileSystems."/var/tmp" = {
      device = "/var/tmp";
      fsType = "none";
      options = ["bind" "nosuid" "nodev" "noexec"];
    };
    fileSystems."/var/log" = lib.mkIf (!config.impermanence) {
      device = "/var/log";
      fsType = "none";
      options = ["bind" "nosuid" "nodev" "noexec"];
    };
    fileSystems."/boot".options = ["nosuid" "nodev" "noexec"];
  };
}
