# @desc: NFS v4 client + lazy automounts of m1 exports under /mnt/m1
{...}: {
  flake.modules.nixos.nfsClient = let
    tank = path: extra: {
      device = "home.storage.milberry.org:/tank/${path}";
      fsType = "nfs4";
      options = ["noauto" "soft" "timeo=30" "retrans=2" "retry=0" "x-systemd.automount" "x-systemd.mount-timeout=15s"] ++ extra;
    };
  in {
    boot.supportedFilesystems = ["nfs"];
    fileSystems = {
      "/mnt/m1/liana" = tank "users/stash/liana" [];
      "/mnt/m1/shared" = tank "users/stash/shared" [];
      "/mnt/m1/landfill" = tank "users/stash/shared/landfill" [];
      "/mnt/m1/photos" = tank "cluster/photos" ["ro"];
      "/mnt/m1/uploads" = tank "cluster/uploads" [];
      "/mnt/m1/media" = tank "cluster/media" [];
    };

    users.groups = {
      media.gid = 2000;
      documents.gid = 2100;
      uploads.gid = 2300;
    };
    users.users.liana.extraGroups = ["media" "documents" "uploads"];
  };
}
