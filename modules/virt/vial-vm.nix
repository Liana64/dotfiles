# @desc: Vial in a disposable microVM — Q11 USB passthrough, GUI via waypipe/vsock
{inputs, ...}: let
  cid = 33;
  port = 1234;
in {
  flake.modules.nixos.microvm-host = _: {
    microvm.vms.vial = {
      autostart = false;
      restartIfChanged = false;
      config = {
        pkgs,
        lib,
        ...
      }: {
        imports = [inputs.microvm.nixosModules.microvm];

        microvm = {
          hypervisor = "qemu";
          mem = 1024;
          vcpu = 2;
          vsock.cid = cid;
          shares = [
            {
              proto = "virtiofs";
              tag = "ro-store";
              source = "/nix/store";
              mountPoint = "/nix/.ro-store";
            }
          ];
          devices = [
            {
              bus = "usb";
              path = "vendorid=0x3434,productid=0x01E0";
            }
          ];
        };

        users.users.vial = {
          isNormalUser = true;
          group = "vial";
        };
        users.groups.vial = {};

        services.udev.extraRules = ''
          KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", GROUP="vial", MODE="0660"
        '';

        systemd.services.vial = {
          wantedBy = ["multi-user.target"];
          environment = {
            QT_QPA_PLATFORM = "wayland";
            XDG_RUNTIME_DIR = "/run/vial";
          };
          serviceConfig = {
            User = "vial";
            RuntimeDirectory = "vial";
            ExecStart = "${lib.getExe pkgs.waypipe} --vsock -s ${toString port} server -- ${lib.getExe pkgs.vial}";
            Restart = "always";
            RestartSec = 1;
          };
        };

        system.stateVersion = "26.05";
      };
    };
  };

  flake.modules.homeManager.vial-vm = {pkgs, ...}: {
    home.packages = [
      (pkgs.symlinkJoin {
        name = "vial-vm";
        paths = [(pkgs.writeShellScriptBin "vial-vm" (builtins.readFile ../bin/vial-vm))];
        buildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/vial-vm \
            --prefix PATH : ${pkgs.lib.makeBinPath [pkgs.waypipe]}
        '';
      })
    ];
  };
}
