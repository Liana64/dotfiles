{inputs, ...}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./network.nix
    ./secrets.nix
    ./vms
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  hypervisor.cpu = "intel";

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    configurationLimit = 20;
    device = "nodev";
  };

  environment.etc.machine-id.text = "71cbeb322d1c4f5ca317bd0a88e400f5\n";

  networking = {
    hostName = "n3";
    hostId = "04fb533a";
  };

  users.users.liana = {
    uid = 1000;
    openssh.authorizedKeys.keys = inputs.self.keys.liana;
  };

  services.prometheus.exporters.smartctl.devices = [
    "/dev/disk/by-id/nvme-KXG50ZNV256G_NVMe_TOSHIBA_256GB_58VB7DBLKAUP"
    "/dev/disk/by-id/ata-SPCC_Solid_State_Disk_AA000000000000004607"
  ];

  system.stateVersion = "26.05";
}
