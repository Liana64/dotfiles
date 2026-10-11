{
  config,
  lib,
  pkgs,
  hardening,
  inputs,
  ...
}: let
  net = inputs.self.network;
  meta = "/rpool/seaweedfs";
  data = "/tank/cluster/s3";
  weed = "${pkgs.seaweedfs}/bin/weed";

  ports = {
    master = 9333;
    volume = 8080;
    filer = 8888;
    s3 = 8333;
    metrics = 9327;
  };
  internal = lib.concatMap (p: [p (p + 10000)]) [ports.master ports.volume ports.filer];

  store = dir:
    pkgs.linkFarm "seaweedfs-store" {
      "filer.toml" = (pkgs.formats.toml {}).generate "filer.toml" {
        leveldb2 = {
          enabled = true;
          inherit dir;
        };
      };
    };

  options = name: attrs: pkgs.writeText "${name}.options" (lib.generators.toKeyValue {} attrs);

  server = options "server" {
    ip = "127.0.0.1";
    "ip.bind" = "127.0.0.1";
    "master.port" = ports.master;
    "volume.port" = ports.volume;
    "filer.port" = ports.filer;
    s3 = true;
    "s3.ip.bind" = net.cluster.hosts.m1;
    "s3.port" = ports.s3;
    "s3.config" = config.sops.secrets."seaweedfs/s3-config".path;
    filer = true;
    "master.dir" = "${meta}/master";
    "master.volumeSizeLimitMB" = 1024;
    dir = data;
    "volume.max" = 2000;
    metricsIp = net.cluster.hosts.m1;
    metricsPort = ports.metrics;
  };

  backup = options "meta-backup" {
    filer = "127.0.0.1:${toString ports.filer}";
    config = "${store "${data}/meta"}/filer.toml";
    restart = true;
  };

  unit = after: binds: exec: {
    wantedBy = ["multi-user.target"];
    requires = ["zfs-datasets.service"] ++ after;
    after = ["zfs-datasets.service" "network.target"] ++ after;
    serviceConfig =
      hardening.confined
      // {
        ExecStart = exec;
        User = "seaweedfs";
        Group = "seaweedfs";
        Restart = "on-failure";
        RestartSec = 5;
        TemporaryFileSystem = "/tank /rpool";
        BindPaths = binds;
      };
  };
in {
  sops.secrets."seaweedfs/s3-config".owner = "seaweedfs";

  networking.firewall = {
    interfaces.cluster.allowedTCPPorts = [ports.s3 ports.metrics];
    extraCommands = ''
      iptables -w -N seaweedfs-lo 2>/dev/null || iptables -w -F seaweedfs-lo
      iptables -w -A seaweedfs-lo -p tcp --syn -m multiport --dports ${lib.concatMapStringsSep "," toString internal} \
        -m owner ! --uid-owner ${toString config.users.users.seaweedfs.uid} -j REJECT --reject-with tcp-reset
      iptables -w -C OUTPUT -o lo -j seaweedfs-lo 2>/dev/null || iptables -w -A OUTPUT -o lo -j seaweedfs-lo
    '';
  };

  systemd.services = {
    seaweedfs = lib.recursiveUpdate (unit [] [meta data] "${weed} -logtostderr server -options=${server}") {
      preStart = "mkdir -p ${meta}/master ${meta}/filer ${data}/meta";
      serviceConfig.WorkingDirectory = store "${meta}/filer";
    };
    seaweedfs-meta-backup = lib.recursiveUpdate (unit ["seaweedfs.service"] ["${data}/meta"] "${weed} -logtostderr filer.meta.backup -options=${backup}") {
      serviceConfig.Restart = "always";
    };
  };
}
