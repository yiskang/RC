Perform a security-focused review of:

{{INPUT_FILE}}

Repository root:

{{REPO_ROOT}}

Act as a senior application security engineer.

Inspect relevant repository files when needed to understand trust boundaries,
callers, data flow, deployment context, authentication, authorization, and
existing mitigations.

Do not modify any files.

Evaluate:

- trust boundaries
- authentication
- authorization
- privilege escalation
- credential and secret handling
- sensitive data exposure
- input validation
- injection
- command execution
- path handling
- file access
- network exposure
- SSRF
- request forgery
- unsafe deserialization
- race conditions
- replay
- insecure defaults
- dependency assumptions
- sandbox boundaries
- logging of sensitive data
- error-information leakage
- denial-of-service vectors
- abuse cases

Distinguish between:

- confirmed vulnerability
- credible security risk
- defense-in-depth recommendation

Do not present speculative threats as confirmed vulnerabilities.

For every finding include:

- Severity
- Confidence
- Location
- Threat
- Exploitation or failure scenario
- Existing mitigation, if any
- Recommended mitigation

Use:

# Executive Summary

# Critical Vulnerabilities

# Security Risks

# Defense-in-Depth Improvements

# Trust-Boundary Questions

# Positive Observations

# Overall Security Readiness

Choose exactly one:

- Ready
- Ready with minor revisions
- Requires major revision