# oob — UniFi controller (Raspberry Pi 5)

UniFi Network via `services.unifi` (`mongodb-ce` — the upstream aarch64
binary; MongoDB ≥5.0 needs ARMv8.2-A, so this workload fits a Pi 5's A76
but would crash on a Pi 4's A72). GUI at `https://oob:8443`; devices reach
inform on 8080, STUN 3478/udp, discovery 10001/udp. Runs on
`nixpkgs-unstable` (26.05 images lack Pi 5-family boot files) with the
`nixos-hardware` rpi5 profile, but on the **mainline** kernel, not the
profile's rpi vendor default: `bcm2712_defconfig` is 16K-pages and mongod's
aarch64 binaries require 4K (the same trap Pi OS solves with
`kernel=kernel8.img`). Mainline covers everything this headless host uses
(NVMe, RP1 ethernet, USB) and is hydra-cached.

Shared aspects (`modules/flake/hosts.nix`): `nixDaemon`, `time`, `users` —
everything else host-local; no home-manager.

## Layout

| Media | Managed by | Contents |
|---|---|---|
| SD `mmcblk0` | disko | `FIRMWARE` 512M vfat → `/boot/firmware` (EEPROM firmware, `config.txt`, u-boot — seeded once, see Install); `boot` ext4 → `/boot` (extlinux + generation kernels) |
| NVMe `nvme0n1` 238G | disko | `rpool`: `reserved` 10G / `root` / `nix` / `var` / `var/unifi` (controller db, sanoid 48h/30d/6m) / `home` |

Boot chain: EEPROM → `config.txt` + u-boot on `FIRMWARE` → extlinux on
`/boot` → root on `rpool`. Released U-Boot (v2026.07) cannot load extlinux
from NVMe on the Pi 5 (PCIe inbound DMA patches unmerged), so the boot
chain stays on SD — revisit single-disk boot when a fixed U-Boot lands.
The SD sees writes only on generation switches.

## Install

1. Flash the **unstable** generic aarch64 sd-image to a USB stick and boot
   the Pi from it (no SD inserted, or EEPROM boot order past it). From the
   console, add the fw-2026 key to `/root/.ssh/authorized_keys` and check
   the EEPROM is current enough to read GPT (`rpi-eeprom-update`).
2. Insert the target SD card. Mint the host's PQ age identity (secretstore
   README), add its recipient and rekey, then install with the key staged.
   Building happens on the Pi — the laptop is x86. `--phases` skips kexec
   (unsupported on the Pi) and the reboot (firmware isn't seeded yet):

   ```sh
   mkdir -p extra/var/lib/sops-nix && cp key.txt extra/var/lib/sops-nix/key.txt
   chmod 600 extra/var/lib/sops-nix/key.txt
   nix run github:nix-community/nixos-anywhere -- --flake /nix/dotfiles#oob \
     --phases disko,install --build-on-remote --extra-files extra root@<ip>
   ```

3. Seed the firmware partition before rebooting — disko leaves it empty.
   Both the USB stick's boot partition and the new SD one are labeled
   `FIRMWARE`, so mount by device, not label:

   ```sh
   mount /dev/sda1 /mnt-usb && mount /dev/mmcblk0p1 /mnt-sd
   cp -rT /mnt-usb /mnt-sd && umount /mnt-usb /mnt-sd
   ```

4. Remove the USB stick, reboot, prove sops decrypted:
   `ssh liana@oob sudo -v` (same failure mode as m1: ssh works but sudo is
   passwordless-dead, console is the only way back).
5. Adopt devices: point existing gear's inform URL at
   `http://oob:8080/inform`, or restore the previous controller's backup
   from the GUI on first run.

## Updates

```sh
nixos-rebuild switch --flake /nix/dotfiles#oob --target-host liana@oob \
  --build-host liana@oob --sudo --ask-sudo-password
```

Input updates via `/flake-update`. Rollback: pick a previous generation
from the u-boot/extlinux menu (serial console `ttyAMA10` or reflash-free
SD edit of `extlinux.conf` from another machine).

## Monitoring

Infra-level Grafana + Prometheus (`monitoring.nix`), deliberately outside
the k8s stack: cluster-hosted monitoring shares fate with m1 (host-down =
cluster-storage-down), so the infra view lives on the out-of-band box.
Grafana at `http://oob:3000` (admin password from sops); Prometheus is
loopback-only, 90d retention, scraping node/zfs/smartctl exporters here
and on m1 (its mgmt firewall already admits 9100/9134/9633). The k8s
prometheus keeps app/cluster scope — the two stacks stay disjoint.
Follow-up once the controller has a local read-only user: unpoller for
UniFi network metrics.

Required keys in `oob.yaml`: `users/liana/password`, `backup/ssh-key`,
`grafana/admin-password`.

## Backups

syncoid pushes `rpool/var/unifi` to `backup@m1:tank/backups/oob` daily
(`services.syncoid`, `backup.nix`) — same receive-only forced-command
account the framework uses, so a stolen oob key can receive but never
destroy history. Wiring it up once:

1. Mint a dedicated ed25519 keypair. Private key → `backup/ssh-key` in
   `oob.yaml` (secretstore); public key → the `oob` list in the `pushers`
   map in `hosts/m1/storage.nix`.
2. First push creates `tank/backups/oob/var/unifi` on m1 (`zfs receive -du`
   derives the path from the stream); m1's sanoid `backup` template prunes
   replicated snapshots there.

## Data safety

`nixos-rebuild switch` never formats; destructive paths are explicit
(`nixos-anywhere` full runs, disko format modes) and touch only this
host's SD + `rpool`. Controller state lives in `rpool/var/unifi` with
sanoid snapshots; UniFi's own scheduled backups land in
`/var/lib/unifi/data/backup` on the same dataset — for off-host recovery,
download a backup after major config changes. Firmware partition contents
are not managed by NixOS: EEPROM updates via `rpi-eeprom-update`, firmware
file refresh = re-seed from a current sd-image.
