{...}: {
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
      bridgeConfig.VLANFiltering = true;
    };

    networks = {
      "20-lan" = {
        matchConfig.Name = "lan";
        networkConfig = {
          Bridge = "br0";
          LinkLocalAddressing = "no";
        };
        bridgeVLANs = [{VLAN = 10;}];
        linkConfig.RequiredForOnline = false;
      };
      "30-br0" = {
        matchConfig.Name = "br0";
        networkConfig.LinkLocalAddressing = "no";
        bridgeVLANs = [{VLAN = 10;}];
        linkConfig.RequiredForOnline = false;
      };
      "40-mgmt" = {
        matchConfig.Name = "mgmt";
        networkConfig = {
          Address = "172.16.99.102/24";
          Gateway = "172.16.99.1";
          DNS = "172.16.99.1";
        };
      };
    };
  };
}
