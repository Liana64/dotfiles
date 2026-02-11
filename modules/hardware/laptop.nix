{ pkgs, ... }: {

  # Rules for systemd-udevd
  # Credit: KyleOndy
  # https://github.com/KyleOndy/dotfiles/blob/51098f0b2fdd9c903a7e08d27a9dd0f240c16a11/nix/hosts/dino/configuration.nix#L382
  services.udev = {
    packages = [ pkgs.yubikey-personalization ];
    extraRules = ''
      # CalDigit TS4 Thunderbolt dock - start sleep inhibitor when connected
      # Trigger on Thunderbolt device add/remove events for CalDigit vendor
      ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{device_name}=="TS4", ATTR{vendor_name}=="CalDigit, Inc.", TAG+="systemd", ENV{SYSTEMD_WANTS}="inhibit-sleep-when-docked.service"
      ACTION=="remove", SUBSYSTEM=="thunderbolt", ATTR{device_name}=="TS4", ATTR{vendor_name}=="CalDigit, Inc.", RUN+="${pkgs.systemd}/bin/systemctl stop inhibit-sleep-when-docked.service"
    '';
  };

  # Prevent system sleep when CalDigit TS4 dock is connected
  # This ensures the laptop stays awake while docked, even if lid is closed
  # Triggered by udev rules when dock connects/disconnects
  # Credit: KyleOndy
  # https://github.com/KyleOndy/dotfiles/blob/51098f0b2fdd9c903a7e08d27a9dd0f240c16a11/nix/hosts/dino/configuration.nix#L382
  systemd.services.inhibit-sleep-when-docked =
    let
      monitorScript = pkgs.writeShellScript "monitor-dock-connected" ''
        #!/usr/bin/env bash
        set -euo pipefail

        echo "$(date): CalDigit dock connected, holding sleep inhibitor"

        # Monitor dock connection status
        while true; do
          DOCK_INFO=$(${pkgs.bolt}/bin/boltctl list 2>/dev/null || true)

          if echo "$DOCK_INFO" | ${pkgs.gnugrep}/bin/grep -q "CalDigit" && \
             echo "$DOCK_INFO" | ${pkgs.gnugrep}/bin/grep -A10 "CalDigit" | ${pkgs.gnugrep}/bin/grep -qE "status:[[:space:]]+connected$"; then
            # Still connected, keep holding inhibitor
            sleep 10
          else
            # Dock disconnected, exit to release inhibitor
            echo "$(date): CalDigit dock disconnected, releasing sleep inhibitor"
            exit 0
          fi
        done
      '';
    in
    {
      description = "Inhibit sleep when CalDigit TS4 Thunderbolt dock is connected";
      # Service is triggered by udev rules, not started at boot
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.systemd}/bin/systemd-inhibit --what=sleep:handle-lid-switch --who='CalDigit TS4 Dock Monitor' --why='Prevent sleep while docked' --mode=block ${monitorScript}";
        Restart = "on-failure";
      };
    };

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
