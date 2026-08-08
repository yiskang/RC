#!/usr/bin/env zsh

set -u

usage() {
    cat >&2 <<EOF
Usage:
  $(basename "$0") [reasoning-effort]
  $(basename "$0") cancel <request-id>

Submit mode reads the advisor request from stdin.

Reasoning effort:
  low
  medium
  high
  xhigh

Default:
  CODEX_ADVISOR_EFFORT, or "high"

Environment:
  CODEX_ADVISOR_TIMEOUT  Wait timeout in seconds (default: 600)

Examples:

  $(basename "$0") high <<'EOF_REQUEST'
  Question:
  Should we keep one BVH per Viewer fragment?

  Context:
  ...
  EOF_REQUEST

  $(basename "$0") cancel 20260808-172512-12345-6789
EOF
    exit 2
}

repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    echo "Error: codex-advisor must be run from inside the Git repository being advised." >&2
    exit 1
}

queue_dir="${repo_root}/.codex-advisor"
requests_dir="${queue_dir}/requests"
working_dir="${queue_dir}/working"
responses_dir="${queue_dir}/responses"
cancel_dir="${queue_dir}/cancel"
heartbeat_file="${queue_dir}/heartbeat"

mkdir -p \
    "$requests_dir" \
    "$working_dir" \
    "$responses_dir" \
    "$cancel_dir" || exit 1

#
# Cancel mode
#

if [[ "${1:-}" == "cancel" ]]; then
    if (( $# != 2 )); then
        usage
    fi

    request_id="$2"

    if [[ ! "$request_id" =~ '^[A-Za-z0-9._-]+$' ]]; then
        echo "Error: invalid request ID." >&2
        exit 2
    fi

    ready_request="${requests_dir}/${request_id}.ready"
    running_request="${working_dir}/${request_id}.running"
    response_dir="${responses_dir}/${request_id}"
    cancel_file="${cancel_dir}/${request_id}"

    if [[ -d "$response_dir" ]]; then
        if [[ -f "${response_dir}/response.md" ]]; then
            echo "Request has already completed: $request_id" >&2
            exit 1
        fi

        if [[ -f "${response_dir}/error.txt" ]]; then
            echo "Request has already failed: $request_id" >&2
            exit 1
        fi

        if [[ -f "${response_dir}/cancelled" ]]; then
            echo "Request has already been cancelled: $request_id"
            exit 0
        fi
    fi

    # A queued request can be cancelled immediately without worker action.
    if [[ -d "$ready_request" ]]; then
        /bin/rm -rf "$ready_request"

        mkdir -p "$response_dir"
        : > "${response_dir}/cancelled"

        echo "Cancelled queued Codex Advisor request: $request_id"
        exit 0
    fi

    # A running request is cancelled cooperatively by the worker.
    if [[ -d "$running_request" ]]; then
        : > "$cancel_file"

        echo "Cancellation requested for Codex Advisor request: $request_id"
        exit 0
    fi

    echo "Error: Codex Advisor request not found: $request_id" >&2
    exit 1
fi

#
# Submit mode
#

if (( $# > 1 )); then
    usage
fi

reasoning_effort="${1:-${CODEX_ADVISOR_EFFORT:-high}}"
timeout="${CODEX_ADVISOR_TIMEOUT:-600}"

case "$reasoning_effort" in
    low|medium|high|xhigh)
        ;;
    *)
        echo "Error: unsupported reasoning effort: $reasoning_effort" >&2
        exit 2
        ;;
esac

if [[ ! "$timeout" =~ '^[0-9]+$' ]]; then
    echo "Error: CODEX_ADVISOR_TIMEOUT must be an integer." >&2
    exit 2
fi

if [[ ! -f "$heartbeat_file" ]]; then
    echo "Error: Codex Advisor worker is not running." >&2
    echo "Start 'codex-advisor-worker' from an independent terminal." >&2
    exit 1
fi

now="$(date +%s)"
heartbeat="$(stat -f '%m' "$heartbeat_file" 2>/dev/null || echo 0)"

if (( now - heartbeat > 10 )); then
    echo "Error: Codex Advisor worker heartbeat is stale." >&2
    echo "Start or restart 'codex-advisor-worker' from an independent terminal." >&2
    exit 1
fi

question="$(cat)"

if [[ -z "${question//[[:space:]]/}" ]]; then
    echo "Error: advisor request is empty." >&2
    exit 2
fi

request_id="$(date +%Y%m%d-%H%M%S)-$$-${RANDOM}"

tmp_request="${requests_dir}/.${request_id}.tmp"
ready_request="${requests_dir}/${request_id}.ready"
response_dir="${responses_dir}/${request_id}"

mkdir "$tmp_request" || exit 1

printf '%s\n' "$reasoning_effort" > "${tmp_request}/effort"
printf '%s\n' "$question" > "${tmp_request}/request.md"

# Atomic handoff to the worker.
mv "$tmp_request" "$ready_request" || exit 1

echo "Codex Advisor request: $request_id" >&2
echo "Waiting for Codex Advisor..." >&2
echo "Cancel with: codex-advisor cancel $request_id" >&2

start_time="$(date +%s)"

while true; do
    if [[ -f "${response_dir}/response.md" ]]; then
        cat "${response_dir}/response.md"
        exit 0
    fi

    if [[ -f "${response_dir}/cancelled" ]]; then
        echo "Codex Advisor request was cancelled: $request_id" >&2
        exit 130
    fi

    if [[ -f "${response_dir}/error.txt" ]]; then
        echo "Codex Advisor failed:" >&2
        cat "${response_dir}/error.txt" >&2
        exit 1
    fi

    now="$(date +%s)"

    if (( now - start_time >= timeout )); then
        echo "Error: timed out waiting for Codex Advisor." >&2
        echo "Request ID: $request_id" >&2
        echo "The request may still be running." >&2
        echo "Cancel with: codex-advisor cancel $request_id" >&2
        exit 124
    fi

    sleep 1
done