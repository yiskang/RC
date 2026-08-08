# Codex Advisor

`codex-advisor` lets Claude Code consult Codex as an independent,
read-only technical advisor without launching Codex directly from Claude
Code.

It is intended for cases where Claude would benefit from a second
technical opinion:

-   architecture decisions
-   difficult debugging or root-cause analysis
-   performance-sensitive designs
-   concurrency and lifecycle issues
-   security-sensitive decisions
-   compatibility or migration risks
-   implementation approaches with meaningful trade-offs

Claude remains the primary agent and decision maker. Codex acts only as
an advisor.

## Why this exists

On affected environments, Codex processes launched from Claude Code may
inherit Claude Code's process-tree sandbox restrictions.

Related issue:

https://github.com/openai/codex-plugin-cc/issues/603

`codex-advisor` avoids this by separating Claude Code and Codex
execution:

``` text
Claude Code
    |
    | writes request
    v
.codex-advisor/
    |
    | file queue
    v
Codex Advisor Worker
    |
    | started independently
    v
codex exec --sandbox read-only
    |
    v
response
    |
    v
Claude Code
```

------------------------------------------------------------------------

## Components

``` text
codex-advisor/
├── SKILL.md
├── README.md
├── codex-advisor.sh
├── codex-advisor-worker.sh
└── prompt.md
```

### SKILL.md

Defines when Claude should consult Codex and how the result should be
evaluated.

### codex-advisor.sh

Client command used by Claude Code.

Responsibilities:

-   create advisor requests
-   write requests to the queue
-   wait for responses
-   support cancellation
-   never launch Codex directly

### codex-advisor-worker.sh

External worker.

Responsibilities:

-   monitor advisor requests
-   launch `codex exec`
-   run Codex in read-only mode
-   write responses
-   handle cancellation
-   maintain heartbeat and lock state

### prompt.md

Defines Codex's advisor role.

Codex is instructed to:

-   operate read-only
-   challenge assumptions
-   identify risks and failure modes
-   inspect repository files when useful
-   distinguish facts from inference
-   suggest meaningful alternatives

------------------------------------------------------------------------

# Setup

## Installation

Make scripts executable:

``` bash
chmod +x /path/to/codex-advisor/*.sh
```

Install the Claude Code skill:

``` bash
mkdir -p ~/.claude/skills

ln -sfn /path/to/codex-advisor ~/.claude/skills/codex-advisor
```

Install commands:

``` bash
mkdir -p ~/.local/bin

ln -sfn /path/to/codex-advisor.sh ~/.local/bin/codex-advisor
ln -sfn /path/to/codex-advisor-worker.sh ~/.local/bin/codex-advisor-worker
```

Ensure `~/.local/bin` is in `PATH`.

------------------------------------------------------------------------

## Git Ignore Cache Folder

The worker creates:

``` text
.codex-advisor/
```

This contains local runtime data and should not be committed.

Recommended global ignore:

``` bash
git config --global core.excludesfile ~/.gitignore_global
echo '.codex-advisor/' >> ~/.gitignore_global

# Check the global ignore file:
git config --global --get core.excludesfile
```

------------------------------------------------------------------------

## How to Use

### Start the Worker

The current implementation uses one worker per Git repository.

Start from the project directory:

``` bash
cd /path/to/project
codex-advisor-worker
```

Example:

``` text
Codex Advisor worker

Repo: /Users/example/project
Model: gpt-5.6-sol

Waiting for requests...
```

The worker must be started from an independent Terminal process.

Do not start it from Claude Code.

------------------------------------------------------------------------

### Submit an Advisor Request

Example:

``` bash
codex-advisor high <<'EOF'
Question:
Should we keep one BVH per Viewer fragment or merge geometry first?

Context:
We need browser-side collision detection.

Please challenge the design and identify risks.
EOF
```

Reasoning effort:

``` text
low
medium
high
xhigh
```

Default:

``` text
high
```

------------------------------------------------------------------------

# Troubleshooting

## Worker cannot start

Error:

``` text
Error: Codex Advisor worker must be started from inside the Git repository you want it to serve.
```

The worker is repository-scoped.

Run:

``` bash
cd /path/to/project
codex-advisor-worker
```

------------------------------------------------------------------------

## Ctrl+C does not stop the worker

The worker should use separate signal handlers:

``` zsh
trap cleanup EXIT
trap 'shutdown 130' INT
trap 'shutdown 143' TERM
trap 'shutdown 129' HUP
```

An older implementation only executed cleanup and returned to the worker
loop.

------------------------------------------------------------------------

## zsh error: read-only variable: status

`status` is a reserved zsh variable.

Incorrect:

``` zsh
local status="$1"
status=$?
```

Correct:

``` zsh
local exit_code="$1"
exit_code=$?
```

------------------------------------------------------------------------

## How to know Codex Advisor is running

Worker output:

``` text
→ Request <request-id>
  Reasoning: high
  Status: Codex is thinking...
```

Completed:

``` text
✓ Request <request-id> completed
```

Check:

``` bash
pgrep -af 'codex exec'
```

------------------------------------------------------------------------

## How to stop the worker

Press:

``` text
Ctrl+C
```

The worker removes:

``` text
.codex-advisor/heartbeat
.codex-advisor/worker.lock/
```

From another terminal:

``` bash
pgrep -af codex-advisor-worker
kill <PID>
```

Avoid `kill -9` because cleanup handlers cannot run.

------------------------------------------------------------------------

## Is worker.lock a file or directory?

It is intentionally an empty directory:

``` text
.codex-advisor/worker.lock/
```

It is created using:

``` zsh
mkdir "$lock_dir"
```

Directory creation is atomic, allowing only one worker instance.

------------------------------------------------------------------------

## Why is requests empty after completion?

Expected lifecycle:

``` text
requests/
    |
    v
working/
    |
    v
responses/
```

After completion:

``` text
.codex-advisor/
├── requests/
├── working/
└── responses/
    └── <request-id>/
        ├── response.md
        └── codex.log
```

------------------------------------------------------------------------

## Cancel a request

Use:

``` bash
codex-advisor cancel <request-id>
```

Only the selected request is cancelled. The worker continues running.

------------------------------------------------------------------------

## Stale worker lock

Check:

``` bash
pgrep -af codex-advisor-worker
```

If no worker exists:

``` bash
rm -rf .codex-advisor/worker.lock
rm -f .codex-advisor/heartbeat
```

Restart the worker.

------------------------------------------------------------------------

# Common Questions

## Why does Codex run outside Claude Code?

The separation provides:

-   independent process lifecycle
-   predictable read-only execution
-   custom cancellation
-   avoidance of Claude Code process restrictions

------------------------------------------------------------------------

## Can Claude automatically use Codex as an advisor?

Yes.

The skill is designed for Claude to selectively consult Codex when an
independent opinion improves the result.

Claude remains responsible for the final decision.

------------------------------------------------------------------------

## Why not use codex-plugin-cc directly?

The external worker approach provides:

-   explicit process separation
-   predictable behavior
-   custom lifecycle control
-   custom request handling

The transport can be replaced later if official advisor support becomes
suitable.

------------------------------------------------------------------------

## Codex Advisor vs Codex Review

They solve different problems.

Codex Advisor:

-   answers technical questions
-   challenges assumptions
-   supports decisions during development

Codex Review:

-   reviews existing artifacts
-   produces formal findings
-   reviews specifications, architecture, APIs, and code

Keep the workflows separate.

------------------------------------------------------------------------

# Design Principles

1.  Claude is the primary agent.
2.  Codex is an advisor, not an authority.
3.  Codex runs read-only.
4.  Claude evaluates Codex findings independently.
5.  Codex is not launched from Claude Code.
6.  Avoid unnecessary advisor loops.

------------------------------------------------------------------------

# Current Limitations

The current implementation is repository-specific:

``` text
Project A -> Worker A
Project B -> Worker B
```

A future version could use a global worker:

``` text
Multiple projects
        |
        v
Global Advisor Worker
        |
        v
Codex
```

The current design keeps the implementation simple and easy to validate.

## License

MIT License — see [LICENSE](../../../LICENSE).

## Written by

Eason Kang [in/eason-kang-b4398492/](https://www.linkedin.com/in/eason-kang-b4398492)