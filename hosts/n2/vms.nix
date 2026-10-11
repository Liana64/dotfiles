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

  # 32G budget: 24 vm + 3 opnsense standby + ~1 qemu + 2 arc + ~2 host
  boot.kernelParams = ["zfs.zfs_arc_max=${toString (2 * 1024 * 1024 * 1024)}"];

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
        name = "talos-n2";
        uuid = "efd7776f-3f94-425d-bcb8-e2613708f4d1";
        vcpus = 14;
        memoryGiB = 24;
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
            mac = "BC:24:11:C7:0F:C6";
            vlan = 10;
          }
          {
            bridge = "br-tb";
            mac = "BC:24:11:25:31:59";
            vlan = 10;
          }
        ];
      })
    ];
  };

  services.sanoid = {
    enable = true;
    datasets = lib.genAttrs ["rpool/var" "rpool/vms/talos-os" "rpool/vms/opnsense-os"] (_: {
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
