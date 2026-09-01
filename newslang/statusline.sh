#!/usr/bin/env bash
# New Slang — ambient vocabulary card for the Claude Code status line.
#
# Hot path: no network, no model calls, pure file reads. Claude Code cancels an
# in-flight status line script when a new update triggers, so speed is a feature.
#
# Contract:
#   line 1  ordinary status (dir · model · context) — the card is additive
#   line 2  the card, only when config enables ambient and the pool is non-empty
# Debug:    NEWSLANG_DEBUG=pool prints the filtered card pool and exits.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Config lives OUTSIDE the install dir: a plugin's cache is replaced on every
# update, which would wipe it and silently re-trigger onboarding.
CONF="${NEWSLANG_CONFIG:-$HOME/.claude/newslang-config.json}"
LANGS="$HERE/languages"
MANIFEST="$LANGS/_manifest.tsv"

HAVE_JQ=0; command -v jq >/dev/null 2>&1 && HAVE_JQ=1

get() { # get <jq-path> <default>  (strings/numbers only — see gate for booleans)
  local v=""
  [ -r "$CONF" ] && [ "$HAVE_JQ" = 1 ] && v=$(jq -r "$1 // empty" "$CONF" 2>/dev/null)
  printf '%s' "${v:-$2}"
}

# ---- colors (respect NO_COLOR) ----
if [ -n "${NO_COLOR:-}" ]; then
  R=""; DIM=""; B=""; C_GREEN=""; C_TEAL=""; C_GOLD=""; C_SLATE=""; C_AMBER=""; C_GREY=""
else
  E=$'\033'
  R="${E}[0m"; DIM="${E}[2m"; B="${E}[1m"
  C_GREEN="${E}[38;5;29m"; C_TEAL="${E}[38;5;31m"; C_GOLD="${E}[38;5;136m"
  C_SLATE="${E}[38;5;61m"; C_AMBER="${E}[38;5;130m"; C_GREY="${E}[38;5;244m"
fi

input=$(cat)

# ---- line 1 ----
dir=""; model=""; pct=""
if [ "$HAVE_JQ" = 1 ]; then
  dir=$(printf '%s' "$input"   | jq -r '.workspace.current_dir // .cwd // empty' 2>/dev/null)
  model=$(printf '%s' "$input" | jq -r '.model.display_name // empty' 2>/dev/null)
  pct=$(printf '%s' "$input"   | jq -r '.context_window.remaining_percentage // empty' 2>/dev/null)
fi
[ -n "$dir" ] && dir="~${dir#$HOME}"
line1="${DIM}${dir:-?}${R}"
[ -n "$model" ] && line1="$line1 ${DIM}·${R} ${DIM}${model}${R}"
[ -n "$pct" ]   && line1="$line1 ${DIM}·${R} ${DIM}${pct}% ctx${R}"
printf '%s\n' "$line1"

# ---- gate on config ----
# jq's // treats false as empty, so booleans need an explicit test or
# "ambient: false" silently falls through to the default and stays on.
ambient=true
if [ -r "$CONF" ] && [ "$HAVE_JQ" = 1 ]; then
  ambient=$(jq -r 'if .channels.ambient == false then "false" else "true" end' "$CONF" 2>/dev/null || echo true)
fi
[ "$ambient" = "true" ] || exit 0

# Never pick a language on the user's behalf. With no config at all this is a
# first run: nudge toward setup instead of silently defaulting to a deck they
# did not choose. A config that exists but will not parse still falls back to
# defaults — that is a degraded session, not an unasked question.
if [ ! -r "$CONF" ]; then
  printf '%s\n' "${C_TEAL}▸${R} ${DIM}New Slang${R} ${B}/new-slang setup${R} ${DIM}— pick your language${R} ${C_TEAL}[SETUP]${R}"
  exit 0
fi

LANG_ID=$(get '.language' gen-z)
LEVEL=$(get '.level' beginner)
ROTATE=$(get '.rotate' 6)
case "$ROTATE" in (*[!0-9]*|"") ROTATE=6 ;; esac
[ "$ROTATE" -ge 2 ] || ROTATE=2

# a language must be listed in the manifest — a delisted deck on disk stays dark
[ -r "$MANIFEST" ] || exit 0
mrow=$(awk -F'\t' -v l="$LANG_ID" '$1==l{print; exit}' "$MANIFEST")
[ -n "$mrow" ] || exit 0
tag=$(printf '%s' "$mrow" | cut -f2)
SAFE_REGS=$(printf '%s' "$mrow" | cut -f4)
DECK="$LANGS/$LANG_ID/deck.tsv"
[ -r "$DECK" ] || exit 0

case "$LEVEL" in
  pro)          MAXTIER=3 ;;
  intermediate) MAXTIER=2 ;;
  *)            MAXTIER=1 ;;
esac

# Pool: tier-gated, ambient-safe registers only, then deterministically shuffled
# with a daily seed — stable across redraws (no reshuffle on every repaint),
# varied across the deck (no same-category runs), fresh order each day.
day=$(( $(date +%s) / 86400 ))
pool=$(awk -F'\t' -v mt="$MAXTIER" -v regs=",$SAFE_REGS," -v seed="$day" '
  function h(s,  i,x){ x=seed+5381; for(i=1;i<=length(s);i++) x=(x*33+index(KEYS,substr(s,i,1)))%999983; return x }
  BEGIN{ KEYS="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 " }
  NF==6 && $1+0<=mt && index(regs, ","$5",")>0 { printf "%09d\t%s\n", h($2), $0 }
' "$DECK" | sort -t"$(printf '\t')" -k1,1n | cut -f2-)

if [ "${NEWSLANG_DEBUG:-}" = "pool" ]; then printf '%s\n' "$pool"; exit 0; fi

n=$(printf '%s\n' "$pool" | grep -c . || true)
[ "${n:-0}" -gt 0 ] || exit 0

idx=$(( ( $(date +%s) / ROTATE ) % n + 1 ))
IFS=$'\t' read -r tier term meaning example reg note < <(printf '%s\n' "$pool" | sed -n "${idx}p")
[ -n "${term:-}" ] || exit 0

case "$reg" in
  SAFE|CORE)     c="$C_GREEN" ;;
  CASUAL)        c="$C_TEAL"  ;;
  REGIONAL)      c="$C_GOLD"  ;;
  PRECISE)       c="$C_TEAL"  ;;
  TRAP)          c="$C_AMBER" ;;
  ELEVATED)      c="$C_SLATE" ;;
  *)             c="$C_GREY"  ;;
esac

case "$LEVEL" in
  pro)          body="${DIM}recall:${R} ${B}${term}${R}" ;;
  intermediate) body="${B}${term}${R} ${DIM}—${R} ${meaning}" ;;
  *)            body="${B}${term}${R} ${DIM}—${R} ${meaning}"
                [ -n "${example:-}" ] && body="$body ${DIM}${example}${R}" ;;
esac

# width guard on plain text (ANSI codes don't count against the terminal)
cols=${COLUMNS:-$(tput cols 2>/dev/null || echo 100)}
plain="$tag $term — $meaning $example [$reg]"
if [ "${#plain}" -gt $(( cols - 4 )) ] && [ "$LEVEL" = "beginner" ]; then
  body="${B}${term}${R} ${DIM}—${R} ${meaning}"
fi

printf '%s\n' "${c}▸${R} ${DIM}${tag}${R} ${body} ${c}[${reg}]${R}"
