{
  config,
  inputs,
  ...
}: let
  net = inputs.self.network;
  addr = net.cluster.hosts.m1;
  port = 8090;
  key = k: config.sops.placeholder."seaweedfs/nix-cache/${k}";
in {
  motd.commands = [["http://${addr}:${toString port}" "attic"]];

  sops = {
    secrets."attic/token-rs256" = {};
    templates."atticd.env" = {
      restartUnits = ["atticd.service"];
      content = ''
        AWS_ACCESS_KEY_ID=${key "access-key"}
        AWS_SECRET_ACCESS_KEY=${key "secret-key"}
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
        type = "s3";
        region = "us-east-1";
        bucket = "nix-cache";
        endpoint = "http://${addr}:8333";
      };
      garbage-collection.default-retention-period = "3 months";
    };
  };

  systemd.services.atticd = {
    requires = ["seaweedfs.service"];
    after = ["seaweedfs.service"];
    serviceConfig = {
      IPAddressDeny = "any";
      IPAddressAllow =
        [addr net.home.hosts.catbox net.offsite.hosts.offsite-1 net.offsite.hosts.framework]
        ++ net.cluster.nodes
        ++ net.clients.liana;
      SocketBindAllow = "tcp:${toString port}";
      SocketBindDeny = "any";
      PrivateIPC = true;
    };
  };

  networking.firewall.interfaces.cluster.allowedTCPPorts = [port];
}
