# Keychron Q11 firmware (ANSI + knob)

Custom QMK keymap for the split Q11, built and flashed with the `keychron-q11`
command. That command is provided to every Linux host via
[`home/linux/keychron-q11.nix`](../../home/linux/keychron-q11.nix), which wraps
the script in [`modules/linux/bin/keychron-q11`](../../modules/linux/bin/keychron-q11).

The layout follows the Framework laptop modifier row
(`Ctrl, Fn, Super, Alt │ Alt, Fn, Super`). Both slider positions carry the same
layout — the Linux position (`WIN_BASE`) is a copy of the Mac position
(`MAC_BASE`). On the Mac position only, a layer-scoped key override turns
`Ctrl+Tab` into `Cmd+Tab` and `Ctrl+Shift+Tab` into `Cmd+Shift+Tab`; the Linux
position keeps plain `Ctrl+Tab`. The slider silkscreen still reads "Mac /
Windows" — that legend can't be changed in firmware, so read "Windows" as Linux.

Build:

```sh
keychron-q11 build              # -> ./keychron_q11_ansi_encoder_liana.bin
```

Pin the QMK revision for reproducibility with `QMK_REV=<tag> keychron-q11 build`
(defaults to `master`; the keymap uses the current `RM_*` RGB-matrix keycodes, so
use a recent QMK).

The Q11 is split with no master half: flash each side individually over its own
USB-C port with the same `.bin`. Pop a half's space-bar keycap, hold the reset
button next to the switch, plug that half in (it enumerates as STM32 DFU), then:

```sh
keychron-q11 flash keychron_q11_ansi_encoder_liana.bin
```

Repeat on the other half. (The stock `Fn + J + Z` factory-reset chord is a
Keychron-firmware feature and does nothing on this build; to clear settings,
just reflash.) DFU over USB needs udev access — on NixOS,
`services.udev.packages = [ pkgs.qmk-udev-rules ];`.

## Recovery

A bad keymap can't brick the board: the STM32L432 DFU bootloader lives in mask
ROM and is entered by hardware (reset button + replug), so flashing only ever
touches application flash and DFU is always reachable.

- Bad layout, still enumerates — rebuild and reflash both halves.
- A half misbehaves — force DFU (hold reset, plug in); `lsusb` shows `0483:df11`,
  then reflash.
- Roll back — keep the last working `.bin`, or `git checkout` a known-good commit
  of this dir and rebuild; flash both halves.
- Back to factory — flash Keychron's stock Q11 `.bin` (keychron.com → Q11
  firmware) the same way, restoring VIA. Keychron Launcher or QMK Toolbox also work.
- `dfu-util` can't see it — check the udev rules, try another port/cable, and hold
  reset until it enumerates.
