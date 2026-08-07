#!/usr/bin/env bash

set -euo pipefail

CONFIG="$HOME/.ntfy/claude.env"

if [[ ! -r "$CONFIG" ]]; then
    echo "Missing ntfy config: $CONFIG" >&2
    exit 0
fi

# shellcheck disable=SC1090
source "$CONFIG"

if ! command -v jq >/dev/null 2>&1; then
    echo "jq not installed" >&2
    exit 0
fi

publish() {
    local title="$1"
    local body="$2"
    local priority="${3:-default}"
    local tags="${4:-robot}"
    local click="${5:-${NTFY_CLICK_URL:-termius://}}"
    local actions="${6:-}"

    local args=(
        --silent
        --show-error
        --fail
        --connect-timeout 2
        --max-time 5
        -H "Authorization: Bearer ${NTFY_TOKEN}"
        -H "Title: ${title}"
        -H "Priority: ${priority}"
        -H "Tags: ${tags}"
    )

    if [[ -n "$click" ]]; then
        args+=(-H "Click: ${click}")
    fi

    if [[ -n "$actions" ]]; then
        args+=(-H "Actions: ${actions}, clear=true")
    fi

    curl \
        "${args[@]}" \
        -d "${body}" \
        "${NTFY_SERVER}/${NTFY_TOPIC}" \
        >/dev/null || true
}