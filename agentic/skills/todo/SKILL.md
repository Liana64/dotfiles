---
name: todo
description: Track persistent TODO items in a markdown checklist. Use when the user says "add a todo", "what's on my todo list", "mark … done", "/todo", or otherwise wants to record or review cross-session tasks. Per-project list at .claude/todo.md, global list at ~/.claude/todo.md — both symlinks into the ai-memory repo.
argument-hint: "[add <text> | list | done <match> | --global]"
allowed-tools: [Read, Write, Edit, Bash]
---
Track TODO items as a plain markdown checklist. Two lists exist:

- **Project** (default): `.claude/todo.md` at the git root, else the cwd.
- **Global**: `~/.claude/todo.md`. Target it when the request says `global` or `--global`.

Both paths are symlinks into the canonical store `~/Projects/Software/ai-memory`
(remote `ssh://git@git.milberry.org/liana/ai-memory.git`). Resolve the project
root with `git rev-parse --show-toplevel` (fall back to cwd on failure).

If a project has no list yet, create `projects/<name>/TODO.md` in the ai-memory
repo (`# TODO\n`) and symlink `.claude/todo.md` to it — never a plain local file.
Never invent items.

## Commands

**add `<text>`** — Append `- [ ] <text>` to the target list.

**list** (and bare `/todo`) — Read the project list and show its open (`- [ ]`)
items. If the global list has open items, show them under a separate `Global`
heading. Say so plainly when a list is empty or absent.

**done `<match>`** — Find the open item whose text contains `<match>` and flip its
`- [ ] ` to `- [x] `. If several match, list the candidates and ask which.

## Sync

After any change, commit in the ai-memory repo:
`git -C ~/Projects/Software/ai-memory add -A && git -C ~/Projects/Software/ai-memory commit -m "todo: <summary>"`
then `git -C ~/Projects/Software/ai-memory push` best-effort — report but don't
block on push failure (offline is fine; never force-push).

Durable items only — in-session tracking stays on the harness task tools
(TaskCreate/TaskUpdate); don't substitute or mirror. Promote a session task
here only if it must outlive the session.

Keep replies terse: confirm the change or print the items, nothing more.
