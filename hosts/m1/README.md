# m1

It's called Media 1 (m1), because it's different from compute nodes. The host directly manages NFS and virtualizes a Talos VM using [NixVirt](https://github.com/AshleyYakeley/NixVirt). Most of it was modeled after existing Proxmox hosts.

## Data resiliency

At the m1 node-level, data stored in the NAS is backed up using two separate mechanisms:

- Sanoid snapshots using Copy on Write (CoW) within ZFS, kind of like how BTRFS takes snapshots, and;
- Restic snapshots are deduplicated, encrypted, and pushed off-site to Backblaze using a secret without write capability, i.e. into a locked S3 bucket

For frequency of snapshots, see individual nix files.

At the cluster level (home-infra, which is in the process of being migrated here), data is backed up using volsync and kopia, also off-site to Backblaze but in this case streamed (from what I remember).

### Using ZFS snapshots

**Working with snapshots**
```sh
# List all available pools and tanks
zfs list

# List all available snapshots
zfs list -t snapshot
```

### Using restic 

**Restore using snapshots**
```sh
# list snapshots
restic-tank snapshots

# restore snapshot to a staging dir
restic-tank restore <id> --target /tank/restore

# restore one path to a staging dir
restic-tank restore <id> --target /tank/restore --include /tank/home/liana/some/file

# restore latest
restic-tank restore latest --path /tank/home --target /tank/restore

```

**Browse snapshot data**

```sh
# browse snapshots as directories
restic-tank mount /mnt/restic

# stream a file
restic-tank dump <id> /tank/home/liana/some/file > restored-file
```

### Using zpool

**Replacing a failed boot drive**
```sh
# List boot drives and validate which drive failed
zpool status rpool

# Reformat the new disk
TODO, reference disko

# Resilver
zpool replace rpool <old-zfs-partition> /dev/disk/by-id/<new-disk>-part2

# Rebuild
mount /boot<number>
nixos-rebuild boot --flake /nix/dotfiles#m1
```

**Replacing a failed spinning disk**
```sh
# View tank status
zpool status -v tank

# Replace the disk
zpool replace tank /dev/disk/by-id/ata-ST28000NM001C-<old> /dev/disk/by-id/ata-ST28000NM001C-<new>
```

## Deployment

### Initial install

Boot to a nixos-anywhere USB and, from a remote machine:

```sh
 nix run github:nix-community/nixos-anywhere -- \
    --flake /nix/dotfiles#m1 \
    --extra-files <dir for /var/lib/sops-nix/key.txt> \
    root@<ip>
```

### Creating zpools

The tank isn't declared in Nix, only datasets are.

```sh
# Create the tank from scratch
zpool create -o ashift=12 -O compression=zstd \
-O acltype=posixacl -O xattr=sa -O atime=off  \
tank mirror \
/dev/disk/by-id/ata-ST28000NM001C-<disk_A> \
/dev/disk/by-id/ata-ST28000NM001C-<disk_B>

# Idempotently declare datasets, quotas, permissions, etc.
systemctl start zfs-datasets

# If needed, restore data from off-site
restic-tank restore latest --path /tank/<some_tank> --target /tank/restore
```

## Maintenance

**Flake rebuilds**
```sh
nixos-rebuild switch --flake /nix/dotfiles#m1 --target-host liana@IP --sudo --ask-sudo-password
```

## Hardware architecture

**Processor**

i7 9700k

**Memory**

- DDR4 RAM. For a NAS, non-enterprise ECC would be nice (DDR5) but hey it works.
- Now that I'm writing this, I forgot to test the RAM. If you ever get around to it, use Memtest86+

**Storage**

- Dual boot drives are used, which are mirrored in case of boot drive failure.
- Currently, spinning disks are mirrored between the two disks, so if one drive fails we can re-order and re-silver. It's not ideal, but it works.
