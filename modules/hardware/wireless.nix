{pkgs, ...}:
{
  # Enable printing if needed
  services.printing.enable = false;

  # Enable bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  environment.systemPackages = [ pkgs.blueman ];

  # Automatically set regulatory domain for the wireless network card
  hardware.wirelessRegulatoryDatabase = true;
}
