# @desc: Ephemeral ZFS root: initrd rollback to rpool/root@blank, persisted host key
{
  flake.modules.nixos.zfsRollback = {
    boot.initrd.systemd.services.rollback-root = {
      description = "Rollback root zfs dataset to @blank";
      wantedBy = ["initrd.target"];
      after = ["zfs-import-rpool.service"];
      before = ["sysroot.mount"];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = "zfs rollback -r rpool/root@blank";
    };

    services.openssh.hostKeys = [
      {
        type = "ed25519";
        path = "/var/lib/ssh/ssh_host_ed25519_key";
      }
    ];
  };
}
