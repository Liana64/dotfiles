{
  config,
  inputs,
  lib,
  ...
}: let
  inherit (inputs.self.network) offsite cluster;
  keys = inputs.self.keys.wireguard;
  wan = "en*";

  peers = {
    opnsense = ["${offsite.hosts.opnsense}/32" cluster.subnet];
    framework = ["${offsite.hosts.framework}/32"];
  };
  admins = [offsite.hosts.framework];
  subscribers = admins ++ [offsite.hosts.opnsense];
  addr = offsite.hosts.${config.networking.hostName};

  egress = {
    systemd-resolve = "tcp dport 853";
    chrony = "meta l4proto { tcp, udp } th dport { 123, 4460 }";
    acme = "meta l4proto { tcp, udp } th dport { 53, 443 }";
  };
in {
  networking = {
    useDHCP = false;
    useNetworkd = true;
    firewall.enable = false;
    nftables = {
      enable = true;
      tables.filter = {
        family = "inet";
        content = ''
          chain input {
            type filter hook input priority filter; policy drop;
            ct state established,related accept
            ct state invalid drop
            iif lo accept
            iifname "${wan}" udp dport ${toString offsite.port} accept
            iifname "wg0" meta l4proto { icmp, ipv6-icmp } accept
            iifname "wg0" ip saddr { ${lib.concatStringsSep ", " admins} } tcp dport { 22, 2222, 3000 } accept
            iifname "wg0" ip saddr { ${lib.concatStringsSep ", " subscribers} } tcp dport 2586 accept
            limit rate 10/minute log prefix "nft-in-drop: " level warn
          }

          chain forward {
            type filter hook forward priority filter; policy drop;
          }

          chain output {
            type filter hook output priority filter; policy drop;
            ct state established,related accept
            ct state invalid drop
            oif lo accept
            oifname "wg0" accept
            oifname "${wan}" udp sport ${toString offsite.port} accept
            oifname "${wan}" udp sport 68 udp dport 67 accept
            ${lib.concatStrings (lib.mapAttrsToList (user: rule: ''
              oifname "${wan}" meta skuid ${user} ${rule} accept
            '')
            egress)}
            limit rate 10/minute log prefix "nft-out-drop: " level warn
          }

          chain prerouting {
            type nat hook prerouting priority dstnat;
            iifname "wg0" tcp dport 443 redirect to :3000
          }
        '';
      };
    };
  };

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNS = ["9.9.9.9#dns.quad9.net" "149.112.112.112#dns.quad9.net"];
      DNSSEC = true;
      DNSOverTLS = true;
      FallbackDNS = [];
      LLMNR = false;
      MulticastDNS = false;
    };
  };

  sops.secrets."network/wireguard/offsite-1.key" = {
    owner = "systemd-network";
    mode = "0400";
    restartUnits = ["systemd-networkd.service"];
  };

  boot.kernelModules = ["wireguard"];

  systemd.network = {
    enable = true;
    networks."10-wan" = {
      matchConfig.Name = wan;
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = false;
        LinkLocalAddressing = "no";
      };
      dhcpV4Config.UseDNS = false;
    };

    netdevs."20-wg0" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg0";
      };
      wireguardConfig = {
        PrivateKeyFile = config.sops.secrets."network/wireguard/offsite-1.key".path;
        ListenPort = offsite.port;
        RouteTable = "main";
      };
      wireguardPeers =
        lib.mapAttrsToList (name: allowed: {
          PublicKey = keys.${name};
          AllowedIPs = allowed;
        })
        peers;
    };
    networks."20-wg0" = {
      matchConfig.Name = "wg0";
      address = ["${addr}/32"];
    };
  };
}
