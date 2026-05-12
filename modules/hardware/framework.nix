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
  # Duplicate of keyring.nix; kept here commented for reference.
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

  # Disable PCIe ASPM. Without this, the CalDigit TS4 dock's internal PCIe
  # link (igc NIC, USB-C PD) drops under load, taking the system with it.
  boot.kernelParams = [
    "pcie_aspm=off"
  ];

}
