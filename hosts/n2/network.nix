{...}: {
  networking.useDHCP = false;
  networking.useNetworkd = true;
  services.resolved.enable = true;

  boot.kernelModules = ["thunderbolt-net"];

  systemd.network = let
    rename = mac: name: {
      matchConfig.PermanentMACAddress = mac;
      linkConfig.Name = name;
    };
    member = match: bridge: vlans:
      match
      // {
        networkConfig = {
          Bridge = bridge;
          LinkLocalAddressing = "no";
        };
        bridgeVLANs = vlans;
        linkConfig.RequiredForOnline = false;
      };
    quiet = name: vlans: {
      matchConfig.Name = name;
      networkConfig.LinkLocalAddressing = "no";
      bridgeVLANs = vlans;
      linkConfig.RequiredForOnline = false;
    };
  in {
    links = {
      "10-mgmt" = rename "38:05:25:35:b7:e4" "mgmt";
      "10-lan" = rename "38:05:25:35:b7:e2" "lan";
    };

    netdevs = {
      br0 = {
        netdevConfig = {
          Name = "br0";
          Kind = "bridge";
        };
        bridgeConfig.VLANFiltering = true;
      };
      br-tb = {
        netdevConfig = {
          Name = "br-tb";
          Kind = "bridge";
        };
        bridgeConfig.VLANFiltering = true;
      };
    };

    networks = {
      "20-lan" = member {matchConfig.Name = "lan";} "br0" [{VLAN = 10;}];
      "22-tb" = member {matchConfig.Driver = "thunderbolt-net";} "br-tb" [];
      "30-br0" = quiet "br0" [{VLAN = 10;}];
      "32-br-tb" = {
        matchConfig.Name = "br-tb";
        networkConfig.Address = "10.10.10.12/24";
        linkConfig.RequiredForOnline = false;
      };
      "40-mgmt" = {
        matchConfig.Name = "mgmt";
        networkConfig = {
          Address = "172.16.99.101/24";
          Gateway = "172.16.99.1";
          DNS = "172.16.99.1";
        };
      };
    };
  };
}
