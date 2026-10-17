# @desc: Infra network addressing (cluster, hstore, mgmt, vpn, clients)
{
  flake.network = let
    lan = net: net // {cidr = builtins.mapAttrs (_: ip: "${ip}/${baseNameOf net.subnet}") net.hosts;};
  in {
    cluster = lan {
      subnet = "172.16.4.0/23";
      hosts = {
        m1 = "172.16.4.30";
        syncthing = "172.16.5.16";
      };
      nodes = [
        "172.16.4.11"
        "172.16.4.12"
        "172.16.4.13"
        "172.16.4.14"
      ];
    };
    hstore = lan {
      subnet = "172.16.20.0/24";
      gateway = "172.16.20.1";
      hosts.m1 = "172.16.20.44";
    };
    mgmt = lan {
      subnet = "172.16.99.0/24";
      gateway = "172.16.99.1";
      hosts = {
        m1 = "172.16.99.44";
        n1 = "172.16.99.100";
        n2 = "172.16.99.101";
        n3 = "172.16.99.102";
      };
    };
    vpn = lan {
      subnet = "172.16.140.0/24";
      gateway = "172.16.140.1";
      hosts = {
        slskd = "172.16.140.10";
        qbittorrent = "172.16.140.20";
      };
    };
    clients = {
      ops = ["172.16.95.0/24"];
      liana = [
        "172.16.95.30"
        "172.16.95.31"
      ];
      maxine = [
        "172.16.95.40"
        "172.16.95.41"
      ];
    };
  };
}
