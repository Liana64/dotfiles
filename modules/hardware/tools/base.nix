# @desc: Hardware diagnostics
_: {
  flake.modules.nixos.hardwareTools = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      dmidecode # Hardware profiling
      ethtool # Manage networking
      hdparm # Manage drives
      nvme-cli # Manage NVMes
      smartmontools # Check smart data on disks
      sysstat # Troubleshoot performance
      tcpdump # Troubleshoot networking
      lm_sensors # Temperature sensors
      pciutils # PCI utilities
      usbutils # USB utilities
      efibootmgr # Manage EFI boot settings
    ];
  };
}
