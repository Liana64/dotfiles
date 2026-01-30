{config, pkgs, ...}:
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;

  # Automatically set the regulatory domain for
  # the wireless network card.
  hardware.wirelessRegulatoryDatabase = true;
}
