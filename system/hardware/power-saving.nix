{ ... }: {
  # Configure how the system sleeps when the lid is closed;
  # specifically, it should sleep or suspend in all cases
  # --> when running on battery power
  # --> when connected to external power
  # --> when connected to a dock that has external power
  services.logind.settings.Login.HandleLidSwitch = "suspend";
  services.logind.settings.Login.HandleLidSwitchExternalPower = "suspend";
  services.logind.settings.Login.HandleLidSwitchDocked = "suspend";

  # Disable light sensors and accelerometers
  hardware.sensor.iio.enable = false;

  # Power settings
  services = {
    upower = {
      enable = true;
      percentageLow = 15;
      percentageCritical = 5;
    };

    # Choose one or the other
    power-profiles-daemon.enable = true;
    tlp.enable = false;

    #auto-cpufreq = {
    #  enable = true;
    #  settings = {
    #    battery = {
    #      governor = "powersave";
    #      turbo = "never";
    #    };
    #    charger = {
    #      governor = "performance";
    #      turbo = "auto";
    #    };
    #  };
    #};
  };
}
