{libvirt, ...}: let
  inherit (libvirt) mkVM;
in {
  virtualisation.libvirt.connections."qemu:///system".domains = [
    (mkVM {
      name = "opnsense-n1";
      uuid = "1209e9fd-69cf-467c-a870-c249a4f5009b";
      vcpus = 2;
      memoryGiB = 4;
      active = null;
      disks = [
        {
          zvol = "rpool/vms/opnsense-os";
          dev = "sda";
          boot = 1;
        }
      ];
      nics = [];
    })
  ];

  services.sanoid.datasets."rpool/vms/opnsense-os".useTemplate = ["daily"];
}
