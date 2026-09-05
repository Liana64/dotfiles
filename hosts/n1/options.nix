{inputs, ...}: {
  imports = [
    inputs.disko.nixosModules.disko
    ../../modules/_lib/hypervisor.nix
    ./disko.nix
    ./network.nix
    ./vms.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  boot = {
    loader.grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
      configurationLimit = 20;
      device = "nodev";
    };
    blacklistedKernelModules = ["mt7921e"];
  };

  networking = {
    hostName = "n1";
    hostId = "a7260bc5";
  };

  users.users.liana = {
    uid = 1000;
    extraGroups = ["libvirtd"];
    openssh.authorizedKeys.keys = (import ../../modules/_lib/keys.nix).liana;
  };

  services.prometheus.exporters.smartctl.devices = [
    "/dev/disk/by-id/nvme-WD_Blue_SN580_250GB_24526N803348"
    "/dev/disk/by-id/nvme-WD_BLACK_SN770_1TB_241009808010"
  ];

  system.stateVersion = "26.05";
}
