# CLAUDE.md

NixOS + home-manager dotfiles via Nix Flakes.

## Design
- Use stylix theming for component design and lib.mkForce when applicable.
- Hardening (kernel params, usbguard, portal masking, module blacklists) is intentional. Don't relax it to fix symptoms. Prove any per-unit exception minimal with `hardening-probe <preset> [--sweep] -- <cmd>`.

Structured as the **dendritic pattern** (flake-parts + `vic/import-tree`): every `.nix` under `modules/` is a flake-parts module, auto-imported.

## Layout
- `flake.nix` — inputs + a one-line `mkFlake (import-tree ./modules)`; logic here would bypass import-tree.
- `modules/` — the dendritic tree. A leaf registers config under `flake.modules.<class>.<aspect>` (`class` = `nixos` | `homeManager`); the same aspect from many files merges. No `default.nix` aggregators — adding a file is enough.
  - `modules/flake/` — plumbing: `hosts.nix` (assembles the configs), `modules-option.nix` (declares the aspect store), `keychron`/`index`/`formatter`/`checks`.
  - `modules/{hardware,security,graphical,shell,system}/` — feature aspects grouped by domain (navigation only; import loads them all). A file may declare both a `nixos.*` and a `homeManager.*` aspect.
  - `modules/features/` — cross-class cells: `theme` (theme option + `colors` arg), `tasks` (taskManager option + todoist).
  - `modules/agentic/` — the Claude Code config module **and** its materialized content (`AGENTS.md` → `~/.claude/CLAUDE.md`, `agents/*.md`, `skills/<name>/SKILL.md`). Owns all Claude Code config (MCP, settings, hooks, statusline, LSP). `~/.claude/settings.json` is a read-only store symlink — change it here. Edits apply only after a home-manager switch.
  - `modules/bin/` — shell scripts wrapped into derivations (non-`.nix`, so import-tree ignores them). `modules/_lib/` + any `/_` path — data/library files (colors, k9s/taskwarrior data, systemd-hardening) and disabled modules; import-tree skips every path containing `/_`.
- `hosts/<name>/` — thin, NOT auto-imported: `hardware-configuration.nix` + `options.nix` (hostname, password, theme/compositor/taskManager); the shared home base (`hmShared`) lives in `modules/flake/hosts.nix`. Both hosts run on the same Framework laptop; `portable` is an option-variant, so both import *all* aspects and differ only via options.
- `embedded/keychron-q11/` — QMK keymap. Build/flash on demand: `nix run .#keychron-q11`.

## Staged, not wired
Inert by design — do not import or "fix":
- `hosts/framework/{disko,impermanence}.nix` — impermanence migration plan. Disk is shared with a Bazzite install; see file headers for hazards. (Outside `modules/`, so never auto-imported.)
- `/_`-prefixed paths under `modules/` (e.g. `graphical/_drawio.nix`, `graphical/_niri.nix`, `graphical/_element.nix`) — disabled modules kept for recovery; import-tree skips them. All predate the dendritic migration: revival needs the `flake.modules` wrapper (plus, for `_niri`, its commented-out flake input), not just a rename.

## Conventions
- One feature per file; wrap the body as `flake.modules.<class>.<aspect> = <module>`. Disable a module by prefixing its path with `_`. `/new-module` scaffolds a leaf plus its gates (git add, gen-index, verify).
- Keep `# @desc: <one line>` as the first line, above the wrapper; it feeds the Module index below.
- Aspects get `inputs`/`nixpkgs-unstable` via `specialArgs`/`extraSpecialArgs` (set in `modules/flake/hosts.nix`); `colors` flows from the `theme` cell via `_module.args`.
- User `liana`, email `liana@lianas.org` hardcoded in `modules/shell/git.nix`.
- `stateVersion`: NixOS `23.05`, home-manager `26.05`. Do not change.

## Build
- `nh os switch ~/.dotfiles`. Don't offer to build.
- `/flake-update` updates inputs with staged verification (lock diff → eval → checks → build scope); it never switches.
- Format/lint: `.nix` edits auto-format and lint in place via the `claude-nix-check` PostToolUse hook (alejandra, statix, deadnix; `statix.toml` disables lints that fight house style). `nix fmt` is for bulk reformatting only (and fails on the staged `impermanence.nix` — format files explicitly instead).

## Verify
After editing `.nix` files, check evaluation (no build, no switch) with `dotfiles-verify`.
It evaluates all four configs and prints `framework ✓ portable ✓ liana@framework ✓ liana@portable ✓`, or the
failing target with a trimmed trace. New files must be `git add`ed before flake eval sees them (the script warns).
`nix flake check` additionally gates the module index, the secrets-guard fixture, and shellcheck on all `modules/bin` scripts.
After a switch that adds systemd units, fire oneshots once (`systemctl --user start <unit>`) — passing eval doesn't prove a unit starts.

## Module index
Map of leaf modules, generated from `# @desc:` comments by `nix run .#gen-index`; `nix flake check` gates staleness. Consult it before fanning out search agents.
<!-- BEGIN module-index -->
| File | Description |
| --- | --- |
| `modules/agentic/agentic.nix` | Claude Code config: hooks, settings, LSP, materialized agentic/ |
| `modules/features/tasks.nix` | taskManager option (nixos) + Todoist app (home) |
| `modules/features/theme.nix` | Theme option + colors arg, across nixos + home |
| `modules/flake/checks.nix` | Flake checks: secrets-guard fixture + shellcheck on the wrapped scripts |
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
| `modules/security/usbguard.nix` | USBGuard device authorization |
| `modules/security/wireguard.nix` | WireGuard VPN |
| `modules/security/yubikey.nix` | YubiKey (PAM/U2F) |
| `modules/shell/aliases.nix` | Shell aliases (rust-tool replacements) |
| `modules/shell/anki.nix` | Anki spaced repetition |
| `modules/shell/atuin.nix` | Atuin shell history |
| `modules/shell/benchmarks.nix` | wifi-bench / bt-bench wrappers with bundled deps |
| `modules/shell/cli-packages.nix` | Cross-platform user CLI packages |
| `modules/shell/develop.nix` | Rust toolchain (cargo, rustc, clippy, rust-analyzer) |
| `modules/shell/dice.nix` | Curated fortune file + dice wrapper |
| `modules/shell/git.nix` | Git config; hardcodes user liana / email |
| `modules/shell/k9s.nix` | k9s Kubernetes TUI |
| `modules/shell/kitty.nix` | Kitty terminal |
| `modules/shell/nvim.nix` | Neovim config |
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
