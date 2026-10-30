{
  config,
  inputs,
  ...
}: let
  addr = inputs.self.network.offsite.hosts.${config.networking.hostName};
  url = "http://${addr}:2586";
in {
  motd.commands = [[url "ntfy"]];

  sops.secrets."services/ntfy/env".restartUnits = ["ntfy-sh.service"];

  services.ntfy-sh = {
    enable = true;
    environmentFile = config.sops.secrets."services/ntfy/env".path;
    settings = {
      base-url = url;
      listen-http = "${addr}:2586";
      web-root = "disable";
      enable-signup = false;
      auth-default-access = "deny-all";
      auth-access = ["*:${config.networking.hostName}:wo"];
    };
  };

  systemd.services.ntfy-sh = {
    after = ["network-online.target"];
    wants = ["network-online.target"];
  };
}
