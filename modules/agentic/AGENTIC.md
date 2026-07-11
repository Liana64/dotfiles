# AGENTIC.md

Map of the agentic system. Read this instead of exploring `modules/agentic/`;
if it contradicts the code, the code wins — then fix this file.

## Architecture

Everything under `~/.claude` is materialized from `modules/agentic/` as
read-only store symlinks; edits land here and apply only after a
home-manager switch (`nh os switch /nix/dotfiles` — user runs it).

- `agentic.nix` — single owner of Claude Code config: `settings` attrset →
  `~/.claude/settings.json`, hooks, LSP servers, permissions, MCP servers
  (commented out pending audit). Exception to read-only: settings.json is a
  real file, re-based on the declaration at each switch with `effortLevel`
  carried over so `/effort` persists.
- `AGENTS.md` → `~/.claude/CLAUDE.md` (global directives).
- `agents/*.md` → `~/.claude/agents/` (custom subagents).
- `skills/<name>/` → `~/.claude/skills/` (a new skill dir is picked up
  automatically; no agentic.nix change needed).
- Scripts live in `modules/bin/` (plain shell, ignored by import-tree),
  wrapped by the `scripts` attrset in `agentic.nix` into a `symlinkJoin` with
  PATH deps and env injection (`makeWrapper`). Adding a script = file in
  `modules/bin/` + entry in `scripts`.

## Hooks

| Event | Matcher | Script | Purpose |
| --- | --- | --- | --- |
| PreToolUse | `Read\|Edit\|MultiEdit\|Write\|NotebookEdit\|Bash` | `claude-secrets-guard` | deny secrets access; `--test` runs its fixture |
| PreToolUse | `Skill` | `claude-skill-guard` | deny skills in `CLAUDE_DENIED_SKILLS` (code-review) |
| PreToolUse | `Edit\|MultiEdit\|Write\|NotebookEdit` | `claude-comment-check` | snapshot pre-image for the net-new diff |
| PostToolUse | `Edit\|Write` | `claude-nix-check` | format + lint edited `.nix`; exit 2 feeds findings back |
| PostToolUse | `Edit\|MultiEdit\|Write\|NotebookEdit` | `claude-comment-check` | flag net-new comment lines for a necessity check |
| SessionStart | `startup\|resume` | `ai-memory pull` (backgrounded) + `ai-memory debt` | rebase memory store; whisper when the dream loop is stale |
| statusLine | — | `claude-statusline` | context + rate-limit line |

Contract: hooks get JSON on stdin (`tool_name`, `tool_input`); exit 0 =
silent allow, exit 2 = stderr fed back to the agent; PreToolUse decisions via
`hookSpecificOutput.permissionDecision` JSON on stdout.

## Permissions

`permissions.deny` pre-empts hooks and covers tools outside the guard's
matcher (Grep, Glob); the same patterns from `modules/_lib/secret-patterns.nix`
are injected into the guard at wrap time. Allowlist philosophy: wildcards
only on binaries with no eval/exec flags plus own scripts; evaluators stay
prompted; compound commands decompose per segment.

## Memory

Durable store: ai-memory repo at `~/Projects/Software/ai-memory` (git =
truth; remote `ssh://git@git.milberry.org/liana/ai-memory.git`;
`~/.claude/projects/*/memory` symlink into it). Recall via the
`ai-memory` CLI (`list`/`search`/`show` — token-frugal slug+description
output), persist via `/remember`, project wiring via `/onboard`, publish via
`ai-memory sync "<msg>"`. Session tracking = harness tasks; durable TODOs =
`/todo` (separate Taskwarrior store).

Memories are semantic facts; dreams are process observations, living as
proposal lines in the repo-root `JOURNAL.md` (never in the recall path).
Information is living — it earns its carrying cost or gets pruned on contact;
instruments: `ai-memory stale` (candidates by git author date), `confirm`
(still-true, logged out of context), `stats` (index weight), `trend`
(monthly growth), `debt` (loop-staleness whisper, wired into SessionStart),
git itself as the prune graveyard. Only `/onboard`-ed projects participate;
unlinked `~/.claude/projects/*` dirs are outside the model.

## Improvement surface

Routing table for `/dream` (and anyone improving the system): one lever per
finding type.

| Finding | Lever | Where |
| --- | --- | --- |
| durable fact worth re-discovery cost | memory | `/remember` → ai-memory repo |
| behavioral guidance / recurring correction | directive | `modules/agentic/AGENTS.md` |
| repeated multi-step workflow | skill | `modules/agentic/skills/<name>/SKILL.md` |
| check that should be automatic | hook | `agentic.nix` hooks + script in `modules/bin/` |
| safe command that keeps prompting | allowlist | `agentic.nix` `permissions.allow` |
| missing tooling | script | `modules/bin/` + `scripts` attrset |
| stale/missing system map | doc | this file, `CLAUDE.md` |

Changes are inert until user review + home-manager switch; never commit.
AGENTS.md directives adopt **two-touch** (recurrence on record in the journal
first) and the file is budgeted at 60 lines (`checks.agents-budget`) —
additions are trades.

## Skills

<!-- BEGIN agentic-skills -->
| Name | Description |
| --- | --- |
| `/audit` | File-by-file trust audit of a project, e.g. before forking third-party code ("/audit [path] [--minimal]") |
| `/dice` | Add a quote to the curated fortune file ("/dice <quote, author, or topic>") — verifies attribution, formats, and places it via a context-loaded agent |
| `/dream` | Forked retrospective on completed multi-step work — consolidate process lessons into the agentic system ("/dream [focus]") |
| `/explain` | Grounded explanation of a code change or subsystem ("/explain <commit|diff|PR|subsystem>") |
| `/flake-update` | Update flake inputs with staged verification ("/flake-update [input ...] [--build]") |
| `/new-module` | Scaffold a dendritic module leaf ("/new-module <domain>/<name> <desc>") |
| `/onboard` | Wire the current project into the ai-memory repo ("/onboard") |
| `/quick-lint` | Fast lint check using the cheapest model ("/quick-lint [file]") |
| `/remember` | Save a durable fact to the ai-memory repo ("remember this", "/remember") |
| `/todo` | Track persistent cross-session TODOs as Taskwarrior tasks in a dedicated AI store. Use for "add a todo", "what's on my todo list", "mark … done", or "/todo". |
<!-- END agentic-skills -->

## Agents

<!-- BEGIN agentic-agents -->
| Name | Description |
| --- | --- |
| `prompt-smith` | Prompt engineering specialist — diagnoses intent, treats prompts as testable hypotheses, grounds advice in evidence |
<!-- END agentic-agents -->

## Scripts (agentic)

Wrapped scripts with a `# @desc:` header; regenerate with
`nix run .#gen-agentic-index` (staleness gated by `nix flake check`).

<!-- BEGIN agentic-scripts -->
| Name | Description |
| --- | --- |
| `ai-memory` | Manage the ai-memory store with token-frugal output |
| `claude-comment-check` | Pre/PostToolUse hook — flag net-new comment lines from file edits, for a necessity check |
| `claude-nix-check` | PostToolUse hook — format edited .nix in place (alejandra), then lint it (statix, deadnix) |
| `claude-secrets-guard` | PreToolUse hook — decline access to secrets files and commands |
| `claude-skill-guard` | PreToolUse hook — deny skills listed in CLAUDE_DENIED_SKILLS |
| `claude-statusline` | statusLine — context window and plan rate-limit usage |
| `dotfiles-verify` | Quiet flake-eval check for the four configs, evaluated concurrently |
| `hardening-probe` | Probe a command or live unit under a systemd-hardening preset |
<!-- END agentic-scripts -->
