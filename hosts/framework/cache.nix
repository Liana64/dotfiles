{
  config,
  inputs,
  pkgs,
  ...
}: let
  inherit (inputs.self.network) cluster;
in {
  sops = {
    secrets."attic/token" = {};
    templates."attic.toml" = {
      path = "/var/secrets/attic/config.toml";
      mode = "0400";
      content = ''
        default-server = "m1"

        [servers.m1]
        endpoint = "http://${cluster.hosts.m1}:${toString cluster.atticPort}/"
        token = "${config.sops.placeholder."attic/token"}"
      '';
    };
  };

  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "attic-push";
      runtimeInputs = [pkgs.attic-client pkgs.coreutils];
      excludeShellChecks = ["SC2024"];
      text = ''
        dir=$(mktemp -d -p "$XDG_RUNTIME_DIR")
        trap 'rm -rf "$dir"' EXIT
        mkdir "$dir/attic"
        ${config.security.wrapperDir}/sudo ${pkgs.coreutils}/bin/cat ${config.sops.templates."attic.toml".path} > "$dir/attic/config.toml"
        XDG_CONFIG_HOME=$dir attic push ${cluster.atticCache} "$@"
      '';
    })
  ];
}
