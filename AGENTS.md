# CLAUDE.md

NixOS + home-manager dotfiles via Nix Flakes.

## Design
- Use stylix theming for component design and lib.mkForce when applicable.
- Hardening (kernel params, usbguard, portal masking, module blacklists) is intentional. Don't relax it to fix symptoms; the proof workflow lives in `modules/security/CLAUDE.md` (auto-loads when working there).

Structured as the **dendritic pattern** (flake-parts + `vic/import-tree`): every `.nix` under `modules/` is a flake-parts module, auto-imported.

## Layout
- `flake.nix` — inputs + a one-line `mkFlake (import-tree ./modules)`; logic here would bypass import-tree.
- `modules/` — the dendritic tree. A leaf registers config under `flake.modules.<class>.<aspect>` (`class` = `nixos` | `homeManager`); the same aspect from many files merges. No `default.nix` aggregators — adding a file is enough. **Module index: `modules/README.md`** — consult it before exploring or fanning out search agents.
  - `modules/flake/` — plumbing: `hosts.nix` (assembles the configs), `modules-option.nix` (declares the aspect store), plus generators, checks, budgets, devshells — see the index.
  - `modules/{hardware,security,graphical,shell,system}/` — feature aspects grouped by domain (navigation only; import loads them all). A file may declare both a `nixos.*` and a `homeManager.*` aspect.
  - `modules/features/` — cross-class cells: `theme` (theme option + `colors` arg), `tasks` (taskManager option + todoist).
  - `modules/agentic/` — the Claude Code config module **and** its materialized content (`AGENTS.md` → `~/.claude/CLAUDE.md`, agents, skills). Owns all Claude Code config; `~/.claude` is a read-only materialization — change it here, applies after a home-manager switch. System map: `modules/agentic/README.md` — read it instead of exploring this module.
  - `modules/bin/` — shell scripts wrapped into derivations (non-`.nix`, so import-tree ignores them); conventions in `modules/bin/CLAUDE.md`. `modules/_lib/` + any `/_` path — data/library files and disabled modules; import-tree skips every path containing `/_`.
- `hosts/<name>/` — thin, NOT auto-imported: `hardware-configuration.nix` + `options.nix` (hostname, password, theme/compositor/taskManager); the shared home base (`hmShared`) lives in `modules/flake/hosts.nix`. Both hosts run on the same Framework laptop; `portable` is an option-variant, so both import *all* aspects and differ only via options.
- `embedded/keychron-q11/` — QMK keymap. Build/flash on demand: `nix run .#keychron-q11`.

## Staged, not wired
Inert by design — do not import or "fix":
- `hosts/framework/{disko,impermanence}.nix` — impermanence migration plan. Disk is shared with a Bazzite install; see file headers for hazards. (Outside `modules/`, so never auto-imported.)
- `/_`-prefixed paths under `modules/` — disabled modules kept for recovery; import-tree skips them. All predate the dendritic migration: revival needs the `flake.modules` wrapper (plus any commented-out flake input), not just a rename.

## Conventions
- One feature per file; wrap the body as `flake.modules.<class>.<aspect> = <module>`. Disable a module by prefixing its path with `_`. `/new-module` scaffolds a leaf plus its gates (git add, gen-index, verify).
- Keep `# @desc: <one line>` as the first line, above the wrapper; it feeds the module index (`nix run .#gen-index`).
- Aspects get `inputs`/`nixpkgs-unstable` via `specialArgs`/`extraSpecialArgs` (set in `modules/flake/hosts.nix`); `colors` flows from the `theme` cell via `_module.args`.
- User `liana`, email `liana@lianas.org` hardcoded in `modules/shell/git.nix`.
- `stateVersion`: NixOS `23.05`, home-manager `26.05`. Do not change.

## Build
- `nh os switch /nix/dotfiles`. Don't offer to build.
- `/flake-update` updates inputs with staged verification (lock diff → eval → checks → build scope); it never switches.
- Format/lint: hooks auto-format and lint edited `.nix` (alejandra, statix, deadnix; `statix.toml` disables lints that fight house style) and shellcheck shell edits. `nix fmt` is for bulk reformatting only (and fails on the staged `impermanence.nix` — format files explicitly instead).

## Verify
After editing `.nix` files, check evaluation (no build, no switch) with `dotfiles-verify`; a Stop hook blocks once per turn until it has passed on the current tree.
New files must be `git add`ed before flake eval sees them (the script warns); `gen-index` likewise skips untracked leaves.
`nix flake check` additionally gates the generated indexes, token budgets, guard fixtures, shellcheck on `modules/bin`, and the root `justfile`.
`frame` (or bare `just` at the repo root) lists all repo/system tasks; recipes shell out to the same commands documented here.
After a switch that adds systemd units, fire oneshots once (`systemctl --user start <unit>`) — passing eval doesn't prove a unit starts.
