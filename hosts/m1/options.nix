{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./attic.nix
    ./backup.nix
    ./builder.nix
    ./disko.nix
    ./ganesha.nix
    ./network.nix
    ./seaweedfs.nix
    ./storage.nix
    ./syncthing.nix
    ./vms.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  hypervisor.cpu = "intel";

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
    # kernelParams "vfio-pci.ids=10de:1b80,10de:10f0" (GTX 1080 at 02:00.0, 02:00.1)
    #initrd.kernelModules = ["vfio_pci" "vfio" "vfio_iommu_type1"];
    blacklistedKernelModules = ["nouveau" "iwlwifi"];
  };

  motd.description = "NAS and Talos hypervisor";

  networking = {
    hostName = "m1";
    hostId = "c0ff6d31";
    firewall.interfaces = {
      # TODO: tighten perms once new oob is deployed
      cluster.allowedTCPPorts = [2049 9100 9134 9633];
      hstore.allowedTCPPorts = [2049];
    };
  };

  users.users = {
    liana = {
      uid = 1000;
      extraGroups = ["media" "documents"];
      openssh.authorizedKeys.keys = inputs.self.keys.liana;
    };
    maxine = {
      isNormalUser = true;
      uid = 1001;
      extraGroups = ["media" "documents"];
      hashedPasswordFile = config.sops.secrets."users/maxine/password".path;
      openssh.authorizedKeys.keys = [inputs.self.keys.maxine];
    };
  };
  sops.secrets."users/maxine/password".neededForUsers = true;

  system.stateVersion = "26.05";
}
