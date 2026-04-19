{config, pkgs, lib, ...}:
{
  # Allow printing
  services.printing.enable = true;

  # Enable bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };
  environment.systemPackages = [ pkgs.blueman ];

  # Automatically set regulatory domain for the wireless network card
  hardware.wirelessRegulatoryDatabase = true;
}
