{
  config,
  inputs,
  lib,
  libvirt,
  ...
}: let
  inherit (inputs.self.network) pfsync;
  cfg = config.edge.opnsense;
  inherit (libvirt) mkVM media;
in {
  virtualisation.libvirt.connections."qemu:///system".domains = [
    (mkVM {
      name = "opnsense-${config.networking.hostName}";
      inherit (cfg) uuid memoryGiB;
      vcpus = 2;
      iso = media.opnsense;
      disks = [
        {
          zvol = "rpool/vms/opnsense-os";
          dev = "sda";
          boot = 1;
        }
      ];
      nics = [
        {
          bridge = "br0";
          mac = cfg.macs.lan;
          vlan = lib.range 2 4094;
          native = 1;
        }
        {
          bridge = "br-wan";
          mac = cfg.macs.wan;
        }
        {
          bridge = "br-tb";
          mac = cfg.macs.tb;
          vlan = pfsync.vlan;
        }
      ];
    })
  ];

  services.sanoid.datasets."rpool/vms/opnsense-os".useTemplate = ["daily"];
}
