# impermanence for deck — armed from install day: @root-blank is pristine
# from disko format time and the sops proof gates the install, so there is
# no unarmed generation to stage; recovery path is `portable` plus the
# /persist key copy
{inputs, ...}: {
  imports = [inputs.impermanence.nixosModules.impermanence];

  boot.initrd.systemd.services.rollback-root = {
    description = "Rollback root btrfs subvolume to @root-blank";
    wantedBy = ["initrd.target"];
    after = ["systemd-cryptsetup@cryptdeck.service"];
    before = ["sysroot.mount"];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /mnt
      mount -o subvol=/ /dev/mapper/cryptdeck /mnt

      btrfs subvolume list -o /mnt/@root | cut -f9 -d' ' | while read -r sub; do
        btrfs subvolume delete "/mnt/$sub"
      done

      btrfs subvolume delete /mnt/@root
      btrfs subvolume snapshot /mnt/@root-blank /mnt/@root

      umount /mnt
    '';
  };

  environment.persistence."/persist" = {
    hideMounts = true;

    directories = [
      "/var/lib/nixos"
      "/var/lib/systemd"
      "/var/lib/sops-nix"
      "/var/lib/bluetooth"
      "/var/lib/NetworkManager"
      "/var/lib/fprint"
      "/var/lib/fwupd"
      "/var/lib/boltd"
      "/etc/NetworkManager/system-connections"
    ];

    files = ["/etc/machine-id"];
  };
}
