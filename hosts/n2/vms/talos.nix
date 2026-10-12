{libvirt, ...}: let
  inherit (libvirt) mkVM media;
in {
  virtualisation.libvirt.connections."qemu:///system".domains = [
    (mkVM {
      name = "talos-n2";
      uuid = "efd7776f-3f94-425d-bcb8-e2613708f4d1";
      vcpus = 14;
      memoryGiB = 24;
      iso = media.talos;
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
}
