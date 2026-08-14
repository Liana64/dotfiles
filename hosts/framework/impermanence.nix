# impermanence for framework, pairs with ./disko.nix
#
# DO NOT IMPORT THIS
# importing arms the /@root wipe on boot
# wait until the subvolumes and the readonly /@root-blank snapshot exist
# (docs/MIGRATION.md); arm together with `impermanence = true` in
# ./options.nix — that flips mutableUsers off and sources the password hash
# from sops (modules/system/impermanence.nix); the "hashedPassword" key must
# exist in the secretstore first
#
# two pieces: initrd rollback (/@root-blank → /@root) and the
# environment.persistence."/persist" list of what survives
#
# /home is a persistent subvolume, firefox/keyring/ssh/gpg/syncthing need nothing here
# /var/secrets needs nothing either, sops-nix re-materializes it each activation,
# only /var/lib/sops-nix (host identity) must survive
{inputs, ...}: {
  imports = [inputs.impermanence.nixosModules.impermanence];

  # snapshot /@root-blank → /@root once LUKS is open, before sysroot.mount
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

      # nested subvolumes (podman, systemd machines/portables) have to go first
      btrfs subvolume list -o /mnt/@root | cut -f9 -d' ' | while read -r sub; do
        btrfs subvolume delete "/mnt/$sub"
      done

      btrfs subvolume delete /mnt/@root
      btrfs subvolume snapshot /mnt/@root-blank /mnt/@root

      umount /mnt
    '';
  };

  # what survives the wipe, add sparingly, every entry is a place for stale state to hide
  environment.persistence."/persist" = {
    hideMounts = true;

    directories = [
      "/var/lib/nixos" # uid/gid/group allocation state
      "/var/lib/systemd" # timers, random-seed, backlight, etc.
      {
        directory = "/var/lib/private";
        mode = "0700";
      } # DynamicUser state, systemd insists on 0700
      "/var/lib/sops-nix" # PQ host identity — without it no secret decrypts
      "/var/lib/sbctl" # lanzaboote signing keys — loss = unbootable under secure boot
      "/var/lib/fprint" # fingerprint enrollments
      "/var/lib/audit-wall" # ack timestamps; loss re-alerts stale events
      "/var/lib/usbguard" # IPCAccessControl.d (daemon conf points here)
      "/var/lib/cni" # container network allocations
      "/var/lib/btrfs" # scrub progress + stats
      "/var/lib/chrony" # clock drift + NTS state
      "/var/lib/NetworkManager" # wifi connection profiles
      "/var/lib/bluetooth" # paired device keys
      "/var/lib/boltd" # thunderbolt device authorization (dir is boltd, not bolt)
      "/var/lib/fwupd" # firmware update metadata
      "/var/lib/flatpak" # flatpak-repo installs land here
      "/var/lib/upower" # battery history
      "/var/lib/power-profiles-daemon" # last selected profile
      "/var/lib/AccountsService" # user account icons/locale
      "/var/lib/colord" # display color profiles
      "/etc/NetworkManager/system-connections"
      "/etc/usbguard" # rules.conf — preStart regenerates only if absent
    ];

    files = [
      "/etc/machine-id" # journald continuity, sd-network
      "/var/lib/logrotate.status" # rotation timestamps
    ]; # no sshd on this host → no host keys to keep
  };

  # only matters if home-level binds ever appear, harmless until then
  programs.fuse.userAllowOther = true;
}
