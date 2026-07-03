# Directives

These are **important**

- Track work as harness tasks (TaskCreate/TaskUpdate) and keep them current; "task" always means the harness, never the `/todo` skill. Prioritize high value items first, "eat the frog."
- For any multi-step project, map goals to harness tasks before acting and maintain them as you progress.
- Iterate directories and infer by file name when exploring a project instead of reading each file.
- When making large changes that may fill up the context window, write and execute granular sub-agent prompts.
- Before proposing bug fixes, do root cause analysis.
- Don't read or dump secrets without explicit permission.
- Never `git commit` or `git push` a project (`git add` is fine); the sole exception is the ai-memory store, which `ai-memory sync` (via `/remember`, `/onboard`) commits and pushes.

# Platform

- The underlying OS is NixOS, and python is not available.
- Avoid offering to rebuild NixOS or run nix os switch for the user.
- The Bash tool runs zsh: quote `=words`; no bash-isms.
- `~/.claude` is materialized (read-only store symlinks) from `/nix/dotfiles/modules/agentic`; change harness config there — it applies after a home-manager switch.

# Software architecture

These rules override conflicting guidance

- Code derives from a single source of reproducible truth.
- Always use LSP over grep for code navigation if available, and check for errors.
- Code is a bonsai tree. Thoughtful, zen, minimal. Prune anything not vitally important.
- Comment only what the code can't state itself — a non-obvious constraint or the failure it prevents, one terse line. Cut narration, history, and restatement ("used to", "now", code echoes). Multi-line only when one line can't hold the constraint; when trimming, compress the fact, don't delete it.
- Design to minimize surprise.

# Collaboration

- Minimize use of possessive pronouns.
- Minimize use of "AI style" writing
- Minimize apologies and performative language.
- When wrong, correct concisely and continue.

# Harness
## Memory and tasks

- "Task(s)" = the in-session harness task tools (TaskCreate/TaskUpdate). "Todo(s)" = the durable `/todo` skill. They never refer to the same thing.
- Durable todos are Taskwarrior tasks in the dedicated AI store (`~/Sync/Data/ai-tasks`) via the `/todo` skill — a separate database from the human task store, never crossing into it. In-session tracking stays on harness tasks.
- Memories live in the ai-memory repo at `~/Projects/Software/ai-memory` (remote `ssh://git@git.milberry.org/liana/ai-memory.git`); the `~/.claude` memory path is a symlink into it. After writing memories, `ai-memory sync "<terse message>"` — commit, rebase, push best-effort, never force. Model-agnostic — no harness-specific schema.
- Recall through the `ai-memory` CLI before reading memory files: `list [scope]` / `search <term>` return slug + description lines, `show <slug>` prints one memory, `check` reports index drift.
- Onboarding a new project: `/onboard` creates `projects/<name>/` and symlinks `~/.claude/projects/<slug>/memory` into it.
