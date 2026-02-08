{config, pkgs, ...}:
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;
  #services.unifi.enable = true;
  #services.unifi.openFirewall = true;
  #services.unifi.unifiPackage = pkgs.unifi;
  #services.unifi.mongodbPackage = pkgs.mongodb-7_0;

  # Automatically set the regulatory domain for
  # the wireless network card.
  hardware.wirelessRegulatoryDatabase = true;
}
