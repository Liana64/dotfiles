{config, ...}: {
  sops.secrets = {
    "backup/restic-repo" = {};
    "backup/restic-password" = {};
    "backup/restic-env" = {};
  };

  services.restic.backups.tank = {
    repositoryFile = config.sops.secrets."backup/restic-repo".path;
    passwordFile = config.sops.secrets."backup/restic-password".path;
    environmentFile = config.sops.secrets."backup/restic-env".path;
    initialize = true;
    paths = [
      "/tank/home"
      "/tank/backups"
    ];
    exclude = [
      "/tank/home/shared/landfill"
      "/tank/backups/framework"
      "/tank/backups/volsync"
    ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
    pruneOpts = [
      "--keep-daily 30"
      "--keep-monthly 6"
    ];
    runCheck = true;
    checkOpts = ["--read-data-subset=1G"];
  };
}
