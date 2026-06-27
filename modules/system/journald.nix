# @desc: journald config
{...}: {
  flake.modules.nixos.journald = {...}: {
    services.journald.extraConfig = ''
      Storage=persistent
      SystemMaxUse=1G
      SystemKeepFree=1G
      SystemMaxFileSize=128M
      MaxRetentionSec=1month
    '';
  };
}
