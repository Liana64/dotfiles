# @desc: Vial keyboard editor + QMK/Vial device access
{...}: {
  flake.modules.nixos.keyboard = {pkgs, ...}: {
    services.udev = {
      packages = [pkgs.qmk-udev-rules];

      # Not pkgs.vial: its 92-viia.rules puts MODE="0666" on every hidraw node.
      extraRules = ''
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", TAG+="uaccess"
      '';
    };
  };

  flake.modules.homeManager.keyboard = {pkgs, ...}: {
    home.packages = [pkgs.vial];
  };
}
