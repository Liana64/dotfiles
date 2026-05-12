# CLAUDE.md

NixOS + home-manager dotfiles via Nix Flakes.

## Layout
- `flake.nix` — entry point. `nixosConfigurations`: `framework`, `portable`, `oob`. `homeConfigurations`: `liana@{framework,portable,oob,small}`.
- `hosts/<name>/` — `configuration.nix`, `home.nix`, `hardware-configuration.nix`.
  - `framework` — active dev host. x86_64-linux, Ryzen AI 300, lanzaboote.
  - `portable` — x86_64-linux secondary.
  - `oob`, `small` — deprecated, ignore.
- `modules/{common,linux,hardware}/` — NixOS modules. `modules/common/colors/blueberry.nix` is injected as the `colors` specialArg.
- `home/{common,linux}/` — home-manager modules. `home/linux/default.nix` imports `../common`.
- `agentic/` — materialized into `~/.claude/` by `home/linux/agentic.nix`: `CLAUDE.md` → global user CLAUDE.md, `system/*.md` → `~/.claude/agents/`.

## Conventions
- One feature per `.nix`; `default.nix` aggregates siblings. New module → add to the relevant `default.nix`.
- `specialArgs`/`extraSpecialArgs` carry `inputs`, `nixpkgs-unstable`, `colors`.
- User `liana`, email `liana@lianas.org` hardcoded in `home/common/git.nix`.
- `stateVersion`: NixOS `23.05`, home-manager `25.11`. Do not change.

## Build
- `nh os switch ~/.dotfiles`. Ask before building.

## Stale, ignore
- `README.MD`, `TODO.md`, `scripts/install.sh`.
