{libvirt, ...}: let
  inherit (libvirt) mkVM;
in {
  virtualisation.libvirt.connections."qemu:///system".domains = [
    (mkVM {
      name = "opnsense-n2";
      uuid = "1726c688-7ef0-485f-b5b8-5d73cd49dae6";
      vcpus = 2;
      memoryGiB = 3;
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
