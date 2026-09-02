#!/usr/bin/env bash
# New Slang — ambient vocabulary card for the Claude Code status line.
#
# Hot path: no network, no model calls, pure file reads. Claude Code cancels an
# in-flight status line script when a new update triggers, so speed is a feature.
#
# Contract:
#   line 1  ordinary status (dir · model · context) — the card is additive
#   line 2  the card, only when config enables ambient and the pool is non-empty
# Debug:    NEWSLANG_DEBUG=pool   prints the filtered card pool and exits.
#           NEWSLANG_DEBUG=render renders every card in the pool and exits.
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

# Display width, not character count: CJK glyphs occupy two columns but one
# character, so a Japanese card overflows while ${#plain} still looks short. In
# UTF-8 a wide glyph is a 3-byte sequence and a narrow accented one is 2 bytes,
# so (bytes - chars) / 2 counts the wide ones and rounds the accents away.
# Assigning to LC_ALL re-runs setlocale, which is what flips ${#t} to bytes;
# the result goes in a global so the hot path needs no subshell.
DW=0
dw() {
  local t=$1 c b old=${LC_ALL-__unset__}
  # Not every 3-byte glyph is wide: the em dash and ellipsis are 3 bytes and one
  # column, and counting them as two costs a card its example a column early.
  # Fold them to ASCII first. (⚠️ and friends live only in note fields, which
  # never render.) Literal characters, not \u escapes — bash 3.2 has no \u.
  t=${t//—/-}
  t=${t//…/.}
  c=${#t}
  LC_ALL=C; b=${#t}
  if [ "$old" = "__unset__" ]; then unset LC_ALL; else LC_ALL=$old; fi
  DW=$(( c + (b - c) / 2 ))
}
cols=${COLUMNS:-$(tput cols 2>/dev/null || echo 100)}
budget=$(( cols - 4 ))
fits() { dw "$1"; [ "$DW" -le "$budget" ]; }

render_card() { # render_card <one tab-separated pool line>
  local tier term meaning example reg note c body pbody short
  IFS=$'\t' read -r tier term meaning example reg note <<< "$1"
  [ -n "${term:-}" ] || return 0

  case "$reg" in
    SAFE|CORE)     c="$C_GREEN" ;;
    CASUAL)        c="$C_TEAL"  ;;
    REGIONAL)      c="$C_GOLD"  ;;
    PRECISE)       c="$C_TEAL"  ;;
    TRAP)          c="$C_AMBER" ;;
    FORMAL)        c="$C_SLATE" ;;
    ELEVATED)      c="$C_SLATE" ;;
    *)             c="$C_GREY"  ;;
  esac

  # Richest form that fits wins, and each level has a floor it degrades to. One
  # fallback is not enough for Japanese: a long keigo phrase plus its romaji can
  # outrun a narrow terminal even after the example is dropped. Track the plain
  # text of each candidate alongside the coloured one so the fit test measures
  # what the terminal actually shows.
  case "$LEVEL" in
    pro)
      body="${DIM}recall:${R} ${B}${term}${R}"; pbody="recall: $term"
      # A recall prompt has nothing to drop but the term itself — except the
      # parenthetical gloss some decks carry (ja terms ship their romaji). On a
      # narrow pane that goes first, and at pro it is the crutch anyway.
      if ! fits "$tag $pbody [$reg]"; then
        short=${term% (*)}
        if [ "$short" != "$term" ]; then
          body="${DIM}recall:${R} ${B}${short}${R}"; pbody="recall: $short"
        fi
      fi
      ;;
    intermediate)
      if fits "$tag $term — $meaning [$reg]"; then
        body="${B}${term}${R} ${DIM}—${R} ${meaning}"; pbody="$term — $meaning"
      else
        body="${B}${term}${R}"; pbody="$term"
      fi
      ;;
    *)
      if [ -n "${example:-}" ] && fits "$tag $term — $meaning $example [$reg]"; then
        body="${B}${term}${R} ${DIM}—${R} ${meaning} ${DIM}${example}${R}"
        pbody="$term — $meaning $example"
      elif fits "$tag $term — $meaning [$reg]"; then
        body="${B}${term}${R} ${DIM}—${R} ${meaning}"; pbody="$term — $meaning"
      else
        body="${B}${term}${R}"; pbody="$term"
      fi
      ;;
  esac

  # Last resort: drop the language tag. On a narrow pane a long keigo phrase
  # plus its romaji can overrun 60 columns with nothing else left to cut, and
  # the tag is the one part the user already knows — they chose the language.
  if fits "$tag $pbody [$reg]"; then
    printf '%s\n' "${c}▸${R} ${DIM}${tag}${R} ${body} ${c}[${reg}]${R}"
  else
    printf '%s\n' "${c}▸${R} ${body} ${c}[${reg}]${R}"
  fi
}

# Render every card in the pool at once — the eval suite sweeps the whole
# rotation for overflow, and one process per card is far too slow.
if [ "${NEWSLANG_DEBUG:-}" = "render" ]; then
  while IFS= read -r line; do [ -n "$line" ] && render_card "$line"; done <<< "$pool"
  exit 0
fi

idx=$(( ( $(date +%s) / ROTATE ) % n + 1 ))
render_card "$(printf '%s\n' "$pool" | sed -n "${idx}p")"
