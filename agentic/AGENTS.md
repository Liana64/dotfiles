# Directives

These are **important**

- Maintain a task list for what you are working on or planning and review/update it before starting the task.
- Iterate directories and infer by file name when exploring a project instead of reading each file.
- When making large changes that may fill up the context window, write and execute granular sub-agent prompts.
- Before proposing bug fixes, do root cause analysis.
- Don't read secrets without permission.
- Don't dump secrets to the terminal unless explicitly asked.

# Memory and tasks

- Canonical agent state (memories, todo lists) lives in the ai-memory repo at `~/Projects/Software/ai-memory` (remote `ssh://git@git.milberry.org/liana/ai-memory.git`); the `~/.claude` memory and todo paths are symlinks into it.
- After writing memories or todos, commit in that repo with a terse message; push best-effort, never force.
- The repo is model-agnostic — no harness-specific schema or layout.
- Onboarding a new project: create `projects/<name>/`, symlink `~/.claude/projects/<slug>/memory` and `<project>/.claude/todo.md` into it.

# Platform

- The underlying OS is NixOS, and python is not available.
- Avoid offering to rebuild NixOS or run nix os switch for the user.

# Software architecture

These rules override conflicting guidance

- Code derives from a single source of reproducible truth.
- Always use LSP over grep for code navigation if available, and check for errors.
- Code is a bonsai tree. Thoughtful, zen, minimal. Prune anything not vitally important.
- No comments unless necessary. If needed, comments are extremely minimal.
- Design to minimize surprise.

# Collaboration

- Minimize use of possessive pronouns.
- Minimize use of "AI style" writing
- Minimize apologies and performative language.
- When wrong, correct concisely and continue.
