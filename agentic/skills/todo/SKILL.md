---
name: todo
description: Track persistent cross-session TODOs as Taskwarrior tasks in a dedicated AI store. Use for "add a todo", "what's on my todo list", "mark … done", or "/todo".
argument-hint: "[add <text> | list | done <match>]"
allowed-tools: [Bash]
---
TODOs are Taskwarrior tasks in a dedicated AI store — a separate database that never
touches human tasks persisted via Syncthing (nothing to commit). When actively
working on TODO items, use {TaskCreate, TaskGet, TaskList, TaskUpdate} to show the
status to the user.

## Usage
Prefix every command (`TASK`). The store shares the human taskrc, so override its
context and default project to stay isolated:

    task rc.data.location=~/Sync/Data/ai-tasks rc.context=none rc.default.project=

## Commands

**add `<text>`** — `TASK add <text>` (pass through any `due:`, `priority:`, `+tag` given).

**list** (or bare `/todo`) — `TASK status:pending list`.

**done `<match>`** — `TASK status:pending export`, find the open item whose description
contains `<match>`, then `TASK <uuid> done`. If several match, ask which.
