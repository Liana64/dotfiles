# @desc: Vial keyboard editor (source-built, housed in tools) + QMK/Vial device access
{...}: let
  vial-gui = pkgs: pkgs.callPackage ../_pkgs/vial-gui/package.nix {udev = import ../_lib/udev-chase.nix pkgs;};
in {
  flake.modules.nixos.keyboard = {pkgs, ...}: {
    services.udev.packages = [
      pkgs.qmk-udev-rules

      # Scoped to the vial serial magic (upstream is 0666 on every hidraw); must sort before 73-seat-late.rules or uaccess never applies — extraRules lands at 99.
      (pkgs.writeTextDir "lib/udev/rules.d/70-vial.rules" ''
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", TAG+="uaccess", SYMLINK+="vial-%k"
      '')
    ];
  };

  perSystem = {pkgs, ...}: {
    packages.vial-gui = vial-gui pkgs;
  };

  flake.modules.homeManager.keyboard = {pkgs, ...}: {
    home.packages = [(vial-gui pkgs)];

    xdg.desktopEntries.vial = {
      name = "Vial";
      exec = "vial-gui";
      categories = ["Utility"];
    };
  };
}
