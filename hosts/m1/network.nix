{...}: {
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
      mgmt = vlan 99 "mgmt";
    };
    networks = {
      "10-bond-member" = {
        matchConfig.Name = "enp1s0f*";
        networkConfig = {
          Bond = "bond0";
          LinkLocalAddressing = "no";
        };
      };
      "11-trunk" = {
        matchConfig.Name = "bond0";
        networkConfig = {
          Bridge = "br0";
          LinkLocalAddressing = "no";
        };
        bridgeVLANs = [{VLAN = 10;}];
      };
      "20-br0" = {
        matchConfig.Name = "br0";
        networkConfig = {
          VLAN = ["cluster"];
          LinkLocalAddressing = "no";
        };
        bridgeVLANs = [{VLAN = 10;}];
      };
      "30-mgmt-nic" = parent "eno2" "mgmt";
      "40-cluster" = {
        matchConfig.Name = "cluster";
        networkConfig.DHCP = "ipv4";
        dhcpV4Config.RouteTable = 10;
        routingPolicyRules = [
          {
            To = "172.16.4.0/23";
            Table = 10;
            Priority = 100;
          }
          {
            From = "172.16.4.0/23";
            Table = 10;
            Priority = 101;
          }
        ];
      };
      "41-mgmt" = {
        matchConfig.Name = "mgmt";
        networkConfig = {
          Address = "172.16.99.44/24";
          Gateway = "172.16.99.1";
          DNS = "172.16.99.1";
        };
      };
    };
  };
}
