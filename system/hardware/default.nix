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

  # Rules for systemd-udevd
  # Credit: KyleOndy
  services.udev = {
    packages = [ pkgs.yubikey-personalization ];
    extraRules = ''
      # CalDigit TS4 Thunderbolt dock - start sleep inhibitor when connected
      # Trigger on Thunderbolt device add/remove events for CalDigit vendor
      ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{device_name}=="TS4", ATTR{vendor_name}=="CalDigit, Inc.", TAG+="systemd", ENV{SYSTEMD_WANTS}="inhibit-sleep-when-docked.service"
      ACTION=="remove", SUBSYSTEM=="thunderbolt", ATTR{device_name}=="TS4", ATTR{vendor_name}=="CalDigit, Inc.", RUN+="${pkgs.systemd}/bin/systemctl stop inhibit-sleep-when-docked.service"
    '';
  };
  
  # Disable mouse acceleration
  services.libinput.mouse.accelProfile = "flat";

  # Allow printing
  services.printing.enable = true;

  environment.systemPackages = with pkgs; [
    sbctl
    dmidecode
    hdparm
    smartmontools
  ];

  # Use minimal kernel parameters, including one that turns off ASPM,
  # which seems to enable suspend to work on the Framework 13 AMD laptop when using a dock
  #boot.kernelParams = [
    # Uncomment if there are suspend issues when using a dock
    #"pcie_aspm=off"
  #];
}
