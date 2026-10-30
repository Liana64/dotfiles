{
  config,
  inputs,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.edge;
  vm = extra:
    {
      uuid = mkOption {type = types.str;};
      macs = mkOption {type = types.attrsOf types.str;};
    }
    // extra;
in {
  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./network.nix
    ./opnsense.nix
    ./talos.nix
  ];

  options.edge = {
    index = mkOption {type = types.ints.between 1 9;};
    disks = mkOption {type = types.listOf types.str;};
    macs = mkOption {type = types.attrsOf types.str;};
    memoryGiB = mkOption {type = types.ints.positive;};
    arcMiB = mkOption {type = types.ints.positive;};
    opnsense = vm {memoryGiB = mkOption {type = types.ints.positive;};};
    talos = vm {
      vcpus = mkOption {type = types.ints.positive;};
      poolSize = mkOption {type = types.str;};
    };
  };

  config = {
    motd.description = "edge hypervisor: OPNsense and Talos";

    nixpkgs.hostPlatform = "x86_64-linux";

    boot = {
      loader.grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        configurationLimit = 20;
        mirroredBoots = lib.genList (i: {
          devices = ["nodev"];
          path = "/boot${toString i}";
          efiSysMountPoint = "/boot${toString i}";
        }) (lib.length cfg.disks);
      };
      kernelParams = ["zfs.zfs_arc_max=${toString (cfg.arcMiB * 1024 * 1024)}"];
      blacklistedKernelModules = ["mt7921e"];
    };

    users.users.liana = {
      uid = 1000;
      openssh.authorizedKeys.keys = inputs.self.keys.liana;
    };

    services.prometheus.exporters.smartctl.devices = cfg.disks;

    # talos-pool unsnapshotted: pool slack cannot absorb qbt churn deltas
    services.sanoid.datasets = lib.genAttrs ["rpool/var" "rpool/vms/talos-os"] (_: {useTemplate = ["daily"];});
  };
}
