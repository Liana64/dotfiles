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
    paths = ["/tank/home"];
    exclude = ["/tank/home/shared/landfill"];
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
