{
  config,
  inputs,
  pkgs,
  ...
}: let
  inherit (inputs.self.network) cluster;
  gib = n: n * 1024 * 1024 * 1024;
  attic-push = pkgs.writeShellScriptBin "attic-push" ''
    [ $# -gt 0 ] || set -- $OUT_PATHS
    XDG_CONFIG_HOME=/var/secrets exec ${pkgs.attic-client}/bin/attic push ${cluster.atticCache} "$@"
  '';
in {
  environment.systemPackages = [attic-push];
  motd.commands = [["sudo attic-push <paths>" "attic push"]];

  sops = {
    secrets."attic/push-token" = {};
    templates."attic.toml" = {
      path = "/var/secrets/attic/config.toml";
      mode = "0400";
      content = ''
        default-server = "m1"

        [servers.m1]
        endpoint = "http://${cluster.hosts.m1}:${toString cluster.atticPort}/"
        token = "${config.sops.placeholder."attic/push-token"}"
      '';
    };
  };

  nix = {
    daemonCPUSchedPolicy = "batch";
    daemonIOSchedClass = "idle";
    settings = {
      max-jobs = 2;
      cores = 4;
      min-free = gib 10;
      max-free = gib 30;
      post-build-hook = "${attic-push}/bin/attic-push";
    };
  };

  systemd.services.nix-daemon.serviceConfig = {
    MemoryHigh = "6G";
    MemoryMax = "8G";
  };
}
