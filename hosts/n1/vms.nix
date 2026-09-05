{
  inputs,
  pkgs,
  lib,
  ...
}: let
  inherit (import ../../modules/_lib/talos-vm.nix {inherit pkgs lib;}) mkTalosVM talosISO;
in {
  imports = [inputs.nixvirt.nixosModules.default];

  # 32G budget: 24 vm + 4 opnsense (phase 3) + ~1 qemu + 1.5 arc + ~1.5 host
  boot.kernelParams = ["zfs.zfs_arc_max=${toString (1536 * 1024 * 1024)}"];

  virtualisation.libvirtd.qemu.runAsRoot = false;

  virtualisation.libvirt = {
    enable = true;
    swtpm.enable = true;
    connections."qemu:///system".domains = [
      (mkTalosVM {
        name = "talos-n1";
        uuid = "44960372-e9de-40e2-b1c3-0fd8799943a0";
        vcpus = 10;
        memoryGiB = 24;
        iso = talosISO;
        disks = [
          {
            zvol = "vms/talos-os";
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
            mac = "BC:24:11:15:69:CB";
            vlan = 10;
          }
          {
            bridge = "br-tb";
            mac = "BC:24:11:0D:E4:26";
            vlan = 10;
          }
        ];
      })
    ];
  };

  services.sanoid = {
    enable = true;
    # talos-pool unsnapshotted: ~35G pool slack cannot absorb qbt churn deltas
    datasets."vms/talos-os" = {
      autosnap = true;
      autoprune = true;
      hourly = 0;
      daily = 7;
      monthly = 0;
    };
  };
}
