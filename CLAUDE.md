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
- `specialArgs`/`extraSpecialArgs` carry `inputs`, `nixpkgs-unstable`, `colors`.
- User `liana`, email `liana@lianas.org` hardcoded in `home/common/git.nix`.
- `stateVersion`: NixOS `23.05`, home-manager `26.05`. Do not change.

## Build
- `nh os switch ~/.dotfiles`. Don't offer to build.
- Format: `nix fmt` (alejandra).

## Verify
After editing `.nix` files, check evaluation (no build, no switch):
- `nix eval .#nixosConfigurations.framework.config.system.build.toplevel.drvPath`
- `nix eval .#nixosConfigurations.portable.config.system.build.toplevel.drvPath`
- `nix eval .#homeConfigurations."liana@framework".activationPackage.drvPath`

New files must be `git add`ed before flake eval sees them.
