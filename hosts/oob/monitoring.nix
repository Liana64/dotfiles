{config, ...}: {
  sops.secrets."grafana/admin-password".owner = "grafana";

  networking.firewall.allowedTCPPorts = [3000];

  services = {
    prometheus = {
      enable = true;
      listenAddress = "127.0.0.1";
      retentionTime = "90d";
      extraFlags = ["--storage.tsdb.retention.size=20GB"];
      exporters = {
        node = {
          enable = true;
          listenAddress = "127.0.0.1";
        };
        smartctl = {
          enable = true;
          listenAddress = "127.0.0.1";
        };
        zfs = {
          enable = true;
          listenAddress = "127.0.0.1";
        };
      };
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [{targets = ["127.0.0.1:9100" "m1:9100"];}];
        }
        {
          job_name = "zfs";
          static_configs = [{targets = ["127.0.0.1:9134" "m1:9134"];}];
        }
        {
          job_name = "smartctl";
          static_configs = [{targets = ["127.0.0.1:9633" "m1:9633"];}];
        }
      ];
    };

    grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = "0.0.0.0";
          domain = "oob";
        };
        security.admin_password = "$__file{${config.sops.secrets."grafana/admin-password".path}}";
      };
      provision = {
        enable = true;
        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://127.0.0.1:9090";
            isDefault = true;
          }
        ];
      };
    };
  };
}
