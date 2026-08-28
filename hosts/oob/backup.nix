{config, ...}: {
  sops.secrets."backup/ssh-key".owner = config.services.syncoid.user;

  services.syncoid = {
    enable = true;
    interval = "daily";
    commands."rpool/var/unifi" = {
      target = "backup@m1:tank/backups/oob";
      sshKey = config.sops.secrets."backup/ssh-key".path;
      extraArgs = ["--no-sync-snap"];
    };
  };
}
