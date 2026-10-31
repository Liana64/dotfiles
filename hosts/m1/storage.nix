{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  net = inputs.self.network;

  ids = {
    media = 2000;
    documents = 2100;
    backup = 2200;
    uploads = 2300;
    s3 = 2400;
    attic = 2500;
  };

  pushers = {
    framework = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP657Ck261PoRlolOEYLJnMqwjkWhJiu0gvsFIX+BE08 framework-backup"];
    oob = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHymjCcyZVYbgI4MQTMzTNU68zMHSfKRZOJhTgqpkHQk oob-backup"];
  };

  base = "rw,no_subtree_check,crossmnt";
  access = {
    owned = id: "${base},root_squash,anonuid=${toString id},anongid=${toString id}";
    user = _: "${base},root_squash";
    anon = id: "${base},all_squash,anonuid=${toString id},anongid=${toString id}";
    view = id: "ro,no_subtree_check,crossmnt,all_squash,anonuid=${toString id},anongid=${toString id}";
    browse = _: "ro,no_subtree_check,root_squash";
  };

  lan = level: {
    ops = level;
  };

  people = lib.filterAttrs (_: u: u.isNormalUser && u.uid != null) config.users.users;

  stashes = lib.mapAttrs' (name: u:
    lib.nameValuePair "tank/users/stash/${name}" {
      id = u.uid;
      gid = config.users.groups.${u.group}.gid;
      mode = "0700";
      grants = {
        ${name} = access.anon;
      };
    })
  people;

  syncer = {
    id = config.users.users.syncthing.uid;
    gid = config.users.groups.syncthing.gid;
    mode = "0700";
  };

  syncs = lib.listToAttrs (map (owner: lib.nameValuePair "tank/users/sync/${owner}" syncer) (
    lib.unique (lib.mapAttrsToList (_: f: f.owner) inputs.self.syncthing.folders)
  ));

  # Quotas, out of ~25.3T usable:
  #
  #   users            3.5T  syncthing + stash
  #   cluster/media     15T
  #   cluster/photos     2T
  #   cluster/uploads    1T
  #   cluster/s3         1T
  #   cluster/nix-cache  0.376T  reserved up front
  #   backups            1.5T
  #                   ------
  #                     24.376T
  datasets =
    {
      "tank/users" = {
        id = 0;
        mode = "0755";
        props.quota = "3.5T";
        grants = lan access.browse;
      };
      "tank/users/sync" = syncer;
      "tank/users/stash" = {
        id = 0;
        mode = "0755";
      };
      "tank/users/stash/shared" = {
        id = ids.documents;
        mode = "2770";
        grants = lan access.anon;
      };
      "tank/users/stash/shared/landfill" = {
        id = ids.documents;
        mode = "2770";
      };
      "tank/cluster" = {
        id = 0;
        mode = "0755";
        grants = lan access.browse;
      };
      "tank/cluster/media" = {
        id = ids.media;
        mode = "2775";
        props = {
          recordsize = "1M";
          quota = "15T";
        };
        grants = lan access.user;
      };
      "tank/cluster/photos" = {
        id = ids.documents;
        mode = "2770";
        props.quota = "2T";
        grants = lan access.view;
      };
      "tank/cluster/uploads" = {
        id = ids.uploads;
        mode = "0750";
        props.quota = "1T";
      };
      "tank/cluster/s3" = {
        id = ids.s3;
        mode = "0700";
        props.refquota = "1T";
      };
      "tank/cluster/nix-cache" = {
        id = ids.attic;
        mode = "0700";
        props = {
          refquota = "376G";
          refreservation = "376G";
          compression = "off";
          exec = "off";
          setuid = "off";
          devices = "off";
        };
      };
      "rpool/seaweedfs" = {
        id = ids.s3;
        mode = "0700";
        props = {
          mountpoint = "/rpool/seaweedfs";
          quota = "10G";
        };
      };
      "tank/backups" = {
        id = 0;
        mode = "0700";
        props.quota = "1.5T";
      };
      "tank/backups/volsync" = {
        id = ids.backup;
        mode = "0770";
      };
    }
    // stashes
    // syncs
    // lib.mapAttrs' (name: _:
      lib.nameValuePair "tank/backups/${name}" {
        id = ids.backup;
        mode = "0700";
        allow = "backup receive,create,mount,hold";
        props.readonly = "on";
      })
    pushers;

  exported = lib.filterAttrs (_: s: s ? grants) datasets;

  exportLine = path: s:
    "/${path} "
    + lib.concatStringsSep " " (lib.flatten (
      lib.mapAttrsToList (group: level: map (c: "${c}(${level s.id})") net.clients.${group}) s.grants
    ));

  recvOnly = target: key: ''command="${config.boot.zfs.package}/bin/zfs receive -du tank/backups/${target}",restrict ${key}'';

  ensure = path: s:
    ''
      zfs list -H ${path} >/dev/null 2>&1 || zfs create -p ${path}
    ''
    + lib.concatStrings (lib.mapAttrsToList (k: v: "zfs set -u ${k}=${v} ${path}\n") (s.props or {}))
    + lib.optionalString (s ? allow) "zfs allow ${s.allow} ${path}\n"
    + ''
      [ "$(zfs get -H -o value mounted ${path})" = yes ] || zfs mount ${path}
      [ "$(stat -c %u:%g:%a /${path})" = ${toString s.id}:${toString (s.gid or s.id)}:${lib.removePrefix "0" s.mode} ] || {
        chown ${toString s.id}:${toString (s.gid or s.id)} /${path}
        chmod ${s.mode} /${path}
      }
    '';
in {
  boot = {
    # TODO: ZFS encryption, clevis/tang
    # tank is created manually
    zfs.extraPools = ["tank"];

    # 64G: 40 vm (vfio-pinned) + ~1 qemu + 12 arc + ~11 host/slack
    kernelParams = ["zfs.zfs_arc_max=${toString (12 * 1024 * 1024 * 1024)}"];

    # nfsd/ganesha bind specific addrs; the cluster addr is DHCP and may
    # arrive after the units start
    kernel.sysctl."net.ipv4.ip_nonlocal_bind" = 1;
  };

  users = {
    groups = {
      media.gid = ids.media;
      documents.gid = ids.documents;
      backup.gid = ids.backup;
      uploads.gid = ids.uploads;
      seaweedfs.gid = ids.s3;
      atticd.gid = ids.attic;
    };
    users.seaweedfs = {
      uid = ids.s3;
      group = "seaweedfs";
      isSystemUser = true;
    };
    users.atticd = {
      uid = ids.attic;
      group = "atticd";
      isSystemUser = true;
    };
    users.backup = {
      uid = ids.backup;
      group = "backup";
      isSystemUser = true;
      useDefaultShell = true;
      openssh.authorizedKeys.keys = lib.flatten (lib.mapAttrsToList (target: map (recvOnly target)) pushers);
    };
  };

  environment.systemPackages = [pkgs.rsync pkgs.sanoid];

  services = {
    nfs.server = {
      enable = true;
      exports = lib.concatStringsSep "\n" (lib.mapAttrsToList exportLine exported);
    };
    nfs.settings.nfsd = {
      # homes listen on hstore only; 2049 on the cluster addr is ganesha's
      host = net.hstore.hosts.m1;
      vers3 = false;
      udp = false;
      threads = 16;
    };

    rpcbind.enable = lib.mkForce false;

    sanoid = {
      enable = true;
      templates = {
        tank = {
          hourly = 48;
          daily = 30;
          monthly = 6;
          autosnap = true;
          autoprune = true;
        };
        backup = {
          hourly = 48;
          daily = 30;
          monthly = 6;
          autosnap = false;
          autoprune = true;
        };
      };
      datasets = {
        tank = {
          useTemplate = ["tank"];
          recursive = true;
        };
        # repos are pod-deletable over NFS — snapshots make that recoverable
        "tank/backups/volsync" = {
          autosnap = true;
          autoprune = true;
          hourly = 0;
          daily = 7;
          monthly = 0;
        };
        "tank/cluster/s3" = {
          autosnap = true;
          autoprune = true;
          hourly = 24;
          daily = 7;
          monthly = 0;
        };
        "tank/users/stash/shared/landfill" = {
          autosnap = false;
          autoprune = false;
        };
        "tank/cluster/nix-cache" = {
          autosnap = false;
          autoprune = false;
        };
        # nested recursion precedence unverified — confirm children skip
        # autosnap: sanoid --cron --readonly --debug
        "tank/backups" = {
          useTemplate = ["backup"];
          recursive = true;
        };
      };
    };

    prometheus.exporters.smartctl.devices = [
      "/dev/disk/by-id/ata-ST28000NM001C-4CA103_K1S0PME3"
      "/dev/disk/by-id/ata-ST28000NM001C-4CA103_K1S17776"
    ];
  };

  systemd = {
    services.rpc-statd.enable = false;
    services.rpc-statd-notify.enable = false;
    services.rpc-gssd.enable = false;
    services.rpc-svcgssd.enable = false;
    services.zfs-datasets = {
      wantedBy = ["multi-user.target"];
      requiredBy = ["nfs-server.service"];
      after = ["zfs-mount.service"];
      before = ["nfs-server.service"];
      stopIfChanged = false;
      path = [config.boot.zfs.package];
      # mount-ns directives (ProtectSystem, PrivateTmp, ...) would trap the
      # mounts of newly created datasets in the unit's slave namespace
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        NoNewPrivileges = true;
        CapabilityBoundingSet = "CAP_SYS_ADMIN CAP_CHOWN CAP_FOWNER CAP_DAC_OVERRIDE CAP_DAC_READ_SEARCH";
        RestrictAddressFamilies = ["AF_UNIX" "AF_NETLINK"];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        LockPersonality = true;
        ProtectClock = true;
        SystemCallArchitectures = "native";
        IPAddressDeny = "any";
      };
      script = lib.concatStrings (lib.mapAttrsToList ensure datasets);
    };
  };
}
