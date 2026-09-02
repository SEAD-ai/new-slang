#!/usr/bin/env bash
# New Slang — the in-answer channel, made global.
#
# A SessionStart hook handler. When the user has chosen scope:global, this prints
# the in-answer instructions as additionalContext so immersion is live in every
# session without loading the skill by hand. When scope is session (the default)
# it prints nothing and costs nothing — the skill carries the channel instead.
#
# Contract:
#   stdout  a SessionStart hook JSON object, or nothing at all
#   exit    always 0 — a language lesson must never break a session start
# Debug:    NEWSLANG_DEBUG=context prints the raw context block and exits.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF="${NEWSLANG_CONFIG:-$HOME/.claude/newslang-config.json}"
LANGS="$HERE/languages"
MANIFEST="$LANGS/_manifest.tsv"
CAP=24   # terms per session — bounded, because this block costs tokens

cat >/dev/null 2>&1 || true   # drain the hook payload; we key off config, not it

command -v jq >/dev/null 2>&1 || exit 0
[ -r "$CONF" ] || exit 0
[ -r "$MANIFEST" ] || exit 0

# Both gates must be explicit: jq's // treats false as empty, so a plain
# default would read "inAnswer: false" as unset and switch immersion on.
gate=$(jq -r 'if (.channels.inAnswer == true) and (.scope == "global")
              then "on" else "off" end' "$CONF" 2>/dev/null || echo off)
[ "$gate" = "on" ] || exit 0

get() { local v=""; v=$(jq -r "$1 // empty" "$CONF" 2>/dev/null); printf '%s' "${v:-$2}"; }
LANG_ID=$(get '.language' gen-z)
LEVEL=$(get '.level' beginner)
DENSITY=$(get '.density' seasoned)

# A language must be listed in the manifest — a delisted deck on disk stays dark,
# exactly as it does in the status line.
mrow=$(awk -F'\t' -v l="$LANG_ID" '$1==l{print; exit}' "$MANIFEST")
[ -n "$mrow" ] || exit 0
TAG=$(printf '%s' "$mrow" | cut -f2)
SAFE_REGS=$(printf '%s' "$mrow" | cut -f4)
DECK="$LANGS/$LANG_ID/deck.tsv"
[ -r "$DECK" ] || exit 0

case "$LEVEL" in
  pro)          MAXTIER=3 ;;
  intermediate) MAXTIER=2 ;;
  *)            MAXTIER=1 ;;
esac

case "$DENSITY" in
  saturated) RATE="every sentence carries something" ;;
  fluent)    RATE="approximately one term per one or two sentences" ;;
  *)         RATE="approximately one term per three or four sentences" ;;
esac

# Same daily-seeded shuffle as the status line: a different slice of the deck
# each day, stable within the day, so sessions vary without churning mid-work.
day=$(( $(date +%s) / 86400 ))
VOCAB=$(awk -F'\t' -v mt="$MAXTIER" -v regs=",$SAFE_REGS," -v seed="$day" '
  function h(s,  i,x){ x=seed+5381; for(i=1;i<=length(s);i++) x=(x*33+index(KEYS,substr(s,i,1)))%999983; return x }
  BEGIN{ KEYS="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 " }
  NF==6 && $1+0<=mt && index(regs, ","$5",")>0 { printf "%09d\t- %s — %s\n", h($2), $2, $3 }
' "$DECK" | sort -t"$(printf '\t')" -k1,1n | cut -f2- | head -n "$CAP")
[ -n "$VOCAB" ] || exit 0

case "$LANG_ID" in
  gen-z)  NUANCE="Register flags matter more than volume: never produce a term the deck marks RISKY, DECODE ONLY, DEAD, or VULGAR. State AAVE and ballroom/drag origins where they apply, once, plainly, without lecturing." ;;
  es|it)  NUANCE="Prefer set phrases and connectives over isolated nouns. Mark regional terms with their region every time — \"vale (Spain)\", \"daje (Rome)\". When the user writes in the target language, correct gender and conjugation gently, once, inside the gloss block." ;;
  ja)     NUANCE="Politeness is the lesson, not a detail: name the level a term belongs to (keigo, polite, or casual) whenever it is not obvious, and never model a casual form aimed upward. Write romaji beside the Japanese the first time a term appears in a session, and keep set phrases whole — おつかれさま is one unit, not three words." ;;
  en-adv) NUANCE="Do not sprinkle — deploy. Use the precise word only where it is genuinely the best word. When the user misuses a TRAP word (comprise, fulsome, enervate), note the trap once in the gloss: never inline, never smug." ;;
  *)      NUANCE="Introduce terms where context makes the meaning guessable." ;;
esac

CTX=$(cat <<EOF
# New Slang — in-answer immersion is ON for this session

The user is learning ${TAG} at level ${LEVEL}, density ${DENSITY}. They enabled this
globally (\`scope: global\`), so it is live in every session — they did not invoke it here
and may not be thinking about it. Teach in the margin; never make the lesson cost the answer.

## How to weave

The scaffolding of every sentence stays plain English; ${TAG} rides in the predicate.
Density ${DENSITY} means ${RATE}. ${NUANCE}

Gloss every term new to this session in a footnote block at the very end of the reply — one
line each, meaning first. Never gloss inline, never gloss the same term twice:

\`\`\`
─────
**term** — what it means. Short usage note if it earns one.
\`\`\`

## Vocabulary in play

Level ${LEVEL} unlocks the terms below. Do not introduce ${TAG} vocabulary from above this
level, and do not invent terms to fill the quota — a plain sentence beats a fabricated one.

${VOCAB}

## Where the language stops cold

Plain professional English, no exceptions, for: code, identifiers, and comments · anything
sent to a third party · security warnings and irreversible actions · exact errors, numbers,
file paths, and commands. If a phrase creates any ambiguity about what is happening, drop it
and say it plainly. Technical accuracy is never traded for register.

Never claim a term is currently trending — a knowledge cutoff makes that a claim you cannot
check.

## Turning it off

"dial it back", "switch to Spanish", "go pro" and similar are config changes: route them
through \`/new-slang\`, which writes \`~/.claude/newslang-config.json\`. \`/new-slang off\`
quiets immersion for the current conversation only; \`/new-slang off all\` turns the channel
off everywhere, including this hook.
EOF
)

if [ "${NEWSLANG_DEBUG:-}" = "context" ]; then printf '%s\n' "$CTX"; exit 0; fi

jq -n --arg c "$CTX" \
  '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$c}}' 2>/dev/null || exit 0
exit 0
