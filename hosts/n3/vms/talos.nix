{libvirt, ...}: let
  inherit (libvirt) mkVM media;
in {
  virtualisation.libvirt.connections."qemu:///system".domains = [
    (mkVM {
      name = "talos-n3";
      uuid = "c4056b75-6e4d-4b4a-b83b-7c2b9c561702";
      vcpus = 4;
      memoryGiB = 6;
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
          mac = "BC:24:11:E9:CB:66";
          vlan = 10;
        }
      ];
    })
  ];
}
