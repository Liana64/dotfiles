# @desc: Framework AMD AI 300 hardware module + firmware
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

  # Exposes battery charge limit, privacy switches, and LEDs as driver interfaces
  hardware.framework.enableKmod = true;

  # Enable the fingerprint reader
  services.fprintd.enable = true;

  #security.pam.services.swaylock = {
  #  fprintAuth = true;
  #};

  # Enable Thunderbolt 3 support for CalDigit TS4 (enroll with `boltctl`)
  # This uses the gnome bolt daemon
  services.hardware.bolt.enable = true;
  environment.systemPackages = with pkgs; [
    dmidecode # BIOS troubleshooting
    ethtool # Manage networking
    hdparm # Manage drives
    nvme-cli # Manage NVMes
    perf # Benchmarking
    sbctl # Sign our own EFI shim
    smartmontools # Check smart data on disks
    sysstat # Troubleshoot performance
    tcpdump # Troubleshoot networking
    inotify-tools # Use inotify
    lm_sensors # Temperature sensors
  ];

  # pcie_aspm=off prevents CalDigit TS4 link drops under load
  boot.kernelParams = [
    #"pcie_aspm=off"
    "quiet"
    "splash"
    "udev.log_level=3"
    "rd.systemd.show_status=auto"
  ];

  # Keep boot console quiet so kernel/udev messages don't overwrite plymouth/tuigreet
  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;
}
