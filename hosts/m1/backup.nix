{
  config,
  pkgs,
  ...
}: let
  hardening = import ../../modules/_lib/systemd-hardening.nix;
  tank = config.services.restic.backups.tank;
  restic = "${tank.package}/bin/restic --repository-file ${tank.repositoryFile} --password-file ${tank.passwordFile} --no-lock --json";
in {
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

  systemd = {
    services = {
      restic-metrics = {
        path = [pkgs.jq];
        serviceConfig =
          hardening.confined
          // {
            Type = "oneshot";
            EnvironmentFile = tank.environmentFile;
            Environment = "RESTIC_CACHE_DIR=/var/cache/restic-metrics";
            CacheDirectory = "restic-metrics";
            CapabilityBoundingSet = "";
            ReadWritePaths = ["/var/lib/zfs-metrics"];
            RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6"];
            UMask = "0022";
          };
        script = ''
          d=/var/lib/zfs-metrics
          snaps=$(${restic} snapshots)
          size=$(${restic} stats --mode raw-data | jq -e .total_size)
          count=$(jq length <<<"$snaps")
          latest=$(date -d "$(jq -er 'map(.time) | max' <<<"$snaps")" +%s)
          {
            echo "# HELP restic_snapshot_count Snapshots in the repository."
            echo "# TYPE restic_snapshot_count gauge"
            echo "restic_snapshot_count $count"
            echo "# HELP restic_latest_snapshot_time_seconds Creation time of the newest snapshot."
            echo "# TYPE restic_latest_snapshot_time_seconds gauge"
            echo "restic_latest_snapshot_time_seconds $latest"
            echo "# HELP restic_repo_size_bytes Raw size of the repository data."
            echo "# TYPE restic_repo_size_bytes gauge"
            echo "restic_repo_size_bytes $size"
          } >$d/restic.prom.tmp
          mv $d/restic.prom.tmp $d/restic.prom
        '';
      };
      restic-backups-tank = {
        unitConfig.OnSuccess = ["restic-metrics.service"];
        serviceConfig =
          removeAttrs hardening.confined ["PrivateTmp"]
          // {
            CapabilityBoundingSet = "CAP_DAC_READ_SEARCH";
            RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6"];
          };
      };
    };
    timers.restic-metrics = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "10min";
        OnUnitActiveSec = "6h";
      };
    };
  };
}
