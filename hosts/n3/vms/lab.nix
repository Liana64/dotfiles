{
  config,
  pkgs,
  lib,
  libvirt,
  hardening,
  ...
}: let
  inherit (libvirt) mkVM media;

  userData = pkgs.writeText "user-data" ("#cloud-config\n"
    + builtins.toJSON {
      users = [
        {
          name = "liana";
          groups = ["wheel"];
          sudo = "ALL=(ALL) NOPASSWD:ALL";
          ssh_authorized_keys = (import ../../../modules/_lib/keys.nix).liana;
        }
      ];
      ssh_pwauth = false;
    });

  cidata = name:
    pkgs.runCommand "${name}-cidata.iso" {nativeBuildInputs = [pkgs.xorriso];} ''
      xorriso -as mkisofs -volid cidata -joliet -rock -graft-points -output $out \
        user-data=${userData} \
        meta-data=${pkgs.writeText "meta-data" (builtins.toJSON {
        instance-id = name;
        local-hostname = name;
      })}
    '';

  disks = [
    {
      name = "os";
      size = "20G";
      dev = "sda";
      boot = 1;
    }
    {
      name = "data0";
      size = "4G";
      dev = "sdb";
    }
    {
      name = "data1";
      size = "4G";
      dev = "sdc";
    }
    {
      name = "usb";
      size = "4G";
      dev = "sdd";
      bus = "usb";
    }
    {
      name = "nvme";
      size = "2G";
      dev = "nvme0n1";
      bus = "nvme";
    }
  ];

  guests = {
    # rhel8 = {
    #   uuid = "3218a4d3-1624-4376-a975-f9f7c253571b";
    #   image = media.rhel8;
    #   macs = ["BC:24:11:A0:F3:A6" "BC:24:11:2B:E8:50"];
    # };
    # rhel9 = {
    #   uuid = "fcd3510d-1382-4728-89db-301b9568eabd";
    #   image = media.rhel9;
    #   macs = ["BC:24:11:57:2A:DC" "BC:24:11:E2:11:82"];
    # };
    rhel10-a = {
      uuid = "a3610116-9551-4448-bc12-830bb40c11f9";
      image = media.rhel10;
      macs = ["BC:24:11:47:2F:29" "BC:24:11:36:E7:DF"];
    };
    rhel10-b = {
      uuid = "2b1d1449-7035-4ebc-9310-751ca149110e";
      image = media.rhel10;
      macs = ["BC:24:11:F1:1F:3A" "BC:24:11:23:A9:51"];
    };
    rhel10-c = {
      uuid = "2ad22a8c-541e-4ced-b30b-3ce75cdd5539";
      image = media.rhel10;
      macs = ["BC:24:11:16:10:1C" "BC:24:11:18:0E:04"];
    };
  };
in {
  boot.zfs.extraPools = ["lab"];

  disko.devices.zpool.lab.datasets = lib.concatMapAttrs (name: _:
    {
      ${name} = {
        type = "zfs_fs";
        options.mountpoint = "none";
      };
    }
    // lib.listToAttrs (map (d:
      lib.nameValuePair "${name}/${d.name}" {
        type = "zfs_volume";
        inherit (d) size;
      })
    disks))
  guests;

  systemd.services = lib.mapAttrs' (name: guest:
    lib.nameValuePair "lab-seed-${name}" {
      wantedBy = ["multi-user.target"];
      requires = ["zfs-import-lab.service"];
      after = ["zfs-import-lab.service"];
      path = [config.boot.zfs.package pkgs.qemu-utils];
      serviceConfig =
        hardening.confined
        // {
          Type = "oneshot";
          PrivateDevices = false;
          CapabilityBoundingSet = "CAP_SYS_ADMIN";
          RestrictAddressFamilies = ["AF_UNIX" "AF_NETLINK"];
          IPAddressDeny = "any";
        };
      script = ''
        zfs list lab/${name}/os@seeded >/dev/null 2>&1 && exit 0
        udevadm wait --timeout=30 /dev/zvol/lab/${name}/os
        qemu-img convert -n -O raw ${guest.image} /dev/zvol/lab/${name}/os
        zfs snapshot -r lab/${name}@seeded
      '';
    })
  guests;

  virtualisation.libvirt.connections."qemu:///system".domains = lib.mapAttrsToList (name: guest:
    mkVM {
      inherit name;
      inherit (guest) uuid;
      iso = cidata name;
      vcpus = 1;
      memoryGiB = 2;
      active = null;
      disks = map (d: removeAttrs d ["name" "size"] // {zvol = "lab/${name}/${d.name}";}) disks;
      nics =
        map (mac: {
          bridge = "br0";
          inherit mac;
          vlan = 80;
        })
        guest.macs;
      devices.watchdog = {
        model = "i6300esb";
        action = "reset";
      };
    })
  guests;
}
