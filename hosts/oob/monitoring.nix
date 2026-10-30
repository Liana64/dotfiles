{
  inputs,
  lib,
  ...
}: let
  inherit (inputs.self.network) cluster;
  set = lib.concatStringsSep ", ";
in {
  services.prometheus.exporters = {
    node = {
      enable = true;
      enabledCollectors = ["systemd"];
    };
    smartctl.enable = true;
    zfs.enable = true;
  };

  networking.firewall.extraInputRules = ''
    ip saddr { ${set cluster.nodes} } tcp dport { 9100, 9134, 9199, 9633 } accept
  '';
}
