{
  config,
  hardening,
  ...
}: let
  nut =
    hardening.base
    // {
      ProtectHome = true;
      RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK"];
    };
in {
  sops.secrets."nut/password" = {};

  motd.commands = [["upsc cyberpower" "UPS status"]];

  power.ups = {
    enable = true;
    mode = "netserver";
    ups.cyberpower = {
      driver = "usbhid-ups";
      port = "auto";
      description = "CP1500PFCLCDa";
    };
    upsd.listen = [{address = "127.0.0.1";}];
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

  systemd.services = {
    upsd.serviceConfig = nut;
    upsdrv.serviceConfig = nut;
  };

  services.prometheus.exporters.nut = {
    enable = true;
    nutServer = "127.0.0.1";
  };
}
