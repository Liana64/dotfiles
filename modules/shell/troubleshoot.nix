# @desc: Troubleshooting packages
{...}: {
  flake.modules.homeManager.troubleshootPackages = {pkgs, ...}: {
    home.packages = with pkgs; [
      dig
      net-tools
      rclone
      rustscan
      usbutils
      watchexec
    ];
  };
}
