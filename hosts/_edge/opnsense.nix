{
  config,
  inputs,
  lib,
  libvirt,
  ...
}: let
  inherit (inputs.self.network) mgmt pfsync;
  cfg = config.edge.opnsense;
  inherit (libvirt) mkVM media;
  wanMac = "BC:24:11:C4:32:02";
  name = "opnsense-${config.networking.hostName}";
in {
  motd.status = [
    ''
      vm=$(${config.virtualisation.libvirtd.package}/bin/virsh -c qemu:///system domstate ${name} 2>/dev/null) || vm=unknown
      case $vm in running) c=32 ;; paused | "in shutdown") c=33 ;; *) c=31 ;; esac
      if [[ $(${config.security.wrapperDir}/ping -c1 -W1 -n ${mgmt.gateway} 2>/dev/null) =~ time=([0-9.]+) ]]; then
        gw="gateway ''${BASH_REMATCH[1]}ms"
      else
        gw=$'\e[31mgateway down\e[0m'
      fi
      printf ' \e[%sm●\e[0m ${name} %s · %s\n' "$c" "$vm" "$gw"
    ''
  ];

  virtualisation.libvirt.connections."qemu:///system".domains = [
    (mkVM {
      name = "opnsense-${config.networking.hostName}";
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
