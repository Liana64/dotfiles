{ ... }: {
  # Configure how the system sleeps when the lid is closed;
  # specifically, it should sleep or suspend in all cases
  # --> when running on battery power
  # --> when connected to external power
  # --> when connected to a dock that has external power
  services.logind.lidSwitch = "suspend";
  services.logind.lidSwitchExternalPower = "suspend";
  services.logind.lidSwitchDocked = "suspend";

  # Disable light sensors and accelerometers as
  # they are not used and consume extra battery
  hardware.sensor.iio.enable = false;

  # Enable auto-cpufreq service
  services = {
    upower = {
      enable = true;
      percentageLow = 15;
      percentageCritical = 5;
    };
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
    power-profiles-daemon.enable = true;
    tlp.enable = false;
  };
}
