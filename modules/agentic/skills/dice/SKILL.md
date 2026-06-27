---
name: dice
description: Add a quote to the curated fortune file ("/dice <quote, author, or topic>") — verifies attribution, formats, and places it via a context-loaded agent
argument-hint: "<quote, author, or topic>"
allowed-tools: [Agent]
---

Spawn one general-purpose agent for the request in $ARGUMENTS. Relay its report
(entry text, placement, verification notes) back to the user. Agent prompt:

---

Add a quote to `~/Projects/Software/dice/share/fortune`, a hand-curated
fortune file (strfile format: entries separated by lines containing only
`%`). The repo is the single source of truth for the data.

Request: $ARGUMENTS

**Trust the user by default.** Do NOT WebSearch — add the quote as
supplied, attributing it plainly as given. Verify (WebSearch) only when the
request explicitly asks: "verify", "confirm", "check", "is this really by",
or similar. When you do verify — or when you already know from training that
an attribution is a well-known misattribution — apply: Verified → attribute
plainly. Unproven → `attributed to X`. Deliberately altered → `after X`.
Translations name the translator. Fictional voices cite character and work.
A known misattribution → flag it and offer the nearest verified alternative
rather than silently adding, even without searching.

**Format** (match the file exactly — read a few entries first):
- ≤74 columns; two spaces between sentences; ASCII `--` and straight
  quotes; unicode only in non-English text, names, or math.
- Attribution line: two literal tabs then `-- name`. Continuation lines:
  two tabs then three spaces.
- Poems keep their lineation; blank lines only as stanza breaks.
- Entry ends with a `%` line.

**Placement is curation.** Never append. Read the file, find the entry's
thematic kin (the file runs in loose clusters: identity, love-as-act,
silence/word, darkness/light, journey/return, dice/fate, vigilance,
spiritual trapdoors, engineering, memento mori, comedy), and insert beside
the most resonant neighbor. Adjacency jokes are house style — a solemn
entry may be answered by a deadpan one.

**Finish:** count entries with `grep -c '^%$' share/fortune`. Do NOT
commit or push — additions are batched; leave the working tree dirty.
Return: the exact entry as written, the neighbor it was placed beside
and why, verification notes, and the new count.
