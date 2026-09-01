# @desc: home-infra devcontainer microVM — $PWD shared read-only at /work, ssh over vsock
{inputs, ...}: let
  cid = 34;
  guestBase = import ../_lib/microvm-guest.nix {inherit inputs;};
in {
  flake.modules.nixos.microvm-host = _: {
    systemd.tmpfiles.rules = ["d /run/dev-vm/src 0755 root root -"];

    microvm.vms.dev = {
      autostart = false;
      restartIfChanged = false;
      config = {pkgs, ...}: {
        imports = [guestBase];

        microvm = {
          hypervisor = "qemu";
          mem = 4096;
          vcpu = 4;
          vsock = {
            inherit cid;
            ssh.enable = true;
          };
          interfaces = [
            {
              type = "user";
              id = "dev0";
              mac = "02:00:00:00:de:01";
            }
          ];
          shares = [
            {
              proto = "virtiofs";
              tag = "ro-store";
              source = "/nix/store";
              mountPoint = "/nix/.ro-store";
            }
            {
              proto = "virtiofs";
              tag = "work";
              source = "/run/dev-vm/src";
              mountPoint = "/work";
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
            --prefix PATH : ${pkgs.lib.makeBinPath [pkgs.socat]}:${pkgs.systemd}/lib/systemd
        '';
      })
    ];
  };
}
