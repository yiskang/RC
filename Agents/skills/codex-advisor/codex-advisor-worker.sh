#!/usr/bin/env zsh

set -u

script_dir="${0:A:h}"

repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    echo "Error: Codex Advisor worker must be started from inside the Git repository you want it to serve." >&2
    echo >&2
    echo "Example:" >&2
    echo "  cd /path/to/your/project" >&2
    echo "  codex-advisor-worker" >&2
    exit 1
}

if ! command -v codex >/dev/null 2>&1; then
    echo "Error: codex is not available in PATH." >&2
    exit 1
fi

prompt_template="${script_dir}/prompt.md"

if [[ ! -f "$prompt_template" ]]; then
    echo "Error: advisor prompt not found: $prompt_template" >&2
    exit 1
fi

queue_dir="${repo_root}/.codex-advisor"
requests_dir="${queue_dir}/requests"
working_dir="${queue_dir}/working"
responses_dir="${queue_dir}/responses"
cancel_dir="${queue_dir}/cancel"
heartbeat_file="${queue_dir}/heartbeat"
lock_dir="${queue_dir}/worker.lock"

mkdir -p \
    "$requests_dir" \
    "$working_dir" \
    "$responses_dir" \
    "$cancel_dir" || exit 1

if ! mkdir "$lock_dir" 2>/dev/null; then
    echo "Error: a Codex Advisor worker appears to already be running for this repository." >&2
    echo >&2
    echo "Repository:" >&2
    echo "  $repo_root" >&2
    echo >&2
    echo "If no worker is actually running, remove the stale lock directory:" >&2
    echo "  $lock_dir" >&2
    exit 1
fi

current_codex_pid=""
current_request_id=""

cleanup() {
    /bin/rm -f "$heartbeat_file"
    rmdir "$lock_dir" 2>/dev/null || true
}

shutdown() {
    local exit_code="$1"

    if [[ -n "$current_codex_pid" ]] &&
       kill -0 "$current_codex_pid" 2>/dev/null; then
        kill "$current_codex_pid" 2>/dev/null || true
        wait "$current_codex_pid" 2>/dev/null || true
    fi

    exit "$exit_code"
}

trap cleanup EXIT
trap 'shutdown 130' INT
trap 'shutdown 143' TERM
trap 'shutdown 129' HUP

echo "Codex Advisor worker"
echo
echo "Repo:  $repo_root"
echo "Model: ${CODEX_ADVISOR_MODEL:-gpt-5.6-sol}"
echo
echo "Waiting for requests..."
echo

while true; do
    touch "$heartbeat_file"

    for request in "${requests_dir}"/*.ready(N); do
        request_name="${request:t}"
        request_id="${request_name%.ready}"

        running="${working_dir}/${request_id}.running"
        cancel_file="${cancel_dir}/${request_id}"

        # Handle cancellation before claiming the request.
        if [[ -f "$cancel_file" ]]; then
            /bin/rm -rf "$request"
            /bin/rm -f "$cancel_file"

            mkdir -p "${responses_dir}/${request_id}"
            : > "${responses_dir}/${request_id}/cancelled"

            echo "[$(date '+%Y-%m-%d %H:%M:%S')] cancelled $request_id"
            continue
        fi

        # Atomically claim the request.
        if ! mv "$request" "$running" 2>/dev/null; then
            continue
        fi

        effort="$(<"${running}/effort")"
        question="$(<"${running}/request.md")"

        case "$effort" in
            low|medium|high|xhigh)
                ;;
            *)
                effort="high"
                ;;
        esac

        tmp_response="${responses_dir}/.${request_id}.tmp"
        final_response="${responses_dir}/${request_id}"

        mkdir "$tmp_response" || {
            echo "Failed to create response directory for request: $request_id" >&2
            /bin/rm -rf "$running"
            continue
        }

        prompt="$(
            cat "$prompt_template"

            cat <<EOF

Repository root:

$repo_root

Advisor request:

$question
EOF
        )"

        current_request_id="$request_id"

        echo "→ Request $request_id"
        echo "  Reasoning: $effort"
        echo "  Status: Codex is thinking..."

        (
            cd "$repo_root" || exit 1

            exec codex exec \
                --sandbox read-only \
                --model "${CODEX_ADVISOR_MODEL:-gpt-5.6-sol}" \
                -c "model_reasoning_effort=\"$effort\"" \
                -o "${tmp_response}/response.md" \
                "$prompt"
        ) >"${tmp_response}/codex.log" 2>&1 &

        current_codex_pid=$!

        #
        # Monitor Codex and cancellation requests.
        #
        while kill -0 "$current_codex_pid" 2>/dev/null; do
            touch "$heartbeat_file"

            if [[ -f "$cancel_file" ]]; then
                echo "  Status: cancelling..."

                kill "$current_codex_pid" 2>/dev/null || true
                wait "$current_codex_pid" 2>/dev/null || true

                current_codex_pid=""

                /bin/rm -f "$cancel_file"
                /bin/rm -rf "$tmp_response"

                mkdir -p "$final_response"
                : > "${final_response}/cancelled"

                /bin/rm -rf "$running"

                echo "✗ Request $request_id cancelled"
                echo

                break
            fi

            sleep 1
        done

        # Cancellation already completed the request.
        if [[ -f "${final_response}/cancelled" ]]; then
            current_request_id=""
            continue
        fi

        wait "$current_codex_pid"
        exit_code=$?

        current_codex_pid=""

        if (( exit_code != 0 )); then
            {
                echo "codex exec exited with status $exit_code"
                echo
                cat "${tmp_response}/codex.log"
            } > "${tmp_response}/error.txt"

            /bin/rm -f "${tmp_response}/response.md"
        elif [[ ! -s "${tmp_response}/response.md" ]]; then
            echo "Codex returned no advisor response." \
                > "${tmp_response}/error.txt"
        fi

        mv "$tmp_response" "$final_response"
        /bin/rm -rf "$running"

        touch "$heartbeat_file"

        if [[ -f "${final_response}/response.md" ]]; then
            echo "✓ Request $request_id completed"
        else
            echo "✗ Request $request_id failed"
        fi

        echo

        current_request_id=""
    done

    sleep 1
done