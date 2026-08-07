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

TYPE="$(jq -r '.notification_type // ""' <<<"$INPUT")"
MESSAGE="$(jq -r '.message // ""' <<<"$INPUT")"
CWD="$(jq -r '.cwd // ""' <<<"$INPUT")"

PROJECT="$(basename "$CWD")"

case "$TYPE" in

    idle_prompt)
        # publish \
        #     "✅ Claude Finished" \
        #     "$PROJECT"
        # Claude merely finished or became idle; no action required.
        exit 0
        ;;

    agent_needs_input)
        publish \
            "❓ Claude Needs Input" \
            "$PROJECT" \
            high \
            "question,robot"
        ;;

    elicitation_dialog)
        publish \
            "📝 Claude Question" \
            "$PROJECT" \
            high \
            "question,robot"
        ;;

    *)
        if [[ -n "$MESSAGE" ]]; then
            publish \
                "🤖 Claude Code" \
                "$MESSAGE"
        fi
        # # Ignore unknown informational notifications.
        # exit 0
        ;;

esac