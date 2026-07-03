# @desc: Laptop udev rules + power tuning
{...}: {
  flake.modules.nixos.laptop = {pkgs, ...}: let
    hardening = import ../_lib/systemd-hardening.nix;
  in {
    # Credit: KyleOndy
    # https://github.com/KyleOndy/dotfiles/blob/51098f0b2fdd9c903a7e08d27a9dd0f240c16a11/nix/hosts/dino/configuration.nix#L382
    services.udev = {
      packages = [pkgs.yubikey-personalization];
      extraRules = ''
        ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{device_name}=="TS4", ATTR{vendor_name}=="CalDigit, Inc.", TAG+="systemd", ENV{SYSTEMD_WANTS}="inhibit-sleep-when-docked.service"
        ACTION=="remove", SUBSYSTEM=="thunderbolt", ATTR{device_name}=="TS4", ATTR{vendor_name}=="CalDigit, Inc.", RUN+="${pkgs.systemd}/bin/systemctl stop inhibit-sleep-when-docked.service"
      '';
    };

    # Credit: KyleOndy
    # https://github.com/KyleOndy/dotfiles/blob/51098f0b2fdd9c903a7e08d27a9dd0f240c16a11/nix/hosts/dino/configuration.nix#L382
    systemd.services.inhibit-sleep-when-docked = let
      monitorScript = pkgs.writeShellScript "monitor-dock-connected" ''
        #!/usr/bin/env bash
        set -euo pipefail

        echo "$(date): CalDigit dock connected, holding sleep inhibitor"

        # Let the dock authorize before polling boltctl
        sleep 3

        while true; do
          DOCK_INFO=$(${pkgs.bolt}/bin/boltctl list 2>/dev/null || true)

          if echo "$DOCK_INFO" | ${pkgs.gnugrep}/bin/grep -q "CalDigit" && \
             echo "$DOCK_INFO" | ${pkgs.gnugrep}/bin/grep -A10 "CalDigit" | ${pkgs.gnugrep}/bin/grep -qE "status:[[:space:]]+(connected|authorized)"; then
            sleep 10
          else
            echo "$(date): CalDigit dock disconnected, releasing sleep inhibitor"
            exit 0
          fi
        done
      '';
    in {
      description = "Inhibit sleep when CalDigit TS4 Thunderbolt dock is connected";
      serviceConfig =
        hardening.airgapped
        // {
          Type = "simple";
          ExecStart = "${pkgs.systemd}/bin/systemd-inhibit --what=sleep:handle-lid-switch --who='CalDigit TS4 Dock Monitor' --why='Prevent sleep while docked' --mode=block ${monitorScript}";
          Restart = "on-failure";
          # logind inhibitors are polkit-gated: session-less DynamicUser is
          # denied (crash-looped 2026-06-22); root is implicitly authorized,
          # and no capability is involved, so the bounding set stays empty
          CapabilityBoundingSet = "";
        };
    };

    # Suspend on lid close, except when docked (dock monitor holds the
    # inhibitor); swayidle's before-sleep hook handles locking (sway.nix)
    services.logind.settings.Login.HandleLidSwitch = "suspend";
    services.logind.settings.Login.HandleLidSwitchExternalPower = "suspend";
    services.logind.settings.Login.HandleLidSwitchDocked = "ignore";

    # Disable light sensors and accelerometers

    hardware.sensor.iio.enable = false;

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
  };
}
