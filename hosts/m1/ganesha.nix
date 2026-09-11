{pkgs, ...}: let
  hardening = import ../../modules/_lib/systemd-hardening.nix;

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
    + export {
      id = 1;
      path = "/tank/media";
      squash = "Root_Squash";
      uid = 2000;
      access = "RW";
    }
    + export {
      id = 2;
      path = "/tank/backups/volsync";
      squash = "All_Squash";
      uid = 2200;
      access = "RW";
    }
    + export {
      id = 3;
      path = "/tank/home/photos";
      squash = "All_Squash";
      uid = 2100;
      access = "RW";
    });
in {
  systemd.services.nfs-ganesha = {
    wantedBy = ["multi-user.target"];
    requires = ["zfs-datasets.service"];
    after = ["zfs-datasets.service" "network.target"];
    serviceConfig =
      builtins.removeAttrs hardening.confined ["SystemCallFilter" "ProcSubset"]
      // {
        ExecStart = "${pkgs.nfs-ganesha}/bin/ganesha.nfsd -F -L STDERR -f ${conf} -p /run/ganesha/pid";
        Restart = "on-failure";
        RestartSec = 5;
        RuntimeDirectory = "ganesha";
        StateDirectory = "nfs/ganesha";
        TemporaryFileSystem = "/tank";
        BindPaths = [
          "/tank/media"
          "/tank/backups/volsync"
          "/tank/home/photos"
        ];
        # per-op impersonation of squashed uids: outside @system-service
        SystemCallFilter = [
          "@system-service"
          "setfsuid"
          "setfsgid"
          "setgroups"
          "capset"
        ];
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE CAP_SETUID CAP_SETGID CAP_CHOWN CAP_FOWNER CAP_DAC_OVERRIDE CAP_DAC_READ_SEARCH CAP_SYS_RESOURCE";
        RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK"];
      };
  };
}
