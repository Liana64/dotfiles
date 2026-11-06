# DO NOT IMPORT before the disko migration, arming wipes /@root every boot
{
  inputs,
  lib,
  ...
}: {
  imports = [inputs.impermanence.nixosModules.impermanence];

  sops.age.keyFile = "/persist/var/lib/sops-nix/key.txt";
  sops.secrets."network/nm-secret-key".path = lib.mkForce "/persist/var/lib/NetworkManager/secret_key";

  boot.initrd.systemd.services.rollback-root = {
    description = "Rollback root btrfs subvolume to @root-blank";
    wantedBy = ["initrd.target"];
    after = ["systemd-cryptsetup@cryptroot.service"];
    before = ["sysroot.mount"];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /mnt
      mount -o subvol=/ /dev/mapper/cryptroot /mnt

      mkdir -p /mnt/@old-roots
      if [ -e /mnt/@root ]; then
        gen=$(btrfs subvolume find-new /mnt/@root 9999999)
        mv /mnt/@root "/mnt/@old-roots/''${gen##* }"
      fi
      ls /mnt/@old-roots | sort -rn | tail -n +31 | while read -r old; do
        btrfs subvolume delete --recursive "/mnt/@old-roots/$old"
      done

      btrfs subvolume snapshot /mnt/@root-blank /mnt/@root

      umount /mnt
    '';
  };

  environment.persistence."/persist" = {
    hideMounts = true;

    directories = [
      "/var/lib/nixos"
      "/var/lib/systemd"
      {
        directory = "/var/lib/private";
        mode = "0700";
      }
      "/var/lib/sbctl"
      "/var/lib/fprint"
      "/var/lib/audit-wall"
      "/var/lib/usbguard"
      "/var/lib/cni"
      "/var/lib/btrfs"
      "/var/lib/chrony"
      "/var/lib/NetworkManager"
      "/var/lib/bluetooth"
      "/var/lib/boltd"
      "/var/lib/fwupd"
      "/var/lib/flatpak"
      "/var/lib/upower"
      "/var/lib/power-profiles-daemon"
      "/var/lib/AccountsService"
      "/var/lib/colord"
      "/etc/NetworkManager/system-connections"
    ];

    files = [
      "/etc/machine-id"
      "/var/lib/logrotate.status"
    ];
  };
}
