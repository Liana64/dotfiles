# @desc: Troubleshooting packages
{...}: {
  flake.modules.homeManager.troubleshootPackages = {pkgs, ...}: {
    home.packages = with pkgs; [
      dig
      iperf3
      net-tools
      nmap
      rclone
      rustscan
      usbutils
      watchexec
    ];

    home.file.".rustscan.toml".source = (pkgs.formats.toml {}).generate "rustscan.toml" {
      batch_size = 65535;
    };
  };
}
