{libvirt, ...}: let
  inherit (libvirt) mkVM iso;
in {
  virtualisation.libvirt.connections."qemu:///system".domains = [
    (mkVM {
      name = "talos-n1";
      uuid = "44960372-e9de-40e2-b1c3-0fd8799943a0";
      vcpus = 10;
      memoryGiB = 24;
      iso = iso.talos;
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
}
