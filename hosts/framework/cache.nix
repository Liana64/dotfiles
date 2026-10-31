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
      path = "${config.users.users.liana.home}/.config/attic/config.toml";
      owner = "liana";
      mode = "0400";
      content = ''
        default-server = "m1"

        [servers.m1]
        endpoint = "http://${cluster.hosts.m1}:${toString cluster.atticPort}/"
        token = "${config.sops.placeholder."attic/token"}"
      '';
    };
  };

  environment.systemPackages = [pkgs.attic-client];
}
