#!/usr/bin/env zsh

set -u

usage() {
    cat >&2 <<EOF
Usage: $(basename "$0") <review-type> <file> [reasoning-effort]

Review types:
  spec          Specification / design document
  architecture  Architecture / system design
  api           API / SDK / interface design
  code          Source code
  security      Security-sensitive design or code

Reasoning effort:
  low
  medium
  high
  xhigh

Default:
  CODEX_REVIEW_EFFORT environment variable, or "high" if not set.

Examples:
  $(basename "$0") spec docs/design.md
  $(basename "$0") spec docs/design.md medium
  $(basename "$0") architecture docs/system.md xhigh
  CODEX_REVIEW_EFFORT=medium $(basename "$0") code src/foo.ts
EOF
    exit 2
}

if (( $# < 2 || $# > 3 )); then
    usage
fi

review_type="$1"
input="$2"
reasoning_effort="${3:-${CODEX_REVIEW_EFFORT:-high}}"

case "$review_type" in
    spec|architecture|api|code|security)
        ;;
    *)
        echo "Error: unsupported review type: $review_type" >&2
        echo >&2
        usage
        ;;
esac

case "$reasoning_effort" in
    low|medium|high|xhigh)
        ;;
    *)
        echo "Error: unsupported reasoning effort: $reasoning_effort" >&2
        echo "Allowed values: low, medium, high, xhigh" >&2
        exit 2
        ;;
esac

if [[ ! -f "$input" ]]; then
    echo "Error: file not found: $input" >&2
    exit 1
fi

# Resolve the script directory so the skill is self-contained.
script_dir="${0:A:h}"

# Resolve the input to an absolute path.
input_abs="$(
    cd -- "$(dirname -- "$input")" &&
    printf '%s/%s\n' "$PWD" "$(basename -- "$input")"
)" || exit 1

dir="${input_abs:h}"
base="${input_abs:t}"

# Generate:
#
#   foo.md  -> foo-reviewed.md
#   foo.ts  -> foo-reviewed.ts
#   foo     -> foo-reviewed
#
if [[ "$base" == *.* ]]; then
    stem="${base%.*}"
    ext="${base##*.}"
    output="${dir}/${stem}-reviewed.${ext}"
else
    stem="$base"
    output="${dir}/${stem}-reviewed"
fi

template="${script_dir}/prompts/${review_type}.md"

if [[ ! -f "$template" ]]; then
    echo "Error: review template not found: $template" >&2
    exit 1
fi

# Determine repository root when possible.
repo_root="$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null || true)"

if [[ -z "$repo_root" ]]; then
    repo_root="$dir"
fi

# Load prompt template.
prompt="$(<"$template")"

# Substitute supported variables.
prompt="${prompt//\{\{INPUT_FILE\}\}/$input_abs}"
prompt="${prompt//\{\{INPUT_NAME\}\}/$base}"
prompt="${prompt//\{\{OUTPUT_FILE\}\}/$output}"
prompt="${prompt//\{\{REPO_ROOT\}\}/$repo_root}"

echo "Codex review"
echo
echo "Type:      $review_type"
echo "Effort:    $reasoning_effort"
echo "Input:     $input_abs"
echo "Output:    $output"
echo "Repo:      $repo_root"
echo

# Run Codex from the user's normal terminal.
#
# This command is intentionally NOT expected to run from Claude Code's
# sandbox because Codex app-server initialization may be blocked there.
codex exec \
    --sandbox read-only \
    --model gpt-5.6-sol \
    -c "model_reasoning_effort=\"$reasoning_effort\"" \
    -o "$output" \
    "$prompt"

status=$?

echo

if (( status != 0 )); then
    echo "Codex review failed with exit code $status" >&2
    exit "$status"
fi

echo "Review saved to:"
echo "  $output"
echo
echo "Next step in Claude Code:"
echo
echo "  Review is complete. Read and compare:"
echo "  - $input_abs"
echo "  - $output"
echo
echo "  Validate each Codex finding against the original document and repository."
echo "  Classify findings as Accepted, Rejected, or Needs clarification."
echo "  Do not modify the original file unless I ask you to apply the review."

exit 0