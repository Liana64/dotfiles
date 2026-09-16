{...}: {
  flake.modules.homeManager.troubleshootPackages = {pkgs, ...}: {
    home.packages = with pkgs; [
      dig
      rclone
      rustscan
      usbutils
      watchexec
    ];
  };
}
