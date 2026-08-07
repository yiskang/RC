#!/usr/bin/env bash

set -euo pipefail

COMMON="$HOME/.claude/hooks/ntfy-common.sh"

if [[ ! -r "$COMMON" ]]; then
    echo "Missing: $COMMON" >&2
    exit 0
fi

# shellcheck disable=SC1090
source "$COMMON"

INPUT="$(cat)"

TOOL="$(jq -r '.tool_name // ""' <<<"$INPUT")"
CWD="$(jq -r '.cwd // ""' <<<"$INPUT")"

PROJECT="$(basename "$CWD")"

case "$TOOL" in

    Bash)

        COMMAND="$(jq -r '.tool_input.command // ""' <<<"$INPUT")"

        publish \
            "🔐 Bash Permission" \
            "${PROJECT}

${COMMAND}" \
            high \
            "terminal,lock"

        ;;

    Edit)

        FILE="$(jq -r '.tool_input.file_path // ""' <<<"$INPUT")"

        publish \
            "📝 Edit Permission" \
            "${PROJECT}

${FILE}" \
            default \
            "memo"

        ;;

    Write)

        FILE="$(jq -r '.tool_input.file_path // ""' <<<"$INPUT")"

        publish \
            "📄 Write Permission" \
            "${PROJECT}

${FILE}" \
            default \
            "page_facing_up"

        ;;

    ExitPlanMode)

        publish \
            "🚀 Ready to Execute Plan" \
            "$PROJECT" \
            high \
            "rocket"

        ;;

    *)

        publish \
            "🤖 Permission Request" \
            "${PROJECT}

Tool: ${TOOL}" \
            default \
            "robot"

        ;;

esac