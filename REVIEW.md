# Code review — 2026-09-23

Full-repo review of the initial commit (254 files). Findings ranked by severity; eval-breakers verified with `nix eval`/`nix build`, top claims independently re-verified. One reported "high" (n1 talos zvol mismatch) was dropped as a false positive — `zvol = "vms/talos-os"` matches disko's `vms` pool zvols.

## Eval is broken at HEAD (verified by `nix eval`/`nix build`)

1. **Missing `veles`/`portable` home aspects** — `modules/security/housing.nix:117,143,217` reads `aspects.veles` from `flake.modules.homeManager`, but no module defines it; since `modules/flake/hosts.nix:11,95,105` injects every home aspect into every home config, eval dies with `attribute 'veles' missing` (same for `portable`). framework/portable/noku + home configs are all red.
2. **deck undeployable** — `flake.nix:84-87` + `modules/flake/hosts.nix:43-48`: jovian follows nixpkgs-unstable at a rev using the v2 module merge; `jovian.steam.desktopSession`'s option type is incompatible → `nixosConfigurations.deck` fails eval.
3. **oob undeployable** — `hosts/oob/monitoring.nix:42-49`: grafana has a sops-managed `admin_password` but no `settings.security.secret_key` → nixpkgs assertion fires. Nothing covers oob in checks, so it stays silently red.
4. **noku undeployable** — `modules/flake/hosts.nix:10,86-89` `aspects == null` = "all aspects" drags `modules/graphical/wayland.nix:66` `speechd.enable = false` into conflict with the orca path → "conflicting definition values". Needs `mkDefault`/`mkForce`.

Also verified red: `nix flake check` fails because `modules/AGENTS.md` is stale vs `# @desc` reality (`nix build .#checks...module-index` fails).

## Verified real bugs

5. **deck wipes itself on every boot** — `hosts/deck/impermanence.nix:24` rolls back `@root` from `@root-blank`, but `hosts/deck/disko.nix:44` only *creates* `@root-blank` empty; nothing ever snapshots installed root into it (framework's twin file explicitly says "wait until … the snapshot exists" — deck claims it's "pristine from disko format time"). First boot replaces root with an empty subvolume → unbootable.
6. **WireGuard can never come up on untrusted Wi-Fi** — `modules/security/wireguard.nix:63,84` overrides only `ProtectKernelTunables`; `ProtectKernelModules=true` from `hardening.base` stands, so wg-quick's `modprobe wireguard` is denied and `networking.wireguard` (which sets `boot.kernelModules`) isn't used → the autoconnect service restart-loops while traffic goes out untunnelled.
7. **Latent eval-killer** — `modules/shell/taskwarrior.nix:75-83`: `workon` interpolates `${jq}` but `jq` is bound nowhere (let has only `enabled`/`taskwarrior-tui`). Harmless today only because every host is `taskManager = "todoist"`; the moment it's set, home eval dies.
8. **deck has no login** — `hosts/deck/secrets.nix` is orphaned (never imported by `options.nix`, `secrets` absent from its aspect list), so sops never loads: liana stays at `initialHashedPassword = "!"`.
9. **deck gets Framework hardware forced onto it** — `modules/flake/hosts.nix:43-48` imports `frameworkHardware` for deck: `video=eDP-1:1920x1200` on a 1280×800 panel + Framework keyd device ids that can never match.

## Infra gaps (agent-verified by reading, worth confirming)

- **No router exists** — n1 has `br-wan`, the `opnsense-os` zvol, and a "4 opnsense" budget comment, but no domain is declared on any host. Without it, nothing serves DHCP on cluster VLAN 10 → m1 never gets `172.16.4.30`, so `hosts/m1/ganesha.nix:34`'s hardcoded `Bind_addr` crashloops and the whole Talos cluster loses `/tank`.
- **TB link blackholed** — `hosts/n1/network.nix:60` / `hosts/n2/network.nix:54`: bridge member has `bridgeVLANs = []` while the VM NIC is tagged `vlan = 10` on a VLAN-filtering bridge → tagged frames dropped at the TB port.
- **framework's live config vs disko drift** — `hosts/framework/options.nix:7-11` imports `hardware-configuration.nix` (only `/` and `/boot`) while the unimported disko layout defines `/nix`, `/persist`, `/swap` etc. Fine only while the machine isn't on that layout.
- **GPU stranded on m1** — `hosts/m1/options.nix:38` `vfio-pci.ids=10de:1b80,10de:10f0` claims the GPU at boot but no domain anywhere passes `hostdevs`.

## Smaller / latent

- `modules/_lib/lsp-servers.nix:30` — `${binds}` concatenates into `--chdir "$PWD"` (no separator) → bwrap arg corruption for rust-analyzer/lua-ls; moot today since the file's consumer `shell/lsp.nix` doesn't exist (dead code, both true).
- nvim LSP configs (`modules/shell/nvim-lsp/*.lua`) call binaries that only exist in helix's `extraPackages`; `modules/_lib/lsp-servers.nix` is imported nowhere → **nvim has no working LSP for nix/lua/yaml**.
- `modules/shell/nvim-core/keymaps.lua:92` — `<leader>at` runs `task add …` but `task` on PATH is go-task.
- `modules/system/cache.nix:6` — `x` flag without `X` doesn't protect the pre-commit cache tree from the 30d prune.
- `modules/graphical/_niri.nix:89-93` — `mode` as attrset; niri's schema wants a string → session fails the moment any host selects niri (dormant).
- Theme drift: `stylix.nix:22` `emerald = base0F` is pink under kanagawa; `mako.nix:59` hardcodes a milberry-only color; `waybar.nix:260` styles `.focused` but niri emits `.active`; `k9s/plugins.nix:42` `scopes=["helmrelease"]` vs `helmreleases`.
- `modules/graphical/swaybg.nix:22` — absolute `/nix/dotfiles/...` wallpaper path breaks on any other checkout location (crash-loop).
- `modules/bin/track-date` never packaged (`waybar.nix:33,47` wiring commented out), yet `waybar-countdown` reads `/var/secrets/date`.
- `hosts/m1/grafana-restic.json` referenced by nothing.
- `modules/flake/hosts.nix:101-111` — `mkHome` ignores host aspects; `liana@noku`/`liana@portable` are byte-identical to the laptop home.
- `modules/bin/dotfiles-verify` evaluates only 5 of 10 configurations, then prints "all configs ✓" — the check that should have caught items 1–4 doesn't look at them.

## Security posture notes (judgment calls, not defects)

- `modules/security/secrets.nix:16 vs :70` — wrapper decrypts `~/.config/sops/age/nix.age`, but the repo materializes the identity as `milberry.key`; `SOPS_AGE_KEY_CMD` always fails.
- `modules/_lib/hypervisor.nix:45` — `PubkeyAuthOptions=verify-required` + no sk-* keys in the repo → confirm all YubiKey SSH keys are FIDO-resident, else m1–n3 are unreachable without console.
- `modules/security/usbguard.nix:32` — `apply-policy` on present controllers with default `ImplicitPolicyTarget=block`: a missing/stale `rules.conf` deauthorizes xHCI → dead keyboard/trackpad; nixpkgs defaults to `keep` for this reason.
- `modules/security/hardening.nix:13` — `lockdown=integrity` on a ZFS-root host (m1): verify `zfs.ko` is signed/loads, else pools never import.

## Clean

No secret material staged (all sops references, `grafana-restic.json` is a dashboard), no IP/MAC/port collisions across the nine hosts, QMK keymap + vial-gui package verified against pinned sources, firewall/nfsd/journald/timer wiring consistent.

## Order of attack

Fix the four eval-breakers (1–4) first since they gate everything, then the deck wipe-on-boot (5) — that one is data loss on first boot.
