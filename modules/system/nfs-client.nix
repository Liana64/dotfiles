# @desc: NFS v4 client + lazy automounts of the m1 exports under /mnt/m1
{...}: {
  flake.modules.nixos.nfsClient = let
    m1 = path: extra: {
      device = "m1.milberry.org:/tank/${path}";
      fsType = "nfs4";
      options = ["noauto" "soft" "x-systemd.automount" "x-systemd.idle-timeout=600"] ++ extra;
    };
  in {
    boot.supportedFilesystems = ["nfs"];
    fileSystems = {
      "/mnt/m1/liana" = m1 "home/liana" [];
      "/mnt/m1/shared" = m1 "home/shared" [];
      "/mnt/m1/landfill" = m1 "home/shared/landfill" [];
      "/mnt/m1/photos" = m1 "home/photos" ["ro"];
      "/mnt/m1/media" = m1 "media" [];
    };

    # gids must mirror m1 storage.nix ids — AUTH_SYS gid match gates writes
    users.groups = {
      media.gid = 2000;
      documents.gid = 2100;
    };
    users.users.liana.extraGroups = ["media" "documents"];
  };
}
