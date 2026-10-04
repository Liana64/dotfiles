{
  pkgs,
  hardening,
  ...
}: let
  cluster = ["172.16.4.11" "172.16.4.12" "172.16.4.13" "172.16.4.14"];

  export = {
    id,
    path,
    squash,
    uid,
    access,
  }: ''
    EXPORT {
      Export_Id = ${toString id};
      Path = ${path};
      Pseudo = ${path};
      Access_Type = None;
      Squash = ${squash};
      Anonymous_Uid = ${toString uid};
      Anonymous_Gid = ${toString uid};
      SecType = sys;
      Protocols = 4;
      Transports = TCP;
      FSAL { Name = VFS; }
      CLIENT {
        Clients = ${builtins.concatStringsSep ", " cluster};
        Access_Type = ${access};
      }
    }
  '';

  exports = [
    {
      id = 1;
      path = "/tank/cluster/media";
      squash = "Root_Squash";
      uid = 2000;
      access = "RW";
    }
    {
      id = 2;
      path = "/tank/backups/volsync";
      squash = "All_Squash";
      uid = 2200;
      access = "RW";
    }
    {
      id = 3;
      path = "/tank/cluster/photos";
      squash = "All_Squash";
      uid = 2100;
      access = "RW";
    }
    {
      id = 4;
      path = "/tank/cluster/uploads";
      squash = "All_Squash";
      uid = 2300;
      access = "RW";
    }
  ];

  conf = pkgs.writeText "ganesha.conf" (''
      NFS_CORE_PARAM {
        Bind_addr = 172.16.4.30;
        NFS_Protocols = 4;
        Enable_NLM = false;
        Enable_RQUOTA = false;
        Enable_UDP = false;
      }
      NFSv4 {
        Minor_Versions = 1, 2;
        RecoveryBackend = fs;
      }
    ''
    + builtins.concatStringsSep "" (map export exports));
in {
  systemd.services.nfs-ganesha = {
    wantedBy = ["multi-user.target"];
    requires = ["zfs-datasets.service"];
    after = ["zfs-datasets.service" "network.target"];
    serviceConfig =
      removeAttrs hardening.confined ["SystemCallFilter" "ProcSubset"]
      // {
        ExecStart = "${pkgs.nfs-ganesha}/bin/ganesha.nfsd -F -L STDERR -f ${conf} -p /run/ganesha/pid";
        Restart = "on-failure";
        RestartSec = 5;
        RuntimeDirectory = "ganesha";
        StateDirectory = "nfs/ganesha";
        TemporaryFileSystem = "/tank";
        BindPaths = map (e: e.path) exports;
        SystemCallFilter = [
          "@system-service"
          "@chown"
          "setfsuid"
          "setfsgid"
          "setgroups"
          "capset"
          "name_to_handle_at"
          "open_by_handle_at"
          "quotactl"
        ];
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE CAP_SETUID CAP_SETGID CAP_CHOWN CAP_FOWNER CAP_DAC_OVERRIDE CAP_DAC_READ_SEARCH CAP_SYS_RESOURCE";
        UMask = "0000";
      };
  };
}
