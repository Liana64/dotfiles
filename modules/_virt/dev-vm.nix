# @desc: home-infra devcontainer microVM — firecracker, $PWD as erofs volume at /work, ssh over vsock-mux
{inputs, ...}: let
  cid = 34;
  guestBase = import ../_lib/microvm-guest.nix {inherit inputs;};
in {
  flake.modules.nixos.microvm-host = _: {
    systemd.tmpfiles.rules = ["d /run/dev-vm 0755 root root -"];

    users.users.liana.extraGroups = ["kvm"];

    networking.networkmanager.ensureProfiles.profiles.dev-vm = {
      connection = {
        id = "dev-vm";
        type = "tun";
        interface-name = "dev0";
        autoconnect = false;
      };
      tun.mode = 2;
      ipv4.method = "shared";
      ipv6.method = "disabled";
    };

    systemd.services."microvm@dev" = {
      overrideStrategy = "asDropin";
      serviceConfig = {
        MemoryDenyWriteExecute = true;
        SystemCallFilter = ["~@resources"];
        UMask = "0007";
        MemoryMax = "5G";
        TasksMax = 64;
      };
    };

    microvm.vms.dev = {
      autostart = false;
      restartIfChanged = false;
      config = {pkgs, ...}: {
        imports = [guestBase];

        microvm = {
          hypervisor = "firecracker";
          mem = 4096;
          vcpu = 4;
          vsock = {
            inherit cid;
            ssh.enable = true;
          };
          interfaces = [
            {
              type = "tap";
              id = "dev0";
              mac = "02:00:00:00:de:01";
            }
          ];
          volumes = [
            {
              image = "/run/dev-vm/work.img";
              label = "work";
              mountPoint = "/work";
              fsType = "erofs";
              readOnly = true;
              autoCreate = false;
              size = 0;
            }
          ];
        };

        networking.hostName = "dev";

        users.users.dev = {
          isNormalUser = true;
          uid = 1000;
          extraGroups = ["wheel"];
          openssh.authorizedKeys.keys = (import ../_lib/keys.nix).liana;
        };
        security.sudo.wheelNeedsPassword = false;

        environment.systemPackages =
          [pkgs.git]
          ++ import ../_lib/infra-tools.nix {
            inherit pkgs;
            unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
          };
      };
    };
  };

  flake.modules.homeManager.dev-vm = {pkgs, ...}: {
    home.packages = [
      (pkgs.symlinkJoin {
        name = "dev-vm";
        paths = [(pkgs.writeShellScriptBin "dev-vm" (builtins.readFile ../bin/dev-vm))];
        buildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/dev-vm \
            --prefix PATH : ${pkgs.lib.makeBinPath [pkgs.socat pkgs.erofs-utils pkgs.gnugrep pkgs.networkmanager]}:${pkgs.systemd}/lib/systemd
        '';
      })
    ];
  };
}
