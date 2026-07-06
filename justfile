# Global command `frame` (cwd /nix/dotfiles)

_default:
    @just --list --unsorted

# Eval all configs, no build
[group('repo')]
verify:
    dotfiles-verify

# Flake checks: module index, secrets-guard, shellcheck, justfile
[group('repo')]
check:
    nix flake check

# Regenerate module index for CLAUDE.md
[group('repo')]
index:
    nix run .#gen-index

# Format nix files
[group('repo')]
fmt +files:
    nix fmt -- {{ files }}

# Update input(s) and verify
[group('repo')]
update *inputs:
    nix flake update {{ inputs }}
    dotfiles-verify

# Build and show diff
[group('repo')]
diff:
    nh os build /nix/dotfiles --diff always

# Build and activate system
[group('repo')]
[confirm("rebuild + switch now?")]
switch:
    nh os switch /nix/dotfiles

# Failed systemd units
[group('system')]
health:
    systemctl --failed
    systemctl --user --failed

# Auditd status
[group('system')]
status:
    austatus

# Acknowledge auditd tripwires
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

# Flash Keychron Q11 firmware
[group('hardware')]
[confirm("flash the keyboard?")]
flash:
    nix run .#keychron-q11

# Firmware updates
[group('hardware')]
firmware:
    -fwupdmgr refresh
    fwupdmgr update

# SMART health
[group('hardware')]
disk:
    sudo smartctl -a /dev/nvme0n1

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
