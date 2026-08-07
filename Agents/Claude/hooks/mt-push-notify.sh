#!/bin/sh
# MT Push Notify — Claude Code Hook Script
# Installed by: setup-hooks.sh
# Reads stdin JSON from Claude Code, extracts activity content,
# and sends a minimal push notification via MT relay.
#
# Usage (called automatically by Claude Code hooks):
#   mt-push-notify.sh stop          — on task completion
#   mt-push-notify.sh notification  — on permission request

RELAY_URL="https://mt-push.jaga-farm.com/v1/notify"
SECRET_FILE="${HOME}/.config/mt-push/device-secret"
HOOK_TYPE="${1:-stop}"

if [ ! -r "$SECRET_FILE" ]; then
  exit 0
fi

DEVICE_SECRET=$(cat "$SECRET_FILE")

if [ -z "$DEVICE_SECRET" ]; then
  exit 0
fi

INPUT=$(cat)

# Gather minimal remote server context for session matching.
REMOTE_HOST=$(hostname -f 2>/dev/null || hostname)

HAS_TMUX=false
TMUX_SESSION=""
if [ -n "$TMUX" ]; then
  HAS_TMUX=true
  TMUX_SESSION=$(tmux display-message -p '#S' 2>/dev/null || echo "")
fi

if [ "$HOOK_TYPE" = "stop" ]; then
  EVENT="agent-done"
  FIELD="last_assistant_message"
  FALLBACK="Task complete"
else
  EVENT="agent-input"
  FIELD="message"
  FALLBACK="Permission needed"
fi

# Build JSON body using Node.js (preferred) or Python 3 (fallback).
BODY=""

if command -v node >/dev/null 2>&1; then
  BODY=$(printf '%s' "$INPUT" | node -e "
    let d = '';

    process.stdin.on('data', c => d += c);

    process.stdin.on('end', () => {
      const field = process.argv[1];
      const fallback = process.argv[2];
      const token = process.argv[3];
      const event = process.argv[4];
      const host = process.argv[5];
      const hasTmux = process.argv[6] === 'true';
      const tmuxSession = process.argv[7];

      let message = fallback;

      try {
        const input = JSON.parse(d);
        message = String(input[field] || fallback).substring(0, 200);
      } catch (_) {
        // Keep fallback message.
      }

      const body = {
        token,
        event,
        message,
        host,
        has_tmux: hasTmux
      };

      if (tmuxSession) {
        body.tmux_session = tmuxSession;
      }

      process.stdout.write(JSON.stringify(body));
    });
  " \
    "$FIELD" \
    "$FALLBACK" \
    "$DEVICE_SECRET" \
    "$EVENT" \
    "$REMOTE_HOST" \
    "$HAS_TMUX" \
    "$TMUX_SESSION" \
    2>/dev/null)

elif command -v python3 >/dev/null 2>&1; then
  BODY=$(printf '%s' "$INPUT" | python3 -c "
import json
import sys

field = sys.argv[1]
fallback = sys.argv[2]
token = sys.argv[3]
event = sys.argv[4]
host = sys.argv[5]
has_tmux = sys.argv[6] == 'true'
tmux_session = sys.argv[7] if len(sys.argv) > 7 else ''

message = fallback

try:
    data = json.load(sys.stdin)
    message = str(data.get(field, fallback))[:200]
except Exception:
    pass

body = {
    'token': token,
    'event': event,
    'message': message,
    'host': host,
    'has_tmux': has_tmux
}

if tmux_session:
    body['tmux_session'] = tmux_session

print(json.dumps(body), end='')
  " \
    "$FIELD" \
    "$FALLBACK" \
    "$DEVICE_SECRET" \
    "$EVENT" \
    "$REMOTE_HOST" \
    "$HAS_TMUX" \
    "$TMUX_SESSION" \
    2>/dev/null)
fi

# Do not attempt unsafe manual JSON construction if neither runtime exists.
[ -n "$BODY" ] || exit 0

curl -sS \
  -X POST "$RELAY_URL" \
  -H "Content-Type: application/json" \
  --data-binary "$BODY" \
  >/dev/null 2>&1 &