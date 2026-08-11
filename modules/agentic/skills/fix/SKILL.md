---
name: fix
description: One-shot issue resolution in the dotfiles repo — fork the session, anchor to /nix/dotfiles, root-cause, fix, verify ("/fix [issue]")
argument-hint: "[issue]"
---

Spawn the resolver as a conversation fork: call the Agent tool with
`subagent_type: "fork"` and the protocol below — verbatim, `$ARGUMENTS`
substituted — as the prompt. A fork inherits this session's turns, so it
already knows the issue as discussed; `context: fork` skills do NOT
(isolated by design), and the fork type needs `CLAUDE_CODE_FORK_SUBAGENT=1`
(set in settings env). Fork type unavailable ("Agent type 'fork' not
found") → run the protocol inline, restoring the session cwd at the
end. Relay the fork's report unabridged;
state which mode ran (fork or inline). Nothing else — the point is
one command in, one report out.

## Protocol

You are a forked resolver for exactly one issue. Work is autonomous: no
questions, no progress check-ins — make the conventional choice, note it,
and surface everything in the final report. Stop early only for a
destructive or irreversible action.

1. **Anchor** — all work happens in `/nix/dotfiles`; if the session cwd
   differs, `cd /nix/dotfiles` once, then prefer absolute paths.
2. **Scope** — $ARGUMENTS names the issue; otherwise the issue under
   discussion in this session. Neither yields one concrete issue →
   report that and stop; guessing is not resolving.
3. **RCA** — evidence the failure before touching anything; fix the
   cause, not the symptom. Hardening is intentional — never relax it
   to quiet one.
4. **Resolve** — smallest change that removes the cause, per repo
   conventions (dendritic leaf, `# @desc:` first line, one feature per
   file). `git add` new files; never commit, push, or switch.
5. **Verify** — `dotfiles-verify` once after `.nix` edits; new module →
   `nix run .#gen-index`. Eval only — units and builds stay unproven
   until the user switches.
6. **Report** — root cause, files touched, verification result, every
   decision made unilaterally. Blocked → say exactly what's missing,
   with the work staged as far as it got.

Bounds: one issue per invocation; never spawn another fork or invoke
/fix or /dream; leave unrelated breakage reported, not fixed.
