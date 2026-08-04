#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# Claude Code Status Line · Starter Kit #06
# ═══════════════════════════════════════════════════════════════
# Designed by 雷蒙（Raymond Hou）
# Source: https://github.com/Raymondhou0917/claude-code-resources
# Docs: https://cc.lifehacker.tw
# Newsletter: https://raymondhouch.com/
# Threads: @raymond0917
# License: CC BY-NC-SA 4.0 · 個人使用自由；禁止商業用途
# ═══════════════════════════════════════════════════════════════
# 想改顯示什麼？下面這幾行 true/false 切換就好。

# ── Display toggles (set to false to hide a field) ──
EMOJI_STR="🦹🍫"
SHOW_MODEL=true
SHOW_CONTEXT_BAR=true
SHOW_RATE_5H=true
SHOW_RATE_7D=true
SHOW_GIT_BRANCH=true
SHOW_GIT_DIFF=true
SHOW_PROJECT=true
SHOW_LAST_MSG=true # Show last message timestamp (requires the UserPromptSubmit hook)
LAST_MSG_FILE="$HOME/.claude/last-session-msg"

# ── Color definitions ──
WH=$'\033[97m'
GR=$'\033[38;2;80;200;81m'
YL=$'\033[38;2;255;235;59m'
OG=$'\033[38;2;255;152;0m'
RD=$'\033[38;2;244;67;54m'
MD=$'\033[38;2;246;184;90m'
DM=$'\033[90m'
RS=$'\033[0m'
SEP="${DM} │ ${RS}"

input=$(cat)

# ── Parse JSON from Claude Code ──
model=$(echo "$input" | jq -r '.model.display_name // ""')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
rl_5h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
rl_5h_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
rl_7d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
rl_7d_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# ══════ LINE 1 ══════
L1=""
[ -n "$EMOJI_STR" ] && L1="${EMOJI_STR} "

# Model name
if $SHOW_MODEL && [ -n "$model" ]; then
  L1="${L1}${SEP}${MD}${model}${RS}"
fi

# Context gradient progress bar
if $SHOW_CONTEXT_BAR && [ -n "$remaining" ]; then
  pct=$(printf '%.0f' "$remaining")
  used=$((100 - pct))
  BAR_W=12
  filled=$(( used * BAR_W / 100 ))
  z1=$(( BAR_W / 4 )); z2=$(( BAR_W / 2 )); z3=$(( BAR_W * 3 / 4 ))
  bar=""
  for ((n=0; n<BAR_W; n++)); do
    if [ $n -lt $filled ]; then
      if   [ $n -lt $z1 ]; then c=$GR
      elif [ $n -lt $z2 ]; then c=$YL
      elif [ $n -lt $z3 ]; then c=$OG
      else                       c=$RD
      fi
      bar="${bar}${c}█${RS}"
    else
      bar="${bar}${DM}░${RS}"
    fi
  done
  if   [ $used -lt 25 ]; then pc=$GR
  elif [ $used -lt 50 ]; then pc=$YL
  elif [ $used -lt 75 ]; then pc=$OG
  else                        pc=$RD
  fi
  L1="${L1}${SEP}${bar} ${pc}${pct}%${RS}"
fi

# 5-hour rate limit
if $SHOW_RATE_5H && [ -n "$rl_5h" ]; then
  used_5h=$(printf '%.0f' "$rl_5h")
  rem_5h=$((100 - used_5h))
  if [ -n "$rl_5h_reset" ]; then
    now=$(date +%s)
    diff=$(( rl_5h_reset - now ))
    if [ $diff -gt 0 ]; then
      h=$(( diff / 3600 ))
      m=$(( (diff % 3600) / 60 ))
      countdown="${h}H${m}m"
    else
      countdown="now"
    fi
    L1="${L1}${SEP}${DM}5h:${RS} ${countdown} ${rem_5h}%"
  else
    L1="${L1}${SEP}${DM}5h:${RS} ${rem_5h}%"
  fi
fi

# 7-day rate limit
if $SHOW_RATE_7D && [ -n "$rl_7d" ]; then
  used_7d=$(printf '%.0f' "$rl_7d")
  rem_7d=$((100 - used_7d))
  if [ -n "$rl_7d_reset" ]; then
    now=$(date +%s)
    diff=$(( rl_7d_reset - now ))
    if [ $diff -gt 0 ]; then
      d=$(( diff / 86400 ))
      h=$(( (diff % 86400) / 3600 ))
      countdown="${d}D${h}H"
    else
      countdown="now"
    fi
    L1="${L1}${SEP}${DM}7d:${RS} ${countdown} ${rem_7d}%"
  else
    L1="${L1}${SEP}${DM}7d:${RS} ${rem_7d}%"
  fi
fi

# ══════ LINE 2 ══════

L2=""
git_top=$(git rev-parse --show-toplevel 2>/dev/null)

if [ -n "$git_top" ] && git -C "$git_top" rev-parse --git-dir > /dev/null 2>&1; then
  if $SHOW_GIT_BRANCH; then
    br=$(git branch --show-current 2>/dev/null)
    if [ -n "$br" ]; then
      dirty=""
      git diff-index --quiet HEAD -- 2>/dev/null || dirty="*"
      [ -z "$dirty" ] && [ -n "$(git ls-files --others --exclude-standard 2>/dev/null | head -1)" ] && dirty="*"
      L2="${WH}${br}${dirty}${RS}"
    fi
  fi

  if $SHOW_GIT_DIFF; then
    stat=$(git diff --shortstat HEAD 2>/dev/null)
    ins=$(echo "$stat" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+')
    del=$(echo "$stat" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+')
    if [ -n "$ins" ] || [ -n "$del" ]; then
      ds=""
      [ -n "$ins" ] && ds="${GR}+${ins}${RS}"
      [ -n "$ins" ] && [ -n "$del" ] && ds="${ds}${DM}/${RS}"
      [ -n "$del" ] && ds="${ds}${RD}-${del}${RS}"
      [ -n "$L2" ] && L2="${L2}${SEP}${ds}" || L2="${ds}"
    fi
  fi

  if $SHOW_PROJECT; then
    pname=$(basename "$git_top")
    if [ -n "$pname" ]; then
      [ -n "$L2" ] && L2="${L2}${SEP}${WH}${pname}${RS}" || L2="${WH}${pname}${RS}"
    fi
  fi
fi

# Last message timestamp (read from file written by UserPromptSubmit hook)
# This is NOT the current time — it's when you last sent a message in this session
if $SHOW_LAST_MSG && [ -f "$LAST_MSG_FILE" ]; then
  last_msg=$(cat "$LAST_MSG_FILE" 2>/dev/null)
  if [ -n "$last_msg" ]; then
    [ -n "$L2" ] && L2="${L2}${SEP}${DM}📝 Last Message:${RS} ${last_msg}" || L2="${DM}📝 Last Message:${RS} ${last_msg}"
  fi
fi

# ══════ Output ══════
printf '%s\n' "$L1"
[ -n "$L2" ] && printf '%s\n' "$L2"
