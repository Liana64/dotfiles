{inputs, ...}: let
  inherit (inputs.self.network) cluster hstore mgmt;
in {
  networking.useDHCP = false;
  networking.useNetworkd = true;
  services.resolved.enable = true;

  systemd.network = let
    vlan = id: name: {
      netdevConfig = {
        Name = name;
        Kind = "vlan";
      };
      vlanConfig.Id = id;
    };
    parent = nic: vlanName: {
      matchConfig.Name = nic;
      networkConfig = {
        VLAN = [vlanName];
        LinkLocalAddressing = "no";
      };
      linkConfig.RequiredForOnline = false;
    };
  in {
    netdevs = {
      bond0 = {
        netdevConfig = {
          Name = "bond0";
          Kind = "bond";
        };
        bondConfig = {
          Mode = "802.3ad";
          TransmitHashPolicy = "layer3+4";
          LACPTransmitRate = "fast";
          MIIMonitorSec = "100ms";
        };
      };
      br0 = {
        netdevConfig = {
          Name = "br0";
          Kind = "bridge";
          MACAddress = "fa:f2:1e:24:92:a0";
        };
        bridgeConfig.VLANFiltering = true;
      };
      cluster = vlan 10 "cluster";
      hstore = vlan 20 "hstore";
      mgmt = vlan 99 "mgmt";
    };
    networks = {
      "10-bond-member" = {
        matchConfig.Driver = "i40e";
        networkConfig = {
          Bond = "bond0";
          LinkLocalAddressing = "no";
        };
        linkConfig.RequiredForOnline = false;
      };
      "11-trunk" = {
        matchConfig.Name = "bond0";
        networkConfig = {
          Bridge = "br0";
          LinkLocalAddressing = "no";
        };
        bridgeVLANs = [{VLAN = 10;} {VLAN = 20;}];
        linkConfig.RequiredForOnline = false;
      };
      "20-br0" = {
        matchConfig.Name = "br0";
        networkConfig = {
          VLAN = ["cluster" "hstore"];
          LinkLocalAddressing = "no";
        };
        bridgeVLANs = [{VLAN = 10;} {VLAN = 20;}];
        linkConfig.RequiredForOnline = false;
      };
      "30-mgmt-nic" = parent "eno2" "mgmt";
      "40-cluster" = {
        matchConfig.Name = "cluster";
        networkConfig.DHCP = "ipv4";
        dhcpV4Config.RouteTable = 10;
        routingPolicyRules = [
          {
            To = cluster.subnet;
            Table = 10;
            Priority = 100;
          }
          {
            From = cluster.subnet;
            Table = 10;
            Priority = 101;
          }
        ];
      };
      "41-mgmt" = {
        matchConfig.Name = "mgmt";
        networkConfig = {
          Address = mgmt.cidr.m1;
          Gateway = mgmt.gateway;
          DNS = mgmt.gateway;
        };
      };
      "42-hstore" = {
        matchConfig.Name = "hstore";
        networkConfig = {
          Address = hstore.cidr.m1;
          LinkLocalAddressing = "no";
        };
        routes = [
          {
            Destination = hstore.subnet;
            Scope = "link";
            Table = 20;
          }
          {
            Gateway = hstore.gateway;
            Table = 20;
          }
        ];
        routingPolicyRules = [
          {
            From = hstore.subnet;
            Table = 20;
            Priority = 102;
          }
        ];
        linkConfig.RequiredForOnline = false;
      };
    };
  };
}
