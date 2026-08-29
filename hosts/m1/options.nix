{inputs, ...}: let
  gpuIds = "10de:1b80,10de:10f0"; # 02:00.0, 02:00.1
in {
  imports = [
    inputs.disko.nixosModules.disko
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
    supportedFilesystems = ["zfs"];
    zfs.devNodes = "/dev/disk/by-id";
    zfs.forceImportRoot = false;
    kernelParams = ["intel_iommu=on" "iommu=pt" "vfio-pci.ids=${gpuIds}"];
    initrd.kernelModules = ["vfio_pci" "vfio" "vfio_iommu_type1"];
    blacklistedKernelModules = ["nouveau"];
  };

  networking = {
    hostName = "m1";
    hostId = "c0ff6d31";
    firewall.interfaces = {
      cluster.allowedTCPPorts = [2049 9100 9134 9633];
      mgmt.allowedTCPPorts = [22 9100 9134 9633];
    };
  };

  hardware.cpu.intel.updateMicrocode = true;

  # host anon pages only — vm ram is vfio-pinned, arc never swaps
  zramSwap = {
    enable = true;
    memoryPercent = 10;
  };

  services = {
    openssh = {
      enable = true;
      openFirewall = false;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        PubkeyAuthOptions = "verify-required";
      };
    };
    zfs.autoScrub = {
      enable = true;
      interval = "monthly";
    };
    zfs.trim.enable = true;
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
