{
  imports = [../_edge];

  networking = {
    hostName = "n2";
    hostId = "02541559";
  };

  environment.etc.machine-id.text = "c5ee4d3df9aa4ef490bf03b73520cb15\n";

  hypervisor.cpu = "intel";

  # 32G: 24 vm + 3 opnsense standby + ~1 qemu + 2 arc + ~2 host
  edge = {
    index = 2;
    disks = [
      "/dev/disk/by-id/nvme-WD_BLACK_SN770_2TB_244542800309"
      "/dev/disk/by-id/nvme-Viper_VP4300_2TB_VP4300DFBA2308016025"
    ];
    macs = {
      mgmt = "38:05:25:35:b7:e4";
      lan = "38:05:25:35:b7:e2";
      wan = "38:05:25:35:b7:e3";
    };
    arcMiB = 2048;
    opnsense = {
      uuid = "1726c688-7ef0-485f-b5b8-5d73cd49dae6";
      memoryGiB = 3;
      macs = {
        lan = "BC:24:11:70:7A:C3";
        wan = "BC:24:11:58:E3:5A";
        tb = "BC:24:11:80:4A:EF";
      };
    };
    talos = {
      uuid = "efd7776f-3f94-425d-bcb8-e2613708f4d1";
      vcpus = 14;
      poolSize = "1280G";
      macs = {
        lan = "BC:24:11:C7:0F:C6";
        tb = "BC:24:11:25:31:59";
      };
    };
  };

  system.stateVersion = "26.05";
}
