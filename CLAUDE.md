# CLAUDE.md

NixOS + home-manager dotfiles via Nix Flakes.

## Design
- Use stylix theming for component design and lib.mkForce when applicable.
- Hardening (kernel params, usbguard, portal masking, module blacklists) is intentional. Don't relax it to fix symptoms.

## Layout
- `flake.nix` — entry point. `nixosConfigurations`: `framework`, `portable`. `homeConfigurations`: `liana@{framework,portable}`.
- `hosts/<name>/` — thin: hostname, password, hardware-configuration, host deviations. Anything shared by both hosts belongs in `modules/`.
  - `framework` — active dev host. x86_64-linux, Ryzen AI 300, lanzaboote.
  - `portable` — x86_64-linux secondary.
- `modules/{common,linux,hardware}/` — NixOS modules. `modules/common/colors/blueberry.nix` is injected as the `colors` specialArg.
  - Known debt: `modules/hardware/` is imported by both hosts but bakes in Framework-specific config.
- `home/{common,linux}/` — home-manager modules. `home/linux/default.nix` imports `../common`.
- `agentic/` — materialized into `~/.claude/` by `home/linux/agentic.nix`: `AGENTS.md` → global user `~/.claude/CLAUDE.md`, `agents/*.md` → `~/.claude/agents/`, `skills/<name>/SKILL.md` → `~/.claude/skills/<name>/`. Edits take effect only after a home-manager switch.
  - `home/linux/agentic.nix` also owns all Claude Code config: MCP servers, settings, hooks, statusline, LSP servers. `~/.claude/settings.json` is a read-only store symlink — change it here, not in `~/.claude/`.
- `embedded/keychron-q11/` — QMK keymap. Build/flash on demand: `nix run .#keychron-q11`.

## Staged, not wired
Inert by design — do not import or "fix":
- `hosts/framework/{disko,impermanence}.nix` — impermanence migration plan. Disk is shared with a Bazzite install; see file headers for hazards.
- `modules/common/systemd-hardening.nix` — commented import in `modules/linux/default.nix`.

## Conventions
- One feature per `.nix`; `default.nix` aggregates siblings. New module → add to the relevant `default.nix`.
- Give each leaf module a first-line `# @desc: <one line>` comment; it feeds the Module index below.
- `specialArgs`/`extraSpecialArgs` carry `inputs`, `nixpkgs-unstable`, `colors`.
- User `liana`, email `liana@lianas.org` hardcoded in `home/common/git.nix`.
- `stateVersion`: NixOS `23.05`, home-manager `26.05`. Do not change.

## Build
- `nh os switch ~/.dotfiles`. Don't offer to build.
- Format: `.nix` edits auto-format in place via the `claude-nix-fmt` PostToolUse hook (alejandra). `nix fmt` is for bulk reformatting only.

## Verify
After editing `.nix` files, check evaluation (no build, no switch) with `dotfiles-verify`.
It evaluates all three configs and prints `framework ✓ portable ✓ liana@framework ✓`, or the
failing target with a trimmed trace. New files must be `git add`ed before flake eval sees them.

## Module index
Map of leaf modules, generated from `# @desc:` comments by `nix run .#gen-index`; `nix flake check` gates staleness. Consult it before fanning out search agents.
<!-- BEGIN module-index -->
| File | Description |
| --- | --- |
| `home/common/anki.nix` | Anki spaced repetition |
| `home/common/atuin.nix` | Atuin shell history |
| `home/common/develop.nix` | Rust toolchain (cargo, rustc, clippy, rust-analyzer) |
| `home/common/dice.nix` | Curated fortune file + dice wrapper |
| `home/common/git.nix` | Git config; hardcodes user liana / email |
| `home/common/k9s.nix` | k9s Kubernetes TUI |
| `home/common/k9s/aliases.nix` | k9s command aliases |
| `home/common/k9s/plugins.nix` | k9s plugins (kubectl/flux actions) |
| `home/common/k9s/settings.nix` | k9s settings |
| `home/common/kitty.nix` | Kitty terminal |
| `home/common/nvim.nix` | Neovim config |
| `home/common/packages.nix` | Cross-platform user CLI packages |
| `home/common/shell.nix` | Zsh: history, completion, autosuggestion |
| `home/common/starship.nix` | Starship prompt |
| `home/common/taskwarrior/config.nix` | Taskwarrior config |
| `home/common/taskwarrior/hooks.nix` | Taskwarrior hooks |
| `home/common/taskwarrior/reminders.nix` | Taskwarrior due/overdue reminders |
| `home/common/theme.nix` | Resolves color palette from host theme into the colors arg |
| `home/linux/agentic.nix` | Claude Code config: hooks, settings, LSP, materialized agentic/ |
| `home/linux/aliases.nix` | Shell aliases (rust-tool replacements) |
| `home/linux/benchmarks.nix` | wifi-bench / bt-bench wrappers with bundled deps |
| `home/linux/dconf.nix` | dconf/gsettings defaults |
| `home/linux/element.nix` | Element Matrix client |
| `home/linux/firefox.nix` | Firefox |
| `home/linux/framework.nix` | EasyEffects DSP for Framework 13 speakers, bound to sway |
| `home/linux/gpg.nix` | GPG keys/config |
| `home/linux/mako.nix` | Mako notification daemon |
| `home/linux/mime.nix` | Default applications per MIME type |
| `home/linux/niri.nix` | Niri scrollable-tiling compositor |
| `home/linux/obsidian.nix` | Obsidian |
| `home/linux/packages.nix` | Linux-only user packages (GUI + desktop) |
| `home/linux/stylix.nix` | Stylix theming (home) |
| `home/linux/sway.nix` | Sway WM + session env vars |
| `home/linux/swaybg.nix` | swaybg wallpaper |
| `home/linux/syncthing.nix` | Syncthing |
| `home/linux/thunderbird.nix` | Thunderbird |
| `home/linux/todoist.nix` | Todoist (flatpak) |
| `home/linux/vesktop.nix` | Vesktop (Discord) |
| `home/linux/vicinae.nix` | Vicinae launcher |
| `home/linux/waybar.nix` | Waybar status bar |
| `home/linux/xdg-userdirs.nix` | XDG user directories |
| `home/linux/zoom.nix` | Zoom (web client via Firefox) |
| `modules/common/colors/blueberry.nix` | Color palette: blueberry |
| `modules/common/colors/carbon.nix` | Color palette: carbon |
| `modules/common/colors/milberry.nix` | Color palette: milberry |
| `modules/common/systemd-hardening.nix` | Staged systemd unit hardening (not imported) |
| `modules/common/theme.nix` | theme option + colors module arg (blueberry|milberry) |
| `modules/hardware/audio.nix` | Audio mixer fixes (ALC285 internal mic) |
| `modules/hardware/boot.nix` | Boot configuration |
| `modules/hardware/framework.nix` | Framework AMD AI 300 hardware module + firmware |
| `modules/hardware/laptop.nix` | Laptop udev rules + power tuning |
| `modules/hardware/ssd.nix` | SSD tuning (fstrim) |
| `modules/hardware/wireless.nix` | Bluetooth + printing toggle |
| `modules/linux/auditd.nix` | auditd audit logging |
| `modules/linux/drawio.nix` | drawio diagram editor |
| `modules/linux/email.nix` | Protonmail Bridge |
| `modules/linux/faillock.nix` | PAM faillock lockout for swaylock |
| `modules/linux/files.nix` | Thunar file manager |
| `modules/linux/flatpak.nix` | Flatpak |
| `modules/linux/fonts.nix` | System fonts |
| `modules/linux/hardening.nix` | Kernel hardening: polkit, rtkit, kernel params |
| `modules/linux/journald.nix` | journald config |
| `modules/linux/keyring.nix` | GnuPG agent (SSH support) + gnome-keyring via PAM |
| `modules/linux/networking.nix` | NetworkManager + nftables firewall |
| `modules/linux/nix.nix` | Nix daemon: gc, optimise, flake registry |
| `modules/linux/packages.nix` | System packages and base env vars (EDITOR, BROWSER) |
| `modules/linux/tasks.nix` | taskManager option (taskwarrior|todoist) surfaced in the bar |
| `modules/linux/time.nix` | Timezone (America/Chicago) + i18n |
| `modules/linux/usbguard.nix` | USBGuard device authorization |
| `modules/linux/users.nix` | User account liana (groups, zsh) |
| `modules/linux/virtualization.nix` | Podman + qemu/skopeo |
| `modules/linux/wayland.nix` | compositor option (sway|niri) + Wayland session |
| `modules/linux/wireguard.nix` | WireGuard VPN |
| `modules/linux/yubikey.nix` | YubiKey (PAM/U2F) |
<!-- END module-index -->
