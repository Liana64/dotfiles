---
name: flake-update
description: Update flake inputs with staged verification ("/flake-update [input ...] [--build]")
argument-hint: "[input ...] [--build]"
allowed-tools: [Bash, Read, WebFetch]
disable-model-invocation: true
---
Update flake inputs and prove the update sound in stages. Never switch,
activate, or commit; the lock change stays in the working tree.

**Preflight.** `git diff --quiet flake.lock` — a dirty lock has no clean
baseline to bisect against; stop and ask. Warn on untracked `.nix` files
(invisible to eval, so green results would lie).

**Update.** `nix flake update`, or `nix flake update <inputs...>` when named.

**Summarize the jump.** From `git diff flake.lock`: per changed input,
old→new rev and the `lastModified` date delta; call out any
`original.ref`/branch change (that is an upgrade, not an update). On
request, WebFetch the forge compare URL (`/compare/<old>...<new>`) and
summarize breaking-looking commits.

**Verify — in order, stop at first failure:**
1. `dotfiles-verify` — all four configs evaluate.
2. `nix flake check` — module-index staleness, secrets-guard fixture,
   shellcheck.
3. Build scope: `nix build --dry-run` both toplevels and both
   activationPackages; report to-build/to-fetch counts (a kernel or
   toolchain bump reads very differently from a leaf package).
4. Only with `--build`: `nix build --no-link` all four — real proof,
   no activation.

**On failure, bisect to the culprit.** `git restore flake.lock`, re-update
inputs one at a time, re-running the failed stage after each, until it
breaks. Leave the lock fully updated except the culprit (restore again,
update the others) and report the culprit with its error tail.

**Report.** Per-input rev/date table, the verification matrix, culprits if
any. Rebuild stays manual: `nh os switch /nix/dotfiles`.
