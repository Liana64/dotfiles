# Module index

Map of leaf modules, generated from `# @desc:` comments by `nix run .#gen-index`;
`nix flake check` gates staleness. Consult before fanning out search agents.

<!-- BEGIN module-index -->
| File | Description |
| --- | --- |
| `modules/agentic/agentic.nix` | Claude Code config: hooks, settings, LSP, materialized agentic/ |
| `modules/features/tasks/reminders.nix` | Todoist due/overdue reminders (taskManager = todoist) |
| `modules/features/tasks/tasks.nix` | taskManager option (nixos) + Todoist app (home) |
| `modules/features/theme.nix` | Theme option + colors arg, across nixos + home |
| `modules/flake/agentic-index.nix` | Agentic map table generator + staleness check (nix run .#gen-agentic-index) |
| `modules/flake/budgets.nix` | Token-budget tripwires on always-loaded agentic artifacts |
| `modules/flake/checks.nix` | Flake checks: secrets-guard + ai-memory fixtures, shellcheck on the wrapped scripts |
| `modules/flake/devshells.nix` | Dev shells (nix develop .#infra|rust) — project toolchains kept off the global profile |
| `modules/flake/formatter.nix` | Code formatter (alejandra) |
| `modules/flake/hosts.nix` | Assembles nixosConfigurations + homeConfigurations from aspects |
| `modules/flake/index.nix` | Module index generator + staleness check (nix run .#gen-index) |
| `modules/flake/keychron.nix` | Keychron Q11 firmware builder/flasher (nix run .#keychron-q11) |
| `modules/flake/modules-option.nix` | Declares the dendritic aspect store flake.modules.<class>.<aspect> |
| `modules/graphical/desktop-packages.nix` | Linux-only user packages (GUI + desktop) |
| `modules/graphical/files.nix` | Thunar file manager |
| `modules/graphical/firefox.nix` | Firefox |
| `modules/graphical/mako.nix` | Mako notification daemon |
| `modules/graphical/obsidian.nix` | Obsidian |
| `modules/graphical/stylix.nix` | Stylix theming (home) |
| `modules/graphical/sway.nix` | Sway WM + session env vars |
| `modules/graphical/swaybg.nix` | swaybg wallpaper |
| `modules/graphical/swayidle.nix` | swayidle idle/lock daemon as a restarting user service |
| `modules/graphical/thunderbird.nix` | Thunderbird |
| `modules/graphical/vesktop.nix` | Vesktop (Discord) |
| `modules/graphical/vicinae.nix` | Vicinae launcher |
| `modules/graphical/waybar.nix` | Waybar status bar |
| `modules/graphical/wayland.nix` | compositor option (sway|niri) + Wayland session |
| `modules/graphical/zoom.nix` | Zoom (web client via Firefox) |
| `modules/hardware/audio.nix` | Audio mixer fixes (ALC285 internal mic) |
| `modules/hardware/boot.nix` | Boot configuration |
| `modules/hardware/framework.nix` | Framework AMD AI 300 hardware module + firmware |
| `modules/hardware/laptop.nix` | Laptop udev rules + power tuning |
| `modules/hardware/ssd.nix` | SSD tuning (fstrim) |
| `modules/hardware/wireless.nix` | Bluetooth + printing toggle |
| `modules/security/auditd.nix` | auditd audit logging |
| `modules/security/faillock.nix` | PAM faillock lockout for swaylock |
| `modules/security/gpg.nix` | GPG keys/config |
| `modules/security/hardening.nix` | Kernel hardening: polkit, rtkit, kernel params |
| `modules/security/keyring.nix` | GnuPG agent (SSH support) + gnome-keyring via PAM |
| `modules/security/log-flood.nix` | Log flood tripwire: journal/audit event-rate + journal near-cap alert into audit-wall |
| `modules/security/no-defaults.nix` | Strip default packages |
| `modules/security/noexec.nix` | noexec mounts — /dev/shm, /var/tmp, /var/log, /boot |
| `modules/security/secrets.nix` | sops-nix secrets from the PQ-encrypted secretstore repo |
| `modules/security/store-verify.nix` | Weekly nix store verify with tamper alert |
| `modules/security/usbguard.nix` | USBGuard device authorization |
| `modules/security/wireguard.nix` | WireGuard VPN |
| `modules/security/yubikey.nix` | YubiKey (PAM/U2F) |
| `modules/shell/aliases.nix` | Shell aliases (rust-tool replacements) |
| `modules/shell/anki.nix` | Anki spaced repetition |
| `modules/shell/atuin.nix` | Atuin shell history |
| `modules/shell/benchmarks.nix` | wifi-bench / bt-bench wrappers with bundled deps |
| `modules/shell/cli-packages.nix` | Cross-platform user CLI packages |
| `modules/shell/dice.nix` | Curated fortune file + dice wrapper |
| `modules/shell/frame.nix` | frame — global just runner for repo/system/hardware/ai tasks |
| `modules/shell/git.nix` | Git config; hardcodes user liana / email |
| `modules/shell/infra.nix` | infra — home-infra Taskfile runner with bare-name task resolution |
| `modules/shell/k9s.nix` | k9s Kubernetes TUI |
| `modules/shell/kitty.nix` | Kitty terminal |
| `modules/shell/nvim.nix` | Neovim config |
| `modules/shell/probe.nix` | probe — cluster-side connectivity checks through the netshoot pod |
| `modules/shell/shell.nix` | Zsh: history, completion, autosuggestion |
| `modules/shell/starship.nix` | Starship prompt |
| `modules/shell/taskwarrior.nix` | Taskwarrior + nested-task tooling |
| `modules/system/dconf.nix` | dconf/gsettings defaults |
| `modules/system/email.nix` | Protonmail Bridge |
| `modules/system/flatpak.nix` | Flatpak |
| `modules/system/fonts.nix` | System fonts |
| `modules/system/framework-dsp.nix` | EasyEffects DSP for Framework 13 speakers, bound to sway |
| `modules/system/journald.nix` | journald config |
| `modules/system/mime.nix` | Default applications per MIME type |
| `modules/system/networking.nix` | NetworkManager + nftables firewall |
| `modules/system/nix.nix` | Nix daemon: gc, optimise, flake registry |
| `modules/system/packages.nix` | System packages and base env vars (EDITOR, BROWSER) |
| `modules/system/syncthing.nix` | Syncthing |
| `modules/system/time.nix` | Timezone (America/Chicago) + i18n |
| `modules/system/users.nix` | User account liana (groups, zsh) |
| `modules/system/virtualization.nix` | Podman + qemu/skopeo |
| `modules/system/xdg-userdirs.nix` | XDG user directories |
<!-- END module-index -->
