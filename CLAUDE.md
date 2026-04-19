# CLAUDE.md

NixOS/home-manager dotfiles managed via Nix Flakes. Multi-host: Linux (x86_64 + aarch64) and macOS.

## Layout
- `flake.nix` — entry point. Defines `nixosConfigurations` (`framework`, `oob`) and `homeConfigurations` (`liana@framework`, `liana@oob`, `liana@small`).
- `hosts/<name>/` — per-host configs. `configuration.nix` (NixOS), `home.nix` (home-manager), `hardware-configuration.nix` (generated).
  - `framework` — x86_64-linux laptop using Ryzen AI 300 series CPU (active dev host), uses lanzaboote secure boot.
  - `oob` — aarch64-linux Raspberry Pi 4, headless.
  - `small` — aarch64-darwin macOS, home-manager standalone.
  - `coffee` — deprecated, not wired into the flake.
- `modules/` — NixOS (system) modules.
  - `modules/common/` — cross-platform system config + `colors/groove.nix` (injected as `colors` specialArg).
  - `modules/linux/` — Linux-specific system modules; `default.nix` imports siblings.
  - `modules/hardware/` — hardware-specific modules (framework, laptop, audio, boot, ssd, wireless); `default.nix` imports siblings.
- `home/` — home-manager modules.
  - `home/common/` — shared across OSes (git, kitty, nvim, shell/zsh, starship, atuin, k9s, anki, packages).
  - `home/linux/` — Linux-only user config (sway, waybar, mako, rofi, firefox, etc.); `default.nix` imports `../common` + siblings.
- `scripts/install.sh` — legacy, not used with flakes.
- `wallpapers/`, `.local/` — assets.

## Conventions
- One feature per `.nix` file; `default.nix` aggregates siblings.
- `specialArgs`/`extraSpecialArgs` pass `inputs`, `nixpkgs-unstable`, and `colors` (from `groove.nix`) to all modules.
- User is `liana`, email `liana@lianas.org` (hardcoded in `home/common/git.nix`).
- Wayland stack: sway + waybar + mako + rofi.
- NixOS `stateVersion = "23.05"`; home-manager `stateVersion = "25.11"`. Do not change.

## Build / apply
- System: `nh os switch ~/.dotfiles`

## Notes for agents
- `.gitignore` ignores `lazy-lock.json`, `.DS_Store`, `.env`.
- `README.MD` and `TODO.md` are minimal; do not rely on them for context.
- When adding a new module, create the `.nix` file under the appropriate dir and add it to the relevant `default.nix` imports list.
- Prefer editing existing module files over creating new ones; only split out a new file when the feature is genuinely separate.
- Do not build without first explicitly asking
