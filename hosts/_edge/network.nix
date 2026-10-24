{
  config,
  inputs,
  ...
}: let
  cfg = config.edge;
  inherit (inputs.self.network) mgmt pfsync;
in {
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
    quiet = name: {
      matchConfig.Name = name;
      networkConfig.LinkLocalAddressing = "no";
      linkConfig.RequiredForOnline = false;
    };
  in {
    links = {
      "10-mgmt" = rename cfg.macs.mgmt "mgmt";
      "10-lan" = rename cfg.macs.lan "lan";
      "10-wan" = rename cfg.macs.wan "wan";
    };

    netdevs = {
      br0 = {
        netdevConfig = {
          Name = "br0";
          Kind = "bridge";
        };
        bridgeConfig = {
          VLANFiltering = true;
          DefaultPVID = "none";
        };
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
      "20-lan" = member {matchConfig.Name = "lan";} "br0" [
        {
          PVID = 1;
          EgressUntagged = 1;
        }
        {VLAN = "2-4094";}
      ];
      "21-wan" = member {matchConfig.Name = "wan";} "br-wan" [];
      "22-tb" = member {matchConfig.Driver = "thunderbolt-net";} "br-tb" [{VLAN = 10;} {VLAN = pfsync.vlan;}];
      "30-br0" = quiet "br0";
      "31-br-wan" = quiet "br-wan";
      "32-br-tb" = {
        matchConfig.Name = "br-tb";
        networkConfig.Address = "10.10.10.1${toString cfg.index}/24";
        linkConfig.RequiredForOnline = false;
      };
      "40-mgmt" = {
        matchConfig.Name = "mgmt";
        networkConfig = {
          Address = mgmt.cidr.${config.networking.hostName};
          Gateway = mgmt.gateway;
          DNS = mgmt.gateway;
        };
      };
    };
  };
}
