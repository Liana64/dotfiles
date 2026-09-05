# Headless ZFS hypervisor base: ssh, zfs health, zram, exporters, smartd.
# Not an aspect: desktop hosts import every aspect, so this stays in _lib
# and is imported explicitly by m1/n1/n2/n3.
{
  config,
  pkgs,
  ...
}: {
  boot = {
    supportedFilesystems = ["zfs"];
    zfs.devNodes = "/dev/disk/by-id";
    zfs.forceImportRoot = false;
  };

  hardware.cpu.intel.updateMicrocode = true;

  networking.firewall.interfaces.mgmt.allowedTCPPorts = [22 9100 9134 9633];

  # host anon pages only — vm ram is vfio-pinned, arc never swaps
  zramSwap = {
    enable = true;
    memoryPercent = 10;
  };

  environment.systemPackages = [pkgs.smartmontools];

  services = {
    openssh = {
      enable = true;
      openFirewall = false;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        PubkeyAuthOptions = "verify-required";
      };
    };
    zfs.autoScrub = {
      enable = true;
      interval = "monthly";
    };
    zfs.trim.enable = true;
    smartd.enable = true;
    prometheus.exporters = {
      node = {
        enable = true;
        extraFlags = ["--collector.textfile.directory=/var/lib/zfs-metrics"];
      };
      smartctl.enable = true;
      zfs.enable = true;
    };
  };

  systemd = {
    tmpfiles.rules = ["d /var/lib/zfs-metrics 0755 root root"];
    services.zfs-snapshot-metrics = {
      path = [config.boot.zfs.package pkgs.gawk];
      serviceConfig.Type = "oneshot";
      script = ''
        d=/var/lib/zfs-metrics
        {
          zfs list -Hpo name,used,usedbysnapshots -t filesystem
          echo ---
          zfs list -Hpo name,creation -t snapshot
        } | awk -F'\t' '
          /^---$/ {snap = 1; next}
          !snap {total[$1] = $2; used[$1] = $3; count[$1] = 0; next}
          {split($1, a, "@"); count[a[1]]++; if ($2 > latest[a[1]]) latest[a[1]] = $2}
          END {
            print "# HELP zfs_snapshot_count Snapshots per dataset."
            print "# TYPE zfs_snapshot_count gauge"
            for (ds in count) printf "zfs_snapshot_count{dataset=\"%s\"} %d\n", ds, count[ds]
            print "# HELP zfs_snapshot_latest_time_seconds Creation time of the newest snapshot."
            print "# TYPE zfs_snapshot_latest_time_seconds gauge"
            for (ds in latest) printf "zfs_snapshot_latest_time_seconds{dataset=\"%s\"} %d\n", ds, latest[ds]
            print "# HELP zfs_dataset_usedbysnapshots_bytes Space consumed by snapshots of the dataset."
            print "# TYPE zfs_dataset_usedbysnapshots_bytes gauge"
            for (ds in used) printf "zfs_dataset_usedbysnapshots_bytes{dataset=\"%s\"} %d\n", ds, used[ds]
            print "# HELP zfs_dataset_used_bytes Space used by the dataset, including its snapshots and children."
            print "# TYPE zfs_dataset_used_bytes gauge"
            for (ds in total) printf "zfs_dataset_used_bytes{dataset=\"%s\"} %d\n", ds, total[ds]
          }
        ' >$d/zfs-snapshots.prom.tmp
        mv $d/zfs-snapshots.prom.tmp $d/zfs-snapshots.prom
      '';
    };
    timers.zfs-snapshot-metrics = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "2min";
        OnUnitActiveSec = "15min";
      };
    };
  };
}
