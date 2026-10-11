{
  inputs,
  pkgs,
  lib,
  hardening,
  ...
}: let
  inherit (import ../../modules/_lib/talos-vm.nix {inherit pkgs lib;}) mkTalosVM talosISO;
in {
  imports = [inputs.nixvirt.nixosModules.default];

  # 16G budget: 6 vm + 6 lab (3×2G) + ~1 qemu + 1 arc + ~1 host
  boot.kernelParams = ["zfs.zfs_arc_max=${toString (1024 * 1024 * 1024)}"];

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
        name = "talos-n3";
        uuid = "c4056b75-6e4d-4b4a-b83b-7c2b9c561702";
        vcpus = 4;
        memoryGiB = 6;
        iso = talosISO;
        disks = [
          {
            zvol = "rpool/vms/talos-os";
            dev = "sda";
            boot = 1;
          }
          {
            zvol = "vms/talos-pool";
            dev = "sdb";
          }
        ];
        nics = [
          {
            bridge = "br0";
            mac = "BC:24:11:E9:CB:66";
            vlan = 10;
          }
        ];
      })
    ];
  };

  services.sanoid = {
    enable = true;
    datasets = lib.genAttrs ["rpool/var" "rpool/vms/talos-os"] (_: {
      autosnap = true;
      autoprune = true;
      hourly = 0;
      daily = 7;
      monthly = 0;
    });
  };

  systemd.services.sanoid.serviceConfig =
    hardening.confined
    // {
      PrivateDevices = false;
      RestrictAddressFamilies = ["AF_UNIX" "AF_NETLINK"];
      IPAddressDeny = "any";
    };
}
