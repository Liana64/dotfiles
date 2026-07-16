# @desc: journald config
{...}: {
  flake.modules.nixos.journald = {...}: {
    services.journald.extraConfig = ''
      Storage=persistent
      SystemMaxUse=1G
      SystemKeepFree=1G
      SystemMaxFileSize=128M
      MaxRetentionSec=1month
      Audit=no
    '';
    # journald mirrors every audit record otherwise, auditd already keeps them
    systemd.sockets.systemd-journald-audit.enable = false;
  };
}
