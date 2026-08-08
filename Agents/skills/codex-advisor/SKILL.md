---
name: codex-advisor
description: Consult Codex as an independent read-only technical advisor when a second opinion would materially improve an architecture decision, implementation approach, difficult investigation, security decision, performance decision, or other non-trivial technical judgment.
---

# Codex Advisor

Use Codex as an independent technical advisor when a second-model opinion
would materially improve the current decision.

Claude remains the primary agent and final decision maker.

## When to use

Use Codex Advisor selectively for:

- important architecture or design decisions
- multiple viable approaches with meaningful trade-offs
- difficult root-cause investigations
- uncertain assumptions about the codebase
- concurrency or lifecycle problems
- performance-sensitive algorithms
- security-sensitive decisions
- compatibility or migration risks
- complex implementation approaches before substantial work
- situations where Claude remains uncertain after reasonable investigation

Do not use it for:

- trivial implementation decisions
- naming or formatting preferences
- routine code changes
- questions already answered by verified repository facts
- repeated consultation on the same unchanged issue

Normally consult Codex only once for the same decision.

## Codex role

Codex is an advisor, not an authority.

The advisor is strictly read-only.

Do not ask Codex to:

- create files
- modify files
- delete files
- implement the solution
- commit changes

Ask Codex to:

- challenge Claude's assumptions
- identify concrete risks
- identify missed failure modes
- verify relevant repository facts
- compare meaningful alternatives
- distinguish facts from inference
- recommend an approach when justified

## Invocation

Prepare a self-contained advisor request and invoke:

```bash
codex-advisor high <<'EOF'
<advisor request>
EOF