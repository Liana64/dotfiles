{
  config,
  inputs,
  pkgs,
  hardening,
  ...
}: let
  net = inputs.self.network;
  addr = net.cluster.hosts.m1;
  port = net.cluster.atticPort;
  store = "/tank/cluster/nix-cache";
in {
  motd.commands = [["sudo atticd-atticadm make-token --sub <name> --validity 30d --pull <cache>" "attic token"]];

  sops = {
    secrets."attic/token-rs256" = {};
    templates."atticd.env" = {
      restartUnits = ["atticd.service"];
      content = ''
        ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64=${config.sops.placeholder."attic/token-rs256"}
      '';
    };
  };

  services.atticd = {
    enable = true;
    environmentFile = config.sops.templates."atticd.env".path;
    settings = {
      listen = "${addr}:${toString port}";
      api-endpoint = "http://${addr}:${toString port}/";
      storage = {
        type = "local";
        path = store;
      };
      garbage-collection.default-retention-period = "3 months";
    };
  };

  services.prometheus.exporters.node.extraFlags = ["--collector.textfile.directory=/run/attic-metrics"];

  systemd = {
    services.attic-metrics = {
      after = ["atticd.service"];
      path = [pkgs.sqlite pkgs.gawk];
      serviceConfig =
        hardening.sealed
        // {
          Type = "oneshot";
          DynamicUser = true;
          TemporaryFileSystem = ["/var:ro" "/tank:ro"];
          BindReadOnlyPaths = "/var/lib/private/atticd:/var/lib/attic-db";
          RuntimeDirectory = "attic-metrics";
          RuntimeDirectoryMode = "0755";
          RuntimeDirectoryPreserve = true;
          UMask = "0022";
          MemoryMax = "128M";
          TasksMax = 8;
          RuntimeMaxSec = "1min";
        };
      script = ''
        d=$RUNTIME_DIRECTORY
        q="FROM object o JOIN cache c ON c.id = o.cache_id JOIN nar n ON n.id = o.nar_id WHERE c.name = '${net.cluster.atticCache}'"
        sqlite3 -readonly -separator ' ' /var/lib/attic-db/server.db "
          SELECT 'total', count(*), coalesce(sum(n.nar_size), 0), coalesce(max(strftime('%s', o.created_at)), 0) $q;
          SELECT 'system', o.store_path, strftime('%s', o.created_at) $q AND o.store_path LIKE '%-nixos-system-%';
        " | awk -v cache=${net.cluster.atticCache} '
          $1 == "total" {n = $2; bytes = $3; last = $4; next}
          {h = $2; sub(/.*-nixos-system-/, "", h); sub(/-[0-9]+\.[0-9]+\..*$/, "", h); if ($3 > sys[h]) sys[h] = $3}
          END {
            print "# HELP attic_objects Store paths in the cache."
            print "# TYPE attic_objects gauge"
            printf "attic_objects{cache=\"%s\"} %d\n", cache, n
            print "# HELP attic_nar_size_bytes Uncompressed NAR size of all store paths in the cache."
            print "# TYPE attic_nar_size_bytes gauge"
            printf "attic_nar_size_bytes{cache=\"%s\"} %d\n", cache, bytes
            print "# HELP attic_last_push_time_seconds Time the newest store path was pushed."
            print "# TYPE attic_last_push_time_seconds gauge"
            printf "attic_last_push_time_seconds{cache=\"%s\"} %d\n", cache, last
            print "# HELP attic_system_last_push_time_seconds Time the newest NixOS system of a machine was pushed."
            print "# TYPE attic_system_last_push_time_seconds gauge"
            for (h in sys) printf "attic_system_last_push_time_seconds{cache=\"%s\",machine=\"%s\"} %d\n", cache, h, sys[h]
          }
        ' >$d/attic.prom.tmp
        mv $d/attic.prom.tmp $d/attic.prom
      '';
    };

    timers.attic-metrics = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "2min";
        OnUnitActiveSec = "5min";
      };
    };

    services.atticd = {
      requires = ["zfs-datasets.service"];
      after = ["zfs-datasets.service"];
      serviceConfig = {
        IPAddressDeny = "any";
        IPAddressAllow =
          [addr net.mgmt.subnet net.home.hosts.catbox net.offsite.hosts.offsite-1 net.offsite.hosts.framework]
          ++ net.cluster.nodes
          ++ net.clients.liana;
        SocketBindAllow = "tcp:${toString port}";
        SocketBindDeny = "any";
        PrivateIPC = true;
        TemporaryFileSystem = "/tank";
        BindPaths = store;
        MemoryMax = "4G";
        TasksMax = 256;
        CPUWeight = 50;
        IOWeight = 50;
      };
    };
  };

  networking.firewall.interfaces.cluster.allowedTCPPorts = [port];
}
