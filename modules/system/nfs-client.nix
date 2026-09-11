# @desc: NFS v4 client + lazy automounts of m1 exports under /mnt/m1
{...}: {
  flake.modules.nixos.nfsClient = let
    homeStorage = path: extra: {
      device = "home.storage.milberry.org:/tank/${path}";
      fsType = "nfs4";
      options = ["noauto" "soft" "x-systemd.automount" "x-systemd.idle-timeout=600"] ++ extra;
    };
  in {
    boot.supportedFilesystems = ["nfs"];
    fileSystems = {
      "/mnt/m1/liana" = homeStorage "home/liana" [];
      "/mnt/m1/shared" = homeStorage "home/shared" [];
      "/mnt/m1/landfill" = homeStorage "home/shared/landfill" [];
      "/mnt/m1/photos" = homeStorage "home/photos" ["ro"];
      "/mnt/m1/media" = homeStorage "media" [];
    };

    users.groups = {
      media.gid = 2000;
      documents.gid = 2100;
    };
    users.users.liana.extraGroups = ["media" "documents"];
  };
}
