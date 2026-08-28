{...}: {
  networking.useDHCP = false;
  networking.useNetworkd = true;
  services.resolved.enable = true;

  # proxmox-style: br0 is vlan-aware, enp2s0f0 trunks into it, VM taps are
  # tagged by libvirt (>= 11.0), host access via the cluster vlan on br0
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
    dhcp = name: gateway: {
      matchConfig.Name = name;
      networkConfig.DHCP = "ipv4";
      dhcpV4Config.UseGateway = gateway;
    };
  in {
    netdevs = {
      br0 = {
        netdevConfig = {
          Name = "br0";
          Kind = "bridge";
        };
        bridgeConfig.VLANFiltering = true;
      };
      cluster = vlan 10 "cluster";
      mgmt = vlan 99 "mgmt";
      home = vlan 100 "home";
    };
    networks = {
      "10-trunk" = {
        matchConfig.Name = "enp1s0f0";
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
      "30-mgmt-nic" = parent "enp1s0f1" "mgmt";
      # "31-home-nic" = parent "enp0s31f6" "home";
      "40-cluster" = dhcp "cluster" false;
      "41-mgmt" = dhcp "mgmt" true;
      "42-home" = dhcp "home" false;
    };
  };
}
