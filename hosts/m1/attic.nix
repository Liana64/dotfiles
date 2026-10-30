{
  config,
  inputs,
  ...
}: let
  net = inputs.self.network;
  addr = net.cluster.hosts.m1;
  port = 8090;
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
        path = "/tank/cluster/nix-cache";
      };
      garbage-collection.default-retention-period = "3 months";
    };
  };

  systemd.services.atticd = {
    requires = ["zfs-datasets.service"];
    after = ["zfs-datasets.service"];
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
