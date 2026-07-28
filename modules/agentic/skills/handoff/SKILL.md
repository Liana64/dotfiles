---
name: handoff
description: Compress live session state into the harness task list, for a fresh-context agent to pick the work up ("/handoff [scope]")
argument-hint: "[scope]"
allowed-tools: [TaskList, TaskGet, TaskCreate, TaskUpdate, ToolSearch, Bash]
---

Write the list for an agent that arrives with zero transcript and the whole
repo. Everything load-bearing that exists only in this conversation moves into
the list, at the lowest cost that still resumes the work. $ARGUMENTS narrows
scope; bare `/handoff` takes all work in flight.

**Reconcile.** `TaskList` + `git status --short`. Close what is done, delete
what is dead. A stale task bills every turn and aims the reader at nothing.

**Carry only what the repo cannot say.** The reader gets the repo, its docs
and `git diff` free. Transcript-only: decisions and the constraint behind
them; approaches ruled out, with why; runtime facts too slow or unrepeatable
to re-observe; constraints the user set; the next action. Point with
`path:line`, name the command over its output, never paste code or narrate.

**Shape.** One task per resumable unit; ordering rides `addBlockedBy`, not
prose. Exactly one `in_progress` — the entry point. Description: line 1 the
next action, imperative; then `Known:` (facts that cost tokens to re-derive)
and `Done when:` (the check that closes it), each only if it applies. Nothing
may point back at the conversation — no "as discussed", no bare "the file".
Fragments, no preamble, no restating the subject. ≤8 open tasks, ≤5 lines
each; state that will not compress is work wanting a split.

**Route the rest,** one home per fact: outlives the work → `/remember`; not
picked up soon → `/todo` (harness tasks die with the session); process lesson
→ `/dream`.

Report one line — closed, opened, entry point. Never invent pending work; an
empty list after reconciliation is a valid handoff.
