{inputs, ...}: {
  imports = [
    inputs.disko.nixosModules.disko
    ../../modules/_lib/hypervisor.nix
    ./disko.nix
    ./network.nix
    ./vms.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    configurationLimit = 20;
    device = "nodev";
  };

  networking = {
    hostName = "n3";
    hostId = "04fb533a";
  };

  users.users.liana = {
    uid = 1000;
    extraGroups = ["libvirtd"];
    openssh.authorizedKeys.keys = (import ../../modules/_lib/keys.nix).liana;
  };

  services.prometheus.exporters.smartctl.devices = [
    "/dev/disk/by-id/nvme-KXG50ZNV256G_NVMe_TOSHIBA_256GB_58VB7DBLKAUP"
    "/dev/disk/by-id/ata-SPCC_Solid_State_Disk_AA000000000000004607"
  ];

  system.stateVersion = "26.05";
}
