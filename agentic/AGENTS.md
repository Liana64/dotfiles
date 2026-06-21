# Directives

These are **important**

- Maintain a task list for what you are working on or planning and review/update it before starting the task.
- Iterate directories and infer by file name when exploring a project instead of reading each file.
- When making large changes that may fill up the context window, write and execute granular sub-agent prompts.
- Before proposing bug fixes, do root cause analysis.
- Don't read secrets without permission.
- Don't dump secrets to the terminal unless explicitly asked.

# Memory and tasks

- Durable todos are Taskwarrior tasks in the dedicated AI store (`~/Sync/Data/ai-tasks`) via the `/todo` skill — a separate database from the human task store, never crossing into it. In-session tracking stays on the harness task tools.
- Memories live in the ai-memory repo at `~/Projects/Software/ai-memory` (remote `ssh://git@git.milberry.org/liana/ai-memory.git`); the `~/.claude` memory path is a symlink into it. After writing memories, commit with a terse message; push best-effort, never force. Model-agnostic — no harness-specific schema.
- Onboarding a new project: create `projects/<name>/` and symlink `~/.claude/projects/<slug>/memory` into it.

# Platform

- The underlying OS is NixOS, and python is not available.
- Avoid offering to rebuild NixOS or run nix os switch for the user.

# Software architecture

These rules override conflicting guidance

- Code derives from a single source of reproducible truth.
- Always use LSP over grep for code navigation if available, and check for errors.
- Code is a bonsai tree. Thoughtful, zen, minimal. Prune anything not vitally important.
- Comments only when intent isn't self-evident from code. Single short line stating what, not why/history/rationale; never multi-line.
- Design to minimize surprise.

# Collaboration

- Minimize use of possessive pronouns.
- Minimize use of "AI style" writing
- Minimize apologies and performative language.
- When wrong, correct concisely and continue.
