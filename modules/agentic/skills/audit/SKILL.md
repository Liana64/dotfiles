---
name: audit
description: File-by-file trust audit of a project, e.g. before forking third-party code ("/audit [path] [--minimal]")
argument-hint: "[path] [--minimal]"
allowed-tools: [Agent, Bash, Read, Write, Edit]
disable-model-invocation: true
---

Audit the repo at the path in $ARGUMENTS (default cwd) file by file: a
one-line comprehension of each file, plus trust flags — network calls,
exec/eval/dynamic code, obfuscation (encoded blobs, unexpected
minification, homoglyphs), install/build hooks, telemetry,
credential/secret access, filesystem writes outside the project,
injection surfaces, suspicious deps. Never modify the project itself;
never commit. All artifacts live in `.audit/` at the repo root.

**Ledger.** `.audit/ledger.tsv`, append-only: `path<TAB>verdict<TAB>note`.
Verdicts: `clean` | `note` | `flag` | `scan` (pattern-scan only) | `skip`
(reason in note). Each session appends a header `# commit <sha> <date>
<mode>`; the last header and the last row per path win. First run: create
`.audit/` and add `.audit/` to `.git/info/exclude` — never `.gitignore`; a
fork may push upstream and must carry no audit residue.

**Enumerate.** `git ls-files` under the target. Every file gets a row —
coverage must be provable, never silent. Pre-mark `skip`: binaries
(`grep -IL`), assets, vendored/generated dirs. Lockfiles and files over
~1500 lines: don't read whole — scan for registries, URLs, and install
hooks, and say so in the note. Pending = enumerated minus ledger paths
(`scan` rows count as pending in full mode). If HEAD moved since the last
`# commit`, also re-queue files changed since.

**Sweep.** Fan out general-purpose agents (model: sonnet) in waves of ≤4,
~12 files each, grouped by directory. Each agent prompt: read every
assigned file in full; you are strictly read-only — no edits, no network;
for each file return exactly one ledger row (verdict + one-line note
covering what it does and any trust concern), and for each `flag` a block
`FLAG <path>:<line> <category> — <verbatim evidence>`. Append returned
rows to the ledger after each wave — the ledger, not the conversation, is
the state.

**Escalate.** Before any `flag` reaches the report, read the cited lines
yourself with surrounding context. Confirm, or append a downgraded row —
record the downgrade; false positives are findings too.

**Minimal (`--minimal`).** No comprehension, no fan-out. Read only the
high-risk set yourself: manifests, lockfiles, CI configs, build/install
scripts, anything hook-adjacent. Grep the rest for exec/eval, `base64`
and long opaque literals, `curl|wget|fetch|http`, install-hook keys
(`postinstall`, `prepare`, `setup(`); hits get a full read, the clean
remainder gets `scan` rows.

**Report.** When nothing is pending, write `.audit/report.md`: overall
trust verdict; findings by severity with file:line; supply-chain summary
(deps, install hooks, CI); a short architecture map distilled from the
comprehension notes; coverage (audited / scanned / skipped, with
reasons). Give the user the verdict and top findings inline.
