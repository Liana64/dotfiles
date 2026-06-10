{pkgs, ...}:
{
  # Enable printing if needed
  services.printing.enable = false;

  # Enable bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  environment.systemPackages = [ pkgs.blueman pkgs.iw ];

  # Upstream unit has no Restart=; bluetoothd dying leaves blueman unable to
  # reach BlueZ until next boot. Always bring it back.
  systemd.services.bluetooth.serviceConfig = {
    Restart = "always";
    RestartSec = "2s";
  };

  # Automatically set regulatory domain for the wireless network card
  hardware.wirelessRegulatoryDatabase = true;
}
