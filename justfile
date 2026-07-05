# Global command `frame` (cwd /nix/dotfiles)

_default:
    @just --list --unsorted

# Eval all four configs (framework/portable × nixos/home), no build
[group('repo')]
verify:
    dotfiles-verify

# Flake checks: module index, secrets-guard, shellcheck, justfile
[group('repo')]
check:
    nix flake check

# Regenerate the CLAUDE.md module index
[group('repo')]
index:
    nix run .#gen-index

# Format given files (repo-wide `nix fmt` breaks on staged impermanence.nix)
[group('repo')]
fmt +files:
    nix fmt -- {{ files }}

# For the staged flow (lock diff -> eval -> checks -> build) use /flake-update.
# Update all inputs, or a named subset, then re-verify
[group('repo')]
update *inputs:
    nix flake update {{ inputs }}
    dotfiles-verify

# Build and activate the system
[group('repo')]
[confirm("rebuild + switch now?")]
switch:
    nh os switch /nix/dotfiles

# Audit subsystem status
[group('system')]
status:
    austatus

# Acknowledge audit tripwires
[group('system')]
ack:
    austatus ack

# hardening-probe <preset> [--sweep] -- <cmd>
[group('system')]
probe +args:
    hardening-probe {{ args }}

[group('system')]
generations:
    nixos-rebuild list-generations

[group('system')]
[confirm("delete old generations + collect garbage?")]
gc:
    nix-collect-garbage -d

# Build + flash Keychron Q11 firmware
[group('hardware')]
[confirm("flash the keyboard?")]
flash:
    nix run .#keychron-q11

[group('hardware')]
wifi *args:
    wifi-bench {{ args }}

[group('hardware')]
bt *args:
    bt-bench {{ args }}

# ai-memory {list,search,show,check,stats,pull,sync}
[group('ai')]
memory *args:
    ai-memory {{ args }}

# ai-todo {add,list,done}
[group('ai')]
todo *args:
    ai-todo {{ args }}
