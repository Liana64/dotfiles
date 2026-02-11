{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
  ];

  # To get the latest firmware, run:
  # $ fwupdmgr refresh
  # $ fwupdmgr update
  services.fwupd.enable = true;

  # Framework kernel module
  # Enables battery charge limit, privacy switches, and system LEDs as
  # standard driver interfaces. Enabled by default on NixOS >= 24.05 and
  # Kernel >= 6.10
  hardware.framework.enableKmod = true;

  # Enable the fingerprint reader
  services.fprintd.enable = true;

  # Enable Thunderbolt 3 support for CalDigit TS4 (enroll with `boltctl`)
  # This uses the gnome bolt daemon
  services.hardware.bolt.enable = true;
  environment.systemPackages = with pkgs; [
    sbctl             # Sign our own EFI shim
    dmidecode         # BIOS troubleshooting
    hdparm
    smartmontools     # Check smart data on disks
    nvme-cli
    sysstat           # Troubleshoot performance
    perf
    ethtool
    tcpdump
  ];

  # Use minimal kernel parameters, including one that turns off ASPM,
  # which seems to enable suspend to work on the Framework 13 AMD laptop when using a dock
  #boot.kernelParams = [
    # Uncomment if there are suspend issues when using a dock
    #"pcie_aspm=off"
  #];

}
