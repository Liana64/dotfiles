# @desc: journald config
{...}: {
  flake.modules.nixos.journald = {
    lib,
    options,
    ...
  }: let
    journal = {
      Storage = "persistent";
      SystemMaxUse = "1G";
      SystemKeepFree = "1G";
      SystemMaxFileSize = "128M";
      MaxRetentionSec = "1month";
      Audit = "no";
    };
  in {
    services.journald =
      if options.services.journald ? settings
      then {settings.Journal = journal;}
      else {extraConfig = lib.generators.toKeyValue {} journal;};
    # journald mirrors every audit record otherwise, auditd already keeps them
    systemd.sockets.systemd-journald-audit.enable = false;
  };
}
