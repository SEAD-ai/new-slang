#!/usr/bin/env bash
# Write config.json from the onboarding answers. Called by the skill, not by hand.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LANG_ID="${1:?language}"; LEVEL="${2:?level}"; AMBIENT="${3:-true}"; INANSWER="${4:-false}"; DENSITY="${5:-seasoned}"
grep -q "^${LANG_ID}	" "$HERE/languages/_manifest.tsv" || { echo "unknown language: $LANG_ID" >&2; exit 1; }
case "$LEVEL" in beginner|intermediate|pro) ;; *) echo "bad level: $LEVEL" >&2; exit 1;; esac
CONF="${NEWSLANG_CONFIG:-$HOME/.claude/newslang-config.json}"
jq -n --arg l "$LANG_ID" --arg v "$LEVEL" --argjson a "$AMBIENT" --argjson i "$INANSWER" --arg d "$DENSITY" \
  '{language:$l,level:$v,channels:{ambient:$a,inAnswer:$i},density:$d,rotate:6}' > "$CONF"
echo "configured: $(awk -F'\t' -v l="$LANG_ID" '$1==l{print $2}' "$HERE/languages/_manifest.tsv"), $LEVEL"
