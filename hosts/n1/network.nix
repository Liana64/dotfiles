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
      "10-mgmt" = rename "58:47:ca:7a:e3:f4" "mgmt";
      "10-lan" = rename "58:47:ca:7a:e3:f2" "lan";
      "10-wan" = rename "58:47:ca:7a:e3:f3" "wan";
    };

    netdevs = {
      br0 = {
        netdevConfig = {
          Name = "br0";
          Kind = "bridge";
        };
        bridgeConfig.VLANFiltering = true;
      };
      br-wan.netdevConfig = {
        Name = "br-wan";
        Kind = "bridge";
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
      "21-wan" = member {matchConfig.Name = "wan";} "br-wan" [];
      "22-tb" = member {matchConfig.Driver = "thunderbolt-net";} "br-tb" [];
      "30-br0" = quiet "br0" [{VLAN = 10;}];
      "31-br-wan" = quiet "br-wan" [];
      "32-br-tb" = {
        matchConfig.Name = "br-tb";
        networkConfig.Address = "10.10.10.11/24";
        linkConfig.RequiredForOnline = false;
      };
      "40-mgmt" = {
        matchConfig.Name = "mgmt";
        networkConfig = {
          Address = "172.16.99.100/24";
          Gateway = "172.16.99.1";
          DNS = "172.16.99.1";
        };
      };
    };
  };
}
