{
  config,
  inputs,
  lib,
  libvirt,
  pkgs,
  ...
}: let
  inherit (inputs.self.network) mgmt pfsync;
  cfg = config.edge.opnsense;
  inherit (libvirt) mkVM media;
  wanMac = "BC:24:11:C4:32:02";
  name = "opnsense-${config.networking.hostName}";
  virsh = "${config.virtualisation.libvirtd.package}/bin/virsh -c qemu:///system";
in {
  motd.status = [
    ''
      vm=$(${virsh} domstate ${name} 2>/dev/null) || vm=unknown
      case $vm in running) c=32 ;; paused | "in shutdown") c=33 ;; "shut off") c=31 vm=down ;; *) c=31 ;; esac
      port=$(${virsh} domiflist ${name} 2>/dev/null | while read -r i _ _ _ m; do if [[ $m == ${lib.toLower cfg.macs.lan} ]]; then echo "$i"; fi; done) || port=
      fdb=$(${pkgs.iproute2}/bin/bridge fdb show br br0 2>/dev/null) || fdb=
      if [[ -n $port && $fdb =~ 00:00:5e:00:01:..\ dev\ $port\  ]]; then
        carp=$'\e[32mcarp master\e[0m'
      elif [[ $fdb == *00:00:5e:00:01:* ]]; then
        carp='carp backup'
      else
        carp=$'\e[2mcarp none\e[0m'
      fi
      if [[ $(${pkgs.iputils}/bin/ping -c1 -W1 -n ${mgmt.gateway} 2>/dev/null) =~ time=([0-9.]+) ]]; then
        gw="gateway ''${BASH_REMATCH[1]}ms"
      else
        gw=$'\e[31mgateway down\e[0m'
      fi
      printf ' \e[%sm●\e[0m ${name} %s · %s · %s\n' "$c" "$vm" "$carp" "$gw"
    ''
  ];

  virtualisation.libvirt.connections."qemu:///system".domains = [
    (mkVM {
      inherit name;
      inherit (cfg) uuid memoryGiB active;
      vcpus = 2;
      iso = media.opnsense;
      disks = [
        {
          zvol = "rpool/vms/opnsense-os";
          dev = "sda";
          boot = 1;
        }
      ];
      nics = [
        {
          bridge = "br0";
          mac = cfg.macs.lan;
          vlan = lib.range 2 4094;
          native = 1;
        }
        {
          bridge = "br-wan";
          mac = wanMac;
        }
        {
          bridge = "br-tb";
          mac = cfg.macs.tb;
          inherit (pfsync) vlan;
        }
      ];
    })
  ];

  services.sanoid.datasets."rpool/vms/opnsense-os".useTemplate = ["daily"];
}
