---
name: onboard
description: Wire the current project into the ai-memory repo ("/onboard")
argument-hint: "[name]"
allowed-tools: [Read, Write, Edit, Bash]
---
Store: `S=~/Projects/Software/ai-memory` (missing → stop, never init).
Idempotent — skip what's already wired; report created vs existing.

1. Root = `git rev-parse --show-toplevel` (else cwd). Name = `$1` or basename
   (lowercase; must be path-safe, else ask). Slug = root path, `/` → `-`.
   **Collision guard:** if `S/projects/<name>/MEMORY.md` exists with a
   `Project dir:` ≠ root → stop, ask for an explicit name.
2. Ensure `S/projects/<name>/` has:
   - `MEMORY.md` starting with:
     `Project dir: \`<root>\``
     `Global memories: [global/MEMORY.md](../../global/MEMORY.md) — load alongside this index`
     (existing file → prepend these lines; else create)
   - `TODO.md` (`# TODO`)
   If `~/.claude/projects/<slug>/memory` or `<root>/.claude/todo.md` is a real
   dir/file, move its contents in first.
3. Replace originals with symlinks (remove path, `mkdir -p` parents, link to
   **absolute** target):
   - `~/.claude/projects/<slug>/memory` → `S/projects/<name>`
   - `<root>/.claude/todo.md` → `S/projects/<name>/TODO.md`
4. If the project git tracks `.claude/todo.md`: `git rm --cached` it and
   gitignore `.claude/todo.md` (not all of `.claude/`). Leave these project-repo
   changes uncommitted.
5. In S: `pull --rebase`, `add -A`, commit `onboard: <name>`, push —
   pull/push best-effort, never force.

Confirm created paths, one line each.
