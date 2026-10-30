{
  imports = [../_edge];

  networking = {
    hostName = "n1";
    hostId = "a7260bc5";
  };

  environment.etc.machine-id.text = "d315451707bd20f7c70072788c4d81e0\n";

  hypervisor.cpu = "intel";

  # ~900G usable: 640 leaves ~35G for root/nix/var + talos-os snapshots
  edge = {
    index = 1;
    memoryGiB = 32;
    disks = [
      "/dev/disk/by-id/nvme-WD_BLACK_SN770_1TB_241009808010"
      "/dev/disk/by-id/nvme-WD_Blue_SN5100_1TB_25423W804321"
    ];
    macs = {
      mgmt = "58:47:ca:7a:e3:f4";
      lan = "58:47:ca:7a:e3:f2";
      wan = "58:47:ca:7a:e3:f3";
    };
    arcMiB = 1536;
    opnsense = {
      uuid = "1209e9fd-69cf-467c-a870-c249a4f5009b";
      memoryGiB = 4;
      macs = {
        lan = "BC:24:11:C4:32:01";
        tb = "BC:24:11:B6:7B:20";
      };
    };
    talos = {
      uuid = "44960372-e9de-40e2-b1c3-0fd8799943a0";
      vcpus = 10;
      poolSize = "640G";
      macs = {
        lan = "BC:24:11:15:69:CB";
        tb = "BC:24:11:0D:E4:26";
      };
    };
  };

  system.stateVersion = "26.05";
}
