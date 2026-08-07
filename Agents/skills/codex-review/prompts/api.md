Review the API or SDK design at:

{{INPUT_FILE}}

Repository root:

{{REPO_ROOT}}

Act as a senior API and SDK designer reviewing the contract before release.

Inspect relevant repository files when useful to understand existing APIs,
conventions, compatibility requirements, or implementation constraints.

Do not modify any files.

Evaluate:

- API clarity
- naming consistency
- abstraction boundaries
- parameter semantics
- return-value semantics
- error behavior
- lifecycle requirements
- state transitions
- ownership rules
- nullability and optional values
- validation
- async behavior
- concurrency expectations
- cancellation
- extensibility
- backwards compatibility
- versioning
- discoverability
- misuse resistance
- testability
- performance implications
- security implications

Pay special attention to behavior that callers could reasonably interpret in
more than one way.

For every actionable finding include:

- Severity
- API/member/section
- Problem
- Caller failure scenario
- Compatibility impact
- Recommended contract change

Avoid stylistic naming comments unless they create real ambiguity or violate an
established API convention in the repository.

Use:

# Executive Summary

# Critical Contract Issues

# Important API Improvements

# Compatibility Risks

# Ambiguities / Questions

# Positive Observations

# Overall Readiness

Choose exactly one:

- Ready
- Ready with minor revisions
- Requires major revision