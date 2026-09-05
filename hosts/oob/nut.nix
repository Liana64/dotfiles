{config, ...}: {
  sops.secrets."nut/password" = {};

  networking.firewall.allowedTCPPorts = [3493];

  power.ups = {
    enable = true;
    mode = "netserver";
    ups.cyberpower = {
      driver = "usbhid-ups";
      port = "auto";
      description = "CP1500PFCLCDa";
    };
    upsd.listen = [{address = "0.0.0.0";}];
    users.upsmon = {
      passwordFile = config.sops.secrets."nut/password".path;
      upsmon = "primary";
    };
    upsmon.monitor.cyberpower = {
      system = "cyberpower@localhost";
      user = "upsmon";
      passwordFile = config.sops.secrets."nut/password".path;
      type = "primary";
    };
  };

  services.prometheus = {
    exporters.nut = {
      enable = true;
      listenAddress = "127.0.0.1";
      nutServer = "127.0.0.1";
    };
    scrapeConfigs = [
      {
        job_name = "nut";
        static_configs = [{targets = ["127.0.0.1:9199"];}];
      }
    ];
  };
}
