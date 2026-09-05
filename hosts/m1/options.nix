{inputs, ...}: let
  gpuIds = "10de:1b80,10de:10f0"; # 02:00.0, 02:00.1
in {
  imports = [
    inputs.disko.nixosModules.disko
    ../../modules/_lib/hypervisor.nix
    ./backup.nix
    ./disko.nix
    ./network.nix
    ./secrets.nix
    ./storage.nix
    ./vms.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  boot = {
    # grub until lanzaboote lands for host secure boot
    loader.grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
      configurationLimit = 20;
      mirroredBoots = [
        {
          devices = ["nodev"];
          path = "/boot0";
          efiSysMountPoint = "/boot0";
        }
        {
          devices = ["nodev"];
          path = "/boot1";
          efiSysMountPoint = "/boot1";
        }
      ];
    };
    kernelParams = ["intel_iommu=on" "iommu=pt" "vfio-pci.ids=${gpuIds}"];
    initrd.kernelModules = ["vfio_pci" "vfio" "vfio_iommu_type1"];
    blacklistedKernelModules = ["nouveau" "iwlwifi"];
  };

  networking = {
    hostName = "m1";
    hostId = "c0ff6d31";
    firewall.interfaces.cluster.allowedTCPPorts = [22 2049 9100 9134 9633];
  };

  users.users = {
    liana = {
      uid = 1000;
      extraGroups = ["libvirtd" "media" "documents"];
      openssh.authorizedKeys.keys = (import ../../modules/_lib/keys.nix).liana;
    };
    maxine = {
      isNormalUser = true;
      uid = 1001;
      extraGroups = ["media" "documents"];
      openssh.authorizedKeys.keys = [(import ../../modules/_lib/keys.nix).maxine];
    };
  };

  system.stateVersion = "26.05";
}
