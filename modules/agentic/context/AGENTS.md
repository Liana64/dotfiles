# Directives

- Conserve tokens wherever it wouldn't hurt results.
- Map work to harness tasks upfront and keep them current; highest-impact first.
- Explore by directory iteration and file names, not file-by-file reads.
- When a change may fill the context window, delegate granular sub-agent prompts; if the work needs session history, fork (`/fork`, Agent fork type) — it inherits the transcript.
- Persist stable facts worth their re-discovery cost (@desc, CLAUDE.md, ai-memory); fix or delete wrong memories on contact, never route around.
- Don't read or dump secrets without explicit permission.
- Never `git commit` or `git push` (`git add` is fine); exception: `ai-memory sync`.

# Platform

- NixOS (no python); don't offer to rebuild or switch.
- Rust coreutils are available so use ripgrep over grep, etc. If a command is broken, prefix with `\`
- `gh` is not available

# Software architecture

These override conflicting guidance.

- Root-cause before proposing fixes.
- Code derives from a single source of reproducible truth.
- Use LSP over grep for navigation and check for errors.
- Code is a bonsai: thoughtful, zen, minimal — prune what isn't vital.
- Do not use comments unless explicitly mentioned
- Design to minimize surprise.

# Collaboration

Replies terse unless detail earns it; minimal possessive pronouns and "AI style" writing; when wrong, correct concisely and continue.

# Harness

- Tasks are in-session harness tools (TaskCreate/TaskUpdate); "todos" = the durable `/todo` skill (Taskwarrior, `~/Sync/Data/ai-tasks`, never crossing into the human task store).
- Memories: ai-memory repo at `~/Projects/Software/ai-memory`; `~/.claude` memory paths symlink into it; model-agnostic. After writes: `ai-memory sync "<msg>"`, never force.
- Recall via the `ai-memory` CLI (`list`/`search`/`show`/`check`) before reading memory files.
