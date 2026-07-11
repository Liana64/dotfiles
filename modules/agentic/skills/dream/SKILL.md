---
name: dream
description: Forked retrospective on completed multi-step work — consolidate process lessons into the agentic system ("/dream [focus]")
argument-hint: "[focus]"
allowed-tools: [Agent, Read, Write, Edit, Bash]
---

Spawn the retrospective as a conversation fork: call the Agent tool with
`subagent_type: "fork"` and the protocol below — verbatim, `$ARGUMENTS`
substituted — as the prompt. A fork inherits this session's turns, the
evidence base; `context: fork` skills do NOT (isolated by design), and the
fork type needs `CLAUDE_CODE_FORK_SUBAGENT=1` (set in settings env). Fork
type unavailable ("Agent type 'fork' not found") → run the protocol inline:
full evidence, at the cost of main-session context. Relay the fork's report
unabridged; state which mode ran (fork or inline).

## Protocol

You are a forked retrospective of this session. The subject is the *process*,
not the project: improve the agentic system so the next session runs better.
Read `/nix/dotfiles/modules/agentic/AGENTIC.md` first — its improvement-surface
table is the routing map for every finding.

1. **Scope** — $ARGUMENTS names the focus; otherwise the multi-step work just
   completed in this session.
2. **Evidence** — sweep the session for: user corrections and redirections,
   tool errors and retries, hook denials, permission prompts, facts
   re-discovered that memory should have held, exploration a doc should have
   pre-answered. No session turns visible (fresh session or fork context
   loss)? Say so in the report and limit evidence to repo state — git
   status/diff, journal, memory store.
3. **Diagnose** — root-cause each friction point. Drop one-offs; keep only
   what will recur.
4. **Route** — map each root cause to exactly one lever via the AGENTIC.md
   table. Prefer updating an existing memory, directive, or doc over adding
   a new one.
5. **Journal audit** — read `~/Projects/Software/ai-memory/JOURNAL.md`
   (proposal lifecycle lines only). Judge prior `adopted` lines against this
   session: confirmed helpful → prune; regressed → propose revert. Never
   re-propose a `rejected` line. Prune resolved/stale lines; hard cap 30.
6. **Hygiene** — memory is living. Run `ai-memory check`: drift, unresolved
   links, and `budget:` lines are findings. Judge every memory this session
   recalled or contradicted: wrong → delete the file and its MEMORY.md index
   line (`type: user` → always ask first); superseded → merge into the
   survivor, delete the loser; still valuable → leave. Then `ai-memory
   stale` → judge at most the 3 oldest candidates; still-true →
   `ai-memory confirm <slug>`. Prunes and confirmations get no journal
   lines — git history and confirmations.log carry them.
7. **Act**
   - Memory levers: write/update memories per ai-memory conventions, update
     the journal (`YYYY-MM-DD <slug> → proposed|adopted|rejected|regressed:
     <terse note>`, date from `date +%F`), then one
     `ai-memory sync "dream: <scope>"` covering everything above.
   - Repo levers (skills, hooks, allowlist, scripts, docs): apply as
     working-tree edits, `git add` new files, **never commit** — inert until
     user review plus a home-manager switch.
   - AGENTS.md directives are **two-touch**: first sighting → journal
     `proposed` line only, no edit. Edit AGENTS.md only when a prior
     `proposed` line shows the same friction recurring (mark it `adopted`),
     or the user approves early. Directives are weight carried every session.
8. **Report** — one line per finding: root cause → lever → done or staged.
   Note journal prunes and memory prunes; end with the index-weight delta
   (`ai-memory stats` before vs after). Nothing met the bar → say so; an
   empty retro is a valid result.

Bounds: never invoke /dream or spawn another retrospective; never commit,
push, or switch the dotfiles repo (the memory repo syncs via `ai-memory
sync` as instructed above); when uncertain a finding will recur, leave it
out.
