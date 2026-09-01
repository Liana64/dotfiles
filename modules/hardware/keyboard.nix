# @desc: Vial keyboard editor (source-built, bwrap-jailed) + QMK/Vial device access
{...}: {
  flake.modules.nixos.keyboard = {pkgs, ...}: {
    services.udev.packages = [
      pkgs.qmk-udev-rules

      # Scoped to the vial serial magic (upstream is 0666 on every hidraw); must sort before 73-seat-late.rules or uaccess never applies — extraRules lands at 99.
      (pkgs.writeTextDir "lib/udev/rules.d/70-vial.rules" ''
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", TAG+="uaccess"
      '')
    ];
  };

  perSystem = {pkgs, ...}: {
    packages.vial-gui = pkgs.callPackage ../_pkgs/vial-gui/package.nix {};
  };

  flake.modules.homeManager.keyboard = {pkgs, ...}: let
    vial-gui = pkgs.callPackage ../_pkgs/vial-gui/package.nix {};
  in {
    home.packages = [
      (pkgs.symlinkJoin {
        name = "vial";
        paths = [(pkgs.writeShellScriptBin "vial" (builtins.readFile ../bin/vial))];
        buildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/vial \
            --prefix PATH : ${pkgs.lib.makeBinPath [pkgs.bubblewrap vial-gui]}
        '';
      })
    ];

    xdg.desktopEntries.vial = {
      name = "Vial";
      exec = "vial";
      categories = ["Utility"];
    };
  };
}
