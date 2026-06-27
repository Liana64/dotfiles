# @desc: journald config
{ ... }: {
  services.journald.extraConfig = ''
    Storage=persistent
    SystemMaxUse=1G
    SystemKeepFree=1G
    SystemMaxFileSize=128M
    MaxRetentionSec=1month
  '';
}
