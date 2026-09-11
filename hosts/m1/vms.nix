{
  inputs,
  pkgs,
  lib,
  ...
}: let
  inherit (import ../../modules/_lib/talos-vm.nix {inherit pkgs lib;}) mkTalosVM talosISO;
in {
  imports = [inputs.nixvirt.nixosModules.default];

  virtualisation.libvirtd = {
    qemu.runAsRoot = false;
    onBoot = "ignore";
    onShutdown = "shutdown";
  };

  virtualisation.libvirt = {
    enable = true;
    swtpm.enable = true;
    connections."qemu:///system".domains = [
      (mkTalosVM {
        name = "talos-nas";
        uuid = "c0ff6d31-0000-4000-8000-000000000014";
        vcpus = 6;
        memoryGiB = 40;
        iso = talosISO;
        disks = [
          {
            zvol = "rpool/vms/talos-os";
            dev = "sda";
            boot = 1;
          }
          {
            zvol = "rpool/vms/talos-pool";
            dev = "sdb";
          }
        ];
        nics = [
          {
            bridge = "br0";
            mac = "52:54:00:c0:fe:14";
            vlan = 10;
          }
        ];
      })
    ];
  };
}
