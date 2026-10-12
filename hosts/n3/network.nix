{inputs, ...}: let
  inherit (inputs.self.network) mgmt;
in {
  networking.useDHCP = false;
  networking.useNetworkd = true;
  services.resolved.enable = true;

  systemd.network = let
    rename = mac: name: {
      matchConfig.PermanentMACAddress = mac;
      linkConfig.Name = name;
    };
  in {
    links = {
      "10-mgmt" = rename "60:7d:09:03:95:9a" "mgmt";
      "10-lan" = rename "d8:9e:f3:9d:69:77" "lan";
    };

    netdevs.br0 = {
      netdevConfig = {
        Name = "br0";
        Kind = "bridge";
      };
      bridgeConfig = {
        VLANFiltering = true;
        DefaultPVID = "none";
      };
    };

    networks = {
      "20-lan" = {
        matchConfig.Name = "lan";
        networkConfig = {
          Bridge = "br0";
          LinkLocalAddressing = "no";
        };
        bridgeVLANs = [{VLAN = 10;} {VLAN = 80;}];
        linkConfig.RequiredForOnline = false;
      };
      "30-br0" = {
        matchConfig.Name = "br0";
        networkConfig.LinkLocalAddressing = "no";
        linkConfig.RequiredForOnline = false;
      };
      "40-mgmt" = {
        matchConfig.Name = "mgmt";
        networkConfig = {
          Address = mgmt.cidr.n3;
          Gateway = mgmt.gateway;
          DNS = mgmt.gateway;
        };
      };
    };
  };
}
