```markdown
---
name: codex-review
description: Coordinate an independent Codex review of specifications, architecture documents, API designs, source code, and security-sensitive files. Use when the user asks Codex to review a file or wants a second-model review.
---

# Codex Review

Use Codex as an independent second reviewer.

Codex must not be launched from Claude Code's Bash sandbox because Codex
app-server initialization may fail under the nested sandbox.

Never invoke:

- `codex`
- `codex exec`
- Codex Claude plugin review commands

from Claude Code Bash for this workflow.

Instead, use the external `codex-review` script and let the user run it in
their normal terminal.

## Review types

Select the review type that best matches the artifact.

### `spec`

Use for:

- implementation specifications
- feature specifications
- PRDs
- technical design documents
- implementation plans with behavioral requirements

Prefer `spec` when the document primarily describes what should be built.

### `architecture`

Use for:

- system architecture
- component architecture
- technical architecture decisions
- subsystem boundaries
- data flows
- rendering or processing pipelines
- infrastructure design

Prefer `architecture` when the important questions are structural rather than
feature-level requirements.

### `api`

Use for:

- public APIs
- SDK APIs
- interfaces
- contracts
- schemas
- events
- extension APIs
- backwards-compatible API evolution

### `code`

Use for:

- source files
- implementations
- algorithms
- libraries
- utilities
- refactors

### `security`

Use when security is the primary concern, including:

- authentication
- authorization
- trust boundaries
- credential handling
- secrets
- externally reachable services
- untrusted input
- security-sensitive workflows

## Starting a review

When the user asks Codex to review a file:

1. Determine the exact file path.
2. Select the most appropriate review type.
3. Do not run Codex yourself.
4. Give the user this command:

```bash
codex-review <review-type> "<file>"
```

Example:

```bash
codex-review spec "docs/model-alignment-design.md"
```

Do not ask the user to manually calculate the output filename.

The script creates the review beside the original file by inserting
`-reviewed` before the extension.

Examples:

```text
model-alignment-design.md
model-alignment-design-reviewed.md
```

```text
viewer-api.ts
viewer-api-reviewed.ts
```

## After the review

When the user says the review has completed, or otherwise asks to process the
review:

1. Read the original file.
2. Read the corresponding `-reviewed` file.
3. Inspect relevant repository files when needed to verify a finding.
4. Evaluate every Codex finding independently.

Do not assume Codex is correct.

Classify findings as:

- **Accepted**
- **Rejected**
- **Needs clarification**

### Accept a finding when

- it identifies a real contradiction
- required behavior is genuinely unspecified
- it exposes a realistic failure mode
- it identifies an implementation risk supported by the repository
- it catches a compatibility, performance, security, or correctness problem

### Reject a finding when

- it conflicts with an explicit requirement
- it misunderstands the existing architecture
- the behavior is already handled elsewhere
- it expands scope without justification
- it assumes requirements that do not exist
- it is merely stylistic and has no implementation consequence
- it recommends a different design only because of preference

For intentional trade-offs, explain the trade-off rather than automatically
accepting or rejecting the recommendation.

## Applying a review

Do not modify the original artifact merely because a review exists.

Only update it when the user asks to apply, incorporate, fold in, fix, or
otherwise act on the review.

When updating:

1. Preserve the original design intent.
2. Apply accepted findings using the smallest appropriate changes.
3. Do not apply rejected findings.
4. Keep unresolved product or architecture decisions explicit.
5. Do not silently expand scope.
6. Preserve terminology and conventions already used by the document.

After updating, report:

- accepted findings
- rejected findings
- unresolved questions
- significant changes
- overall readiness

## Re-review

Do not automatically launch another Codex review after changes.

If another independent review would materially help, tell the user they can
run the same `codex-review` command again.
```