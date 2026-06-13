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

  #security.pam.services.swaylock = {
  #  fprintAuth = true;
  #};

  # Enable Thunderbolt 3 support for CalDigit TS4 (enroll with `boltctl`)
  # This uses the gnome bolt daemon
  services.hardware.bolt.enable = true;
  environment.systemPackages = with pkgs; [
    dmidecode         # BIOS troubleshooting
    ethtool           # Manage networking
    hdparm            # Manage drives
    nvme-cli          # Manage NVMes
    perf              # Benchmarking
    sbctl             # Sign our own EFI shim
    smartmontools     # Check smart data on disks
    sysstat           # Troubleshoot performance
    tcpdump           # Troubleshoot networking
    inotify-tools     # Use inotify
    lm_sensors        # Temperature sensors
  ];

  # pcie_aspm=off used to prevent link drops under load for the Caldigit TS4,
  # now it's probably not needed anymore.
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
