# Directives

- Conserve tokens wherever it doesn't hurt results.
- Map work to harness tasks upfront and keep them current; highest-impact first.
- If an approach fails, stop and reassess.
- Explore by directory iteration and file names, not file-by-file reads.
- When a change may fill the context window, delegate granular sub-agent prompts; if the work needs session history, fork (`/fork`, Agent fork type) — it inherits the transcript.
- Persist stable facts worth their re-discovery cost (@desc, CLAUDE.md, ai-memory); fix or delete wrong memories on contact, never route around.
- Don't read or dump secrets without explicit permission.
- Never `git commit` or `git push` (`git add` is fine); sole exception: `ai-memory sync`.

# Platform

- NixOS (no python); don't offer to rebuild or switch.
- Bash tool = zsh with rust-replaced coreutils (`ls`→eza with icons, `grep`→rg, `cat`→bat, `diff`→delta, `du`→dust, `df`→duf, `top`→btop, `nmap`→rustscan); use `command <tool>` or globs for parseable output; quote `=words`; no bash-isms.
- `~/.claude` is materialized read-only from `/nix/dotfiles/modules/agentic`; edit there — applies after a home-manager switch.
- `gh` unavailable.

# Software architecture

These override conflicting guidance.

- Root-cause before proposing fixes.
- Code derives from a single source of reproducible truth.
- LSP over grep for navigation when available; check for errors.
- Code is a bonsai: thoughtful, zen, minimal — prune what isn't vital.
- Comments are exceptional: default zero, far fewer than feels natural — only a vital constraint or failure the code can't express, one terse line; narration, history, and restatement get deleted on contact. Trim a survivor by compressing facts, not deleting them. Overrides a file's comment density.
- Comment voice: lowercase, one thought per line, commas as the only joint, warnings bare CAPS ("DO NOT RUN THIS"), "do not" over "never".
- Design to minimize surprise.

# Collaboration

Replies terse unless detail earns it; minimal possessive pronouns and "AI style" writing; when wrong, correct concisely and continue.

# Harness

- "Tasks" = in-session harness tools (TaskCreate/TaskUpdate); "todos" = the durable `/todo` skill (Taskwarrior, `~/Sync/Data/ai-tasks`, never crossing into the human task store).
- Memories: ai-memory repo at `~/Projects/Software/ai-memory`; `~/.claude` memory paths symlink into it; model-agnostic. After writes: `ai-memory sync "<msg>"`, never force.
- Recall via the `ai-memory` CLI (`list`/`search`/`show`/`check`) before reading memory files.
