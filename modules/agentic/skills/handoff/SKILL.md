---
name: handoff
description: Compress live session state into a HANDOFF.md at the working-directory root, for a fresh-context agent to pick the work up ("/handoff [scope]")
argument-hint: "[scope]"
allowed-tools: [Read, Write, Bash, TaskList, TaskGet, ToolSearch]
---

Write `HANDOFF.md` at the root of the working directory, for an agent that
arrives with zero transcript and the whole repo. Everything load-bearing that
exists only in this conversation moves into the file, at the lowest cost that
still resumes the work. $ARGUMENTS narrows scope; bare `/handoff` takes all
work in flight.

**Reconcile.** Read the existing `HANDOFF.md` if there is one, then `TaskList`
+ `git status --short`. Carry forward only what is still live; drop what
shipped or died. A stale line bills every read and aims the reader at nothing.

**Carry only what the repo cannot say.** The reader gets the repo, its docs
and `git diff` free. Transcript-only: decisions and the constraint behind
them; approaches ruled out, with why; runtime facts too slow or unrepeatable
to re-observe; constraints the user set; the next action. Point with
`path:line`, name the command over its output, never paste code or narrate.

**Shape.** Overwrite the file whole — it is state, not a log; no dates, no
history. `# Handoff: <scope>`, then one `##` section per resumable unit,
ordered by dependency with the entry point first, marked `(start here)`.
Section body: line 1 the next action, imperative; then `Known:` (facts that
cost tokens to re-derive) and `Done when:` (the check that closes it), each
only if it applies. Nothing may point back at the conversation — no "as
discussed", no bare "the file". Fragments, no preamble, no restating the
subject. ≤8 sections, ≤5 lines each; state that will not compress is work
wanting a split.

**Route the rest,** one home per fact: outlives the work → `/remember`; not
picked up soon → `/todo` (`HANDOFF.md` is for work resuming next);
process lesson → `/dream`.

The file is a working artifact: leave it untracked, never commit it, and
delete it when the work it describes lands. Report one line — path, sections,
entry point. Never invent pending work; nothing in flight after reconciliation
→ delete any stale `HANDOFF.md` and say so.
