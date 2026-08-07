Review the source file at:

{{INPUT_FILE}}

Repository root:

{{REPO_ROOT}}

Act as a senior engineer performing an independent correctness-focused code
review.

Inspect related repository files when necessary to understand callers,
contracts, lifecycle, tests, and surrounding implementation.

Do not modify any files.

Focus on actionable issues involving:

- correctness
- incorrect assumptions
- edge cases
- error handling
- resource cleanup
- lifecycle problems
- race conditions
- async behavior
- state corruption
- API misuse
- security
- performance regressions
- unnecessary allocations or expensive work
- backwards compatibility
- maintainability risks likely to cause future defects
- missing or inadequate tests

Ignore:

- formatting
- subjective style
- naming preferences without practical impact
- refactoring suggestions that provide no concrete benefit

For each finding include:

- Severity
- File and location
- Problem
- Concrete failure scenario
- Recommended fix

Prefer a small number of high-confidence findings over speculative issues.

Use:

# Executive Summary

# Critical Issues

# Important Issues

# Performance / Resource Concerns

# Testing Gaps

# Positive Observations

# Overall Assessment