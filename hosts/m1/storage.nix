{
  config,
  lib,
  ...
}: let
  net = {
    cluster = [
      "172.16.4.11"
      "172.16.4.12"
      "172.16.4.13"
      "172.16.4.14"
    ];
    home = ["172.16.100.0/24"];
    admin = ["172.16.99.0/24"];
    liana = [
      "172.16.100.30"
    ];
    maxine = [
      "172.16.100.41"
    ];
  };

  ids = {
    media = 2000;
    documents = 2100;
    backup = 2200;
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
  };

  lan = level: {
    home = level;
    admin = level;
  };

  people = lib.filterAttrs (_: u: u.isNormalUser && u.uid != null) config.users.users;

  homes = lib.mapAttrs' (name: u:
    lib.nameValuePair "tank/home/${name}" {
      id = u.uid;
      gid = config.users.groups.${u.group}.gid;
      mode = "0700";
      props.quota = "1T";
      grants = {
        admin = access.user;
        ${name} = access.user;
      };
    })
  people;

  datasets =
    {
      # downloads is a plain dir: hardlinks need one fs; incomplete stays off-pool
      "tank/media" = {
        id = ids.media;
        mode = "2775";
        props = {
          recordsize = "1M";
          quota = "14.5T";
        };
        grants = {cluster = access.owned;} // lan access.user;
      };
      "tank/home" = {
        id = 0;
        mode = "0755";
        props.quota = "5T";
        grants = lan access.user;
      };
      "tank/home/photos" = {
        id = ids.documents;
        mode = "2770";
        grants = {cluster = access.anon;} // lan access.anon;
      };
      "tank/home/shared" = {
        id = ids.documents;
        mode = "2770";
        grants = lan access.anon;
      };
      "tank/home/shared/landfill" = {
        id = ids.documents;
        mode = "2770";
      };
      "tank/backups" = {
        id = 0;
        mode = "0700";
        props.quota = "5T";
      };
      "tank/backups/volsync" = {
        id = ids.backup;
        mode = "0770";
        grants.cluster = access.anon;
      };
    }
    // homes
    // lib.mapAttrs' (name: _:
      lib.nameValuePair "tank/backups/${name}" {
        id = ids.backup;
        mode = "0700";
        allow = "backup receive,create,mount,hold";
      })
    pushers;

  exported = lib.filterAttrs (_: s: s ? grants) datasets;

  exportLine = path: s:
    "/${path} "
    + lib.concatStringsSep " " (lib.flatten (
      lib.mapAttrsToList (group: level: map (c: "${c}(${level s.id})") net.${group}) s.grants
    ));

  recvOnly = target: key: ''command="${config.boot.zfs.package}/bin/zfs receive -du tank/backups/${target}",restrict ${key}'';

  ensure = path: s:
    ''
      zfs list -H ${path} >/dev/null 2>&1 || zfs create -p ${path}
    ''
    + lib.concatStrings (lib.mapAttrsToList (k: v: "zfs set ${k}=${v} ${path}\n") (s.props or {}))
    + lib.optionalString (s ? allow) "zfs allow ${s.allow} ${path}\n"
    + ''
      chown ${toString s.id}:${toString (s.gid or s.id)} /${path}
      chmod ${s.mode} /${path}
    '';
in {
  boot = {
    # tank is hand-built, imported here, never declared to disko (reinstall-safe);
    # unencrypted — future: native zfs encryption, clevis/tang unlock
    zfs.extraPools = ["tank"];
    # 64G budget: 40 vm (vfio-pinned) + ~1 qemu + 12 arc + ~11 host/slack
    kernelParams = ["zfs.zfs_arc_max=${toString (12 * 1024 * 1024 * 1024)}"];
  };

  users = {
    groups = {
      media.gid = ids.media;
      documents.gid = ids.documents;
      backup.gid = ids.backup;
    };
    users.backup = {
      uid = ids.backup;
      group = "backup";
      isSystemUser = true;
      useDefaultShell = true;
      openssh.authorizedKeys.keys = lib.flatten (lib.mapAttrsToList (target: map (recvOnly target)) pushers);
    };
  };

  services = {
    nfs.server = {
      enable = true;
      exports = lib.concatStringsSep "\n" (lib.mapAttrsToList exportLine exported);
    };
    nfs.settings.nfsd = {
      vers3 = false;
      udp = false;
      threads = 16;
    };

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
        "tank/home/shared/landfill" = {
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

    smartd.enable = true;

    prometheus.exporters = {
      node.enable = true;
      smartctl.enable = true;
      zfs.enable = true;
    };
  };

  systemd.services.zfs-datasets = {
    wantedBy = ["multi-user.target"];
    requiredBy = ["nfs-server.service"];
    after = ["zfs-mount.service"];
    before = ["nfs-server.service"];
    path = [config.boot.zfs.package];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = lib.concatStrings (lib.mapAttrsToList ensure datasets);
  };
}
