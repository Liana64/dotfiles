{libvirt, ...}: let
  inherit (libvirt) mkVM media;
in {
  virtualisation.libvirt.connections."qemu:///system".domains = [
    (mkVM {
      name = "talos-nas";
      uuid = "c0ff6d31-0000-4000-8000-000000000014";
      vcpus = 6;
      memoryGiB = 40;
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
          mac = "52:54:00:c0:fe:14";
          vlan = 10;
        }
        {
          bridge = "br0";
          mac = "52:54:00:c0:fe:15";
          vlan = 140;
        }
      ];
    })
  ];
}
