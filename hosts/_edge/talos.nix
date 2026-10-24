{
  config,
  libvirt,
  ...
}: let
  cfg = config.edge.talos;
  inherit (libvirt) mkVM media;
in {
  virtualisation.libvirt.connections."qemu:///system".domains = [
    (mkVM {
      name = "talos-${config.networking.hostName}";
      inherit (cfg) uuid vcpus;
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
          mac = cfg.macs.lan;
          vlan = 10;
        }
        {
          bridge = "br-tb";
          mac = cfg.macs.tb;
          vlan = 10;
        }
      ];
    })
  ];
}
