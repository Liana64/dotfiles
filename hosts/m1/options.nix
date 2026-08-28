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
      mgmt.allowedTCPPorts = [22 2049 9100 9134 9633];
      home.allowedTCPPorts = [22 2049];
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
      openssh.authorizedKeys.keys = [(import ../../modules/_lib/keys.nix).liana];
    };
    maxine = {
      isNormalUser = true;
      uid = 1001;
      extraGroups = ["media" "documents"];
      openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDIH1DudmoKZzEukU5A0ZTc5lmFl2ZARgXwejLG0oLkIKLF8I3pMVtauKDkjd5lA5zHLZ0dsyl0GjSVNP0JMfV0su2Db8DGajjfFSHuaUc70WoMCAQfspsOlnyrjNsKaB4CQJVVVaIHgJPJglQ1yQm7uJSLawyePZ3Nh3A+sCzLnlsT6W3hLJvQcEEznYiLUrAfrs5H9PIGUe7x301BijQLtv3ZqocoeiBO2v//iCcZ07PrpUZE8boBT8v5tj9vwM0TrtQI3TKlsa2F+9BXq7pgHHLdS+LmAi5R3aLDGf5y73SUaXPCQxDmm0m2HRF2VnJF9H6yTApswBxLqvQ/KMw+6OfHJ3bRbXnhnC/n2K20P3xi083bwexbEHRG4Gd4U1qbW/2jk002R6V2AE351wsEaBfmPLM+70sgIWTWtx8FbJOYlRBhpVooaXO7aHvuyGDySPcYFAanj0NRj6bBuLa1Uou/yEXQaUb6tov/ADDWmZLF/6Wnes8hRf0ws+7XBj0= maxine@frame"];
    };
  };

  system.stateVersion = "26.05";
}
