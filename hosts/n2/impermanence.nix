{
  boot.initrd.systemd.services.rollback-root = {
    description = "Rollback root zfs dataset to @blank";
    wantedBy = ["initrd.target"];
    after = ["zfs-import-rpool.service"];
    before = ["sysroot.mount"];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = "zfs rollback -r rpool/root@blank";
  };

  environment.etc.machine-id.text = "c5ee4d3df9aa4ef490bf03b73520cb15\n";

  services.openssh.hostKeys = [
    {
      type = "ed25519";
      path = "/var/lib/ssh/ssh_host_ed25519_key";
    }
  ];
}
