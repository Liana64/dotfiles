---
name: new-module
description: Scaffold a dendritic module leaf ("/new-module <domain>/<name> <desc>")
argument-hint: "<domain>/<name> \"<desc>\""
allowed-tools: [Bash, Read, Write]
---
Scaffold `modules/<domain>/<name>.nix` from $ARGUMENTS. Infer class from the
domain's siblings (read one or two): system-level domains register `nixos`,
user-level `homeManager`; a file may declare both. Aspect = `<name>`.

```nix
# @desc: <desc>
{...}: {
  flake.modules.<class>.<name> = {pkgs, ...}: {
  };
}
```

Then, in order — each gate matters:
1. `git add` the file — flake eval cannot see untracked files.
2. `nix run .#gen-index` — the CLAUDE.md module index gates `nix flake check`.
3. `dotfiles-verify` — all four configs must still evaluate.

Both hosts import every aspect: a new module is live on framework and
portable at the next switch. To stage it inert, prefix the filename with `_`
(import-tree skips it; no index entry, no gates).

Report path, class, and verification results. Leave everything uncommitted.
