---
name: todo
description: Track persistent cross-session TODOs as Taskwarrior tasks in a dedicated AI store. Use for "add a todo", "what's on my todo list", "mark … done", or "/todo".
argument-hint: "[add <text> | list | done <match>]"
allowed-tools: [Bash]
---
TODOs are Taskwarrior items in a dedicated AI store — a separate database that never
touches human tasks persisted via Syncthing (nothing to commit). When actively
working on TODO items, use {TaskCreate, TaskGet, TaskList, TaskUpdate} to show the
status to the user.

## Usage
Always go through the `ai-todo` wrapper. It bakes in the AI store location and the
context/default-project isolation, so never reach for bare `task` or add
`rc.data.location=…`/`rc.context=…` yourself — the wrapper is the only correct entry
point, and partial overrides silently read or write the wrong store.

## Commands

**add `<text>`** — `ai-todo add <text>` (pass through any `due:`, `priority:`, `+tag` given).

**list** (or bare `/todo`) — `ai-todo status:pending list`.

**done `<match>`** — `ai-todo status:pending export`, find the open item whose description
contains `<match>`, then `ai-todo <uuid> done`. If several match, ask which.
