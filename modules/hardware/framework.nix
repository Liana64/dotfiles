# @desc: Framework AMD AI 300 hardware module + firmware
{...}: {
  flake.modules.nixos.frameworkHardware = {
    inputs,
    pkgs,
    ...
  }: {
    imports = [
      inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
    ];

    # To get the latest firmware, run:
    # $ fwupdmgr refresh
    # $ fwupdmgr update
    services.fwupd.enable = true;

    # Exposes battery charge limit, privacy switches, and LEDs as driver interfaces
    hardware.framework.enableKmod = true;
    services.fprintd.enable = true;

    #security.pam.services.swaylock = {
    #  fprintAuth = true;
    #};

    services.hardware.bolt.enable = true;
    environment.systemPackages = with pkgs; [
      dmidecode # BIOS troubleshooting
      ethtool # Manage networking
      hdparm # Manage drives
      nvme-cli # Manage NVMes
      perf # Benchmarking
      sbctl # Sign our own EFI shim
      smartmontools # Check smart data on disks
      sysstat # Troubleshoot performance
      tcpdump # Troubleshoot networking
      inotify-tools # Use inotify
      lm_sensors # Temperature sensors
    ];

    boot.kernelParams = [
      "quiet"
      "splash"
      "udev.log_level=3"
      "rd.systemd.show_status=auto"
      "video=eDP-1:1920x1200"
    ];

    services.keyd = {
      enable = true;
      keyboards = {
        default = {
          ids = ["0001:0001:09b4e68d"];
          settings = {
            main = {
              "capslock" = "layer(control)";
            };
          };
        };
      };
    };

    # In case upstream ever changes
    systemd.services.keyd.serviceConfig = {
      PrivateNetwork = true;
      ProtectHome = true;
    };

    console = {
      font = "ter-v16n";
      packages = [pkgs.terminus_font];
    };

    # Keep boot console quiet so kernel/udev messages don't overwrite tuigreet
    boot.consoleLogLevel = 3;
    boot.initrd.verbose = false;
  };
}
