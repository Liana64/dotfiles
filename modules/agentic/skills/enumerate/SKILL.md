---
name: enumerate
description: Write a multi-agent siege prompt for a hard goal — strict bar, diverse search, adversarial audit, 5 agents / 1 hour ("/enumerate <goal>")
argument-hint: "<goal>"
allowed-tools: [AskUserQuestion]
disable-model-invocation: true
---

Write a siege prompt: one prompt directing an orchestrator and its
subagents to pursue a hard, checkable goal until a solution survives
adversarial audit. Domain-neutral — debugging, performance, security,
design, research; nothing in the output may presume mathematics.
Address the orchestrator directly, imperative voice throughout.

Goal from $ARGUMENTS — if absent, ask for it. If no success criterion
is checkable by someone other than the solver, ask one question to pin
it — an unauditable bar voids the whole prompt.

# Anatomy

Five parts, in order.

**Task statement.** Define every term a solver could read two ways.
State scope, environment, and edge cases (empty input, the degenerate
case, the already-solved case). Name the exact artifact to produce.
When a solution is known or near-certain to exist, add: "Assume for
purposes of this task that a complete solution exists." Where
nonexistence is a legitimate answer, instead name the negative result
as an acceptable artifact, with its own verification bar.

**Completeness bar.** One sentence: exactly what a complete solution
delivers. Then enumerate the near-misses that do not count —
special-case solutions, reductions to an equally hard open subproblem,
fixes verified on one instance, candidates without verification,
best-effort summaries, explanations of why the problem is hard.

**Orchestration.** Up to 5 concurrent agents, managed dynamically —
never a fixed "N agents on strategy X":
- Open with genuinely different approach families, not variations on
  one idea.
- Withhold the favored approach from most agents early; independence
  prevents convergence on an attractive dead end.
- Keep a registry of families grouped by underlying mechanism, not
  wording; redirect crowded families toward underexplored ones.
- Elegance is not progress: a route ending at a subproblem as hard as
  the original is blocked. Reopen only for a materially new mechanism.
- Keep incompatible routes alive across rounds; cross-pollinate only
  after independent work exposes real strengths and gaps.
- Once candidates exist, one agent per round is adversarial: audit
  them against a checklist of this domain's failure modes —
  instantiate 5–8 concrete ones for the goal at hand, not generic
  virtues.
- Demand artifacts — repros, diffs, measurements, counterexamples to
  proposed steps. Reject status reports, optimism, and "routine"
  claims about unverified steps.
- The root synthesizes, challenges, redirects, and launches new
  rounds.

**Persistence.** Do not return because the first wave failed or agents
report hard gaps; launch new rounds. Budget one hour of wall clock:
record the start time and check it between rounds; if the clock is
unobservable, set a round cap and state it. Return early
only with a solution that survived audit; at the deadline return the
strongest rigorously verified result and its exact remaining gap,
nothing vaguer.

**Search restriction.** Only for benchmarks, or when independent
derivation is the point: external lookup for standard background only —
never for the solution itself, never to establish that the goal is
impossible or already answered. For ordinary engineering goals, omit —
whether the problem is already solved upstream is a legitimate query.

# Gate

Before returning: every ambiguous term defined; bar auditable by an
agent that didn't produce the solution; near-misses and audit
checklist specific to this goal, not copied from here; caps present
(5 agents, one hour); vocabulary native to the goal's domain.

# Output

The prompt verbatim in one fenced block, nothing after it.
