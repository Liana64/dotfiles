---
name: remember
description: Save a durable fact to the ai-memory repo ("remember this", "/remember")
argument-hint: "[--global] <fact>"
allowed-tools: [Read, Write, Edit, Bash]
---
Store: `~/Projects/Software/ai-memory` (missing → stop, never init).
Project slug = git root path (else cwd), `/` → `-`. Target dir: `readlink
~/.claude/projects/<project-slug>/memory`; missing → suggest /onboard.
`--global` → `global/` (index: `global/MEMORY.md`).

1. Read target MEMORY.md. Existing memory covers the fact → update that file
   and its index line; skip steps 2–3. Contradicts one → surface it; when the
   new fact clearly supersedes (same scope, same type — never `type: user`),
   write the new memory and delete the old file + index line in the same
   sync, message `supersede: <new> replaces <old>`. Ambiguous → stop and ask.
2. Write `<fact_slug>.md` — short snake_case slug of the fact itself, unique
   in the dir:
   ```
   ---
   name: <fact-slug, kebab>
   description: <one line, used for recall>
   metadata:
     type: user|feedback|project|reference
     host: <hostname>
     agent: claude-code
     created: <YYYY-MM-DD>
   ---
   <fact; feedback/project add **Why:** and **How to apply:**; link [[name]]>
   ```
3. Append `- [Title](<fact_slug>.md) — <hook>` to MEMORY.md. Index lines only.
4. `ai-memory sync "memory: <fact_slug>"` — commit, rebase onto remote, push
   (best-effort, never force).

One fact per file. Don't restate what repos/CLAUDE.md record. Body ≤ 5 lines,
description ≤ 90 chars — changelogs live in git, not memory. Confirm in one line.
