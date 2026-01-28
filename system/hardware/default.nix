{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # Everything is updateable through fwupd, so it's enabled by default.
    inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
    ./power-saving.nix
    ./ssd.nix
  ];

  # To get the latest firmware, run:
  # $ fwupdmgr refresh
  # $ fwupdmgr update
  services.fwupd.enable = true;

  # Enable the fingerprint reader
  services.fprintd.enable = true;

  # Framework kernel module
  # Enables battery charge limit, privacy switches, and system LEDs as
  # standard driver interfaces. Enabled by default on NixOS >= 24.05 and
  # Kernel >= 6.10
  hardware.framework.enableKmod = true;

  # Use minimal kernel parameters, including one that turns off ASPM,
  # which seems to enable suspend to work on the Framework 13 AMD laptop when using a dock
  #boot.kernelParams = [
    # Uncomment if there are suspend issues when using a dock
    #"pcie_aspm=off"
  #];
}
