---
name: explain
description: Grounded explanation of a code change or subsystem ("/explain <commit|diff|PR|subsystem>")
argument-hint: "<commit|range|PR|subsystem|concept>"
allowed-tools: [Bash, Read, Agent]
disable-model-invocation: true
---

Explain the subject in $ARGUMENTS — a code change (commit, range, working-tree
diff, PR) or a subsystem/concept of the current repo. Ground every claim in
code actually read; never explain from diff hunks alone.

**Resolve the subject.** Ref or range → `git show`/`git diff`. Bare `/explain`
with a dirty tree → the working-tree diff. PR number/URL → `gh pr diff` plus
the PR description. Anything else → a subsystem or concept: locate it via the
module index / project docs first, then search.

**For a change:**
- Read the surrounding code, not just the hunks — a diff without its context lies.
- Recover intent: commit message, `git log` on the touched files, blame on the
  changed lines, linked issue or PR body.
- Separate mechanism (what the code now does) from motive (why it changed);
  flag where motive is inferred rather than stated.

**For a subsystem:** trace it from entry point to effect; name the
load-bearing files and how they connect.

**Report** in prose, not a fixed template:
- One paragraph up front that answers "what is this and why".
- Then the mechanism, citing file:line for each load-bearing claim.
- Close with implications: what depends on it, what would break, anything
  surprising found along the way.

Calibrate depth to the subject — a one-line config flip gets three sentences,
not a report. For large subjects, delegate the sweep to Explore agents and
synthesize; keep raw file dumps out of the conversation.
