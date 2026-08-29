# @desc: NFS v4 client + lazy automounts of the m1 exports under /mnt/m1
{...}: {
  flake.modules.nixos.nfsClient = let
    m1 = path: {
      device = "m1.milberry.org:/tank/${path}";
      fsType = "nfs4";
      options = ["noauto" "soft" "x-systemd.automount" "x-systemd.idle-timeout=600"];
    };
  in {
    boot.supportedFilesystems = ["nfs"];
    fileSystems = {
      "/mnt/m1/liana" = m1 "home/liana";
      "/mnt/m1/shared" = m1 "home/shared";
      "/mnt/m1/landfill" = m1 "home/shared/landfill";
      "/mnt/m1/media" = m1 "media";
    };
  };
}
