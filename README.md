# nixops

Nixops, including my personal NixOS configuration. It's not SpectrumOS, or QubesOS, but it's something.


## Features

- Framework
  - Lightweight sway graphical environment with custom waybar
  - Landlock isolation using decentstate's [nix-housing](https://codeberg.org/decentstates/nix-housing)
  - Systemd hardening, kernel tuning, auditd rules, wall alerts, faillock, and usbguard
  - Compartmentalized post-quantum secrets management
  - Hardware optimizations for the AMD AI 300 series framework laptop
  - Minimal packaging, rust tools, virtualization support
  - Lots of misc scripts
  - Impermanence
- Other hosts

## Demo

![Framework host](docs/screenshot.png)

## TODO

- nix-daemon hardening
