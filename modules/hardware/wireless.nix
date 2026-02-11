{config, pkgs, ...}:
{

  # Allow printing
  services.printing.enable = true;

  # Enable bluetooth
  services.blueman.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  # Automatically set the regulatory domain for
  # the wireless network card.
  hardware.wirelessRegulatoryDatabase = true;
}
