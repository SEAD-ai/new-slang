#!/usr/bin/env bash
# New Slang eval suite. Run after any deck or script change. Exit 0 = green.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SL="$HERE/statusline.sh"
J='{"workspace":{"current_dir":"/Users/swmask/x"},"model":{"display_name":"M"},"context_window":{"remaining_percentage":50}}'
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0
ok()  { pass=$((pass+1)); printf '  ok   %s\n' "$1"; }
bad() { fail=$((fail+1)); printf '  FAIL %s\n' "$1"; }
cfg() { jq -n --arg l "$1" --arg v "$2" --argjson a "${3:-true}" '{language:$l,level:$v,channels:{ambient:$a},rotate:6}' > "$TMP/c.json"; }
run() { echo "$J" | NEWSLANG_CONFIG="$TMP/c.json" COLUMNS=130 "$SL"; }
pool(){ echo "$J" | NEWSLANG_CONFIG="$TMP/c.json" NEWSLANG_DEBUG=pool "$SL" | tail -n +2; }

echo "— deck lint —"
for f in "$HERE"/languages/*/deck.tsv; do
  lang=$(basename "$(dirname "$f")")
  awk -F'\t' -v L="$lang" '
    NF!=6           { printf "    %s line %d: %d fields (want 6)\n", L, NR, NF; e=1 }
    $1!~/^[123]$/   { printf "    %s line %d: bad tier %s\n", L, NR, $1; e=1 }
    $2=="" || $3==""{ printf "    %s line %d: empty term/meaning\n", L, NR; e=1 }
    $5!~/^(SAFE|CASUAL|RISKY|DECODE ONLY|DEAD|CORE|REGIONAL|FORMAL|VULGAR|PRECISE|TRAP|ELEVATED)$/ {
                      printf "    %s line %d: unknown register %s\n", L, NR, $5; e=1 }
    END{ exit e }' "$f" && ok "lint $lang" || bad "lint $lang"
done
awk -F'\t' 'NF!=4{e=1} END{exit e}' "$HERE/languages/_manifest.tsv" && ok "lint manifest" || bad "lint manifest"

echo "— matrix: every listed language × level renders a card —"
while IFS=$'\t' read -r id _ _ _; do
  for v in beginner intermediate pro; do
    cfg "$id" "$v"
    [ "$(run | wc -l | tr -d ' ')" = 2 ] && ok "$id/$v renders" || bad "$id/$v renders"
  done
done < "$HERE/languages/_manifest.tsv"

echo "— level gating: pool tiers never exceed the level —"
for spec in "beginner 1" "intermediate 2" "pro 3"; do
  set -- $spec; cfg es "$1"
  max=$(pool | cut -f1 | sort -rn | head -1)
  [ "${max:-0}" -le "$2" ] && ok "es/$1 caps at tier $2" || bad "es/$1 leaked tier $max"
done

echo "— safety: no risky register ever reaches ambient —"
allbad=0
while IFS=$'\t' read -r id _ _ _; do
  cfg "$id" pro
  leaks=$(pool | cut -f5 | grep -cE '^(RISKY|DECODE ONLY|DEAD|VULGAR)$' || true)
  [ "${leaks:-0}" = 0 ] || { allbad=1; printf '    %s leaked %s risky cards\n' "$id" "$leaks"; }
done < "$HERE/languages/_manifest.tsv"
[ "$allbad" = 0 ] && ok "no RISKY/DECODE ONLY/DEAD/VULGAR in any pool" || bad "risky register leaked"

echo "— config handling —"
cfg es beginner false
[ "$(run | wc -l | tr -d ' ')" = 1 ] && ok "ambient:false renders status only" || bad "ambient:false still rendered"
cfg fr beginner   # dormant: on disk but not in manifest
[ "$(run | wc -l | tr -d ' ')" = 1 ] && ok "delisted language stays dark" || bad "delisted language rendered"
cfg klingon pro
[ "$(run | wc -l | tr -d ' ')" = 1 ] && ok "unknown language degrades" || bad "unknown language rendered"
echo 'not json {{{' > "$TMP/c.json"
out=$(run); rc=$?
[ "$rc" = 0 ] && [ "$(printf '%s\n' "$out" | wc -l | tr -d ' ')" = 2 ] && ok "malformed config falls back to defaults" || bad "malformed config: rc=$rc"
rm -f "$TMP/c.json"
out=$(run); [ "$(printf '%s\n' "$out" | wc -l | tr -d ' ')" = 2 ] && ok "missing config falls back to defaults" || bad "missing config"

echo "— degradation without jq —"
mkdir -p "$TMP/bin"
for t in bash awk sed grep sort cut date wc tput mktemp dirname basename printf cat tr head tail; do
  p=$(command -v $t 2>/dev/null) && ln -sf "$p" "$TMP/bin/$t"; done
cfg_out=$(echo "$J" | PATH="$TMP/bin" NEWSLANG_CONFIG="$TMP/nope.json" COLUMNS=130 bash "$SL")
[ "$(printf '%s\n' "$cfg_out" | wc -l | tr -d ' ')" = 2 ] && ok "no jq: card still renders (defaults)" || bad "no jq broke rendering"

echo "— determinism & speed —"
cfg it intermediate
a=$(run | tail -1); b=$(run | tail -1)
[ "$a" = "$b" ] && ok "same second, same card (no flicker)" || bad "card flickered between redraws"
s=$(date +%s%N); for i in $(seq 10); do run >/dev/null; done; e=$(date +%s%N)
ms=$(( (e-s)/10/1000000 ))
[ "$ms" -lt 120 ] && ok "render avg ${ms}ms (<120ms)" || bad "render too slow: ${ms}ms"

echo "— init.sh —"
NEWSLANG_CONFIG="$TMP/init.json" "$HERE/init.sh" it beginner true false >/dev/null 2>&1 && jq -e '.language=="it"' "$TMP/init.json" >/dev/null && ok "init writes valid config" || bad "init broken"
"$HERE/init.sh" klingon pro >/dev/null 2>&1 && bad "init accepted unknown language" || ok "init rejects unknown language"
"$HERE/init.sh" es wizard >/dev/null 2>&1 && bad "init accepted bad level" || ok "init rejects bad level"
NEWSLANG_CONFIG="$TMP/init.json" "$HERE/init.sh" es pro true true fluent global >/dev/null 2>&1 && jq -e '.scope=="global"' "$TMP/init.json" >/dev/null && ok "init writes scope" || bad "init dropped scope"
NEWSLANG_CONFIG="$TMP/init.json" "$HERE/init.sh" es pro true false >/dev/null 2>&1 && jq -e '.scope=="session"' "$TMP/init.json" >/dev/null && ok "init defaults scope to session" || bad "init scope default wrong"
"$HERE/init.sh" es pro true true fluent everywhere >/dev/null 2>&1 && bad "init accepted bad scope" || ok "init rejects bad scope"
"$HERE/init.sh" es pro true true loud global >/dev/null 2>&1 && bad "init accepted bad density" || ok "init rejects bad density"

echo "— first run: never pick a language for the user —"
rm -f "$TMP/c.json"
first=$(run | tail -1)
case "$first" in *setup*) ok "no config nudges to setup";; *) bad "no config picked a deck silently";; esac
case "$first" in *"Gen Z"*) bad "no config still defaulted to gen-z";; *) ok "no config names no language";; esac

echo "— in-answer hook: gates —"
IA="$HERE/inanswer.sh"
ia() { NEWSLANG_CONFIG="$TMP/c.json" bash "$IA" </dev/null; }
iacfg() { jq -n --arg l "$1" --arg v "$2" --argjson i "$3" --arg s "$4" \
  '{language:$l,level:$v,channels:{ambient:true,inAnswer:$i},density:"fluent",scope:$s,rotate:6}' > "$TMP/c.json"; }
[ -x "$IA" ] && ok "inanswer.sh is executable" || bad "inanswer.sh not executable"
rm -f "$TMP/c.json"
[ -z "$(ia)" ] && ok "no config: hook silent" || bad "hook fired without config"
iacfg it intermediate true session
[ -z "$(ia)" ] && ok "scope:session: hook silent" || bad "hook fired at session scope"
iacfg it intermediate false global
[ -z "$(ia)" ] && ok "inAnswer:false: hook silent" || bad "hook fired with channel off"
iacfg klingon pro true global
[ -z "$(ia)" ] && ok "unknown language: hook silent" || bad "hook fired on unknown language"
iacfg fr pro true global
[ -z "$(ia)" ] && ok "delisted language: hook silent" || bad "hook fired on delisted language"

echo "— in-answer hook: payload —"
iacfg it intermediate true global
ia | jq -e '.hookSpecificOutput.hookEventName=="SessionStart"' >/dev/null && ok "emits SessionStart hook JSON" || bad "bad hook JSON"
ia | jq -e '.hookSpecificOutput.additionalContext|length>200' >/dev/null && ok "context block is non-trivial" || bad "context block too thin"
ctx() { NEWSLANG_CONFIG="$TMP/c.json" NEWSLANG_DEBUG=context bash "$IA" </dev/null; }
has() { case "$2" in *"$1"*) return 0;; *) return 1;; esac; }
C=$(ctx)
has 'Italian' "$C"          && ok "context names the language"     || bad "context missing language"
has 'stops cold' "$C"       && ok "context carries the boundaries" || bad "context dropped boundaries"
has 'Gloss every term' "$C" && ok "context carries the gloss rule" || bad "context dropped gloss rule"
[ "${#C}" -lt 6000 ] && ok "context stays under ~1.5k tokens" || bad "context block too expensive"

echo "— in-answer hook: level gating and register safety —"
for spec in "beginner 1" "intermediate 2" "pro 3"; do
  set -- $spec; iacfg es "$1" true global
  # every listed term must exist in the deck at or below the level's tier
  leak=0
  while IFS= read -r t; do
    [ -n "$t" ] || continue
    awk -F'\t' -v term="$t" -v mt="$2" 'NF==6 && $2==term && $1+0<=mt {f=1} END{exit !f}' "$HERE/languages/es/deck.tsv" || leak=1
  done <<< "$(ctx | sed -n '/^## Vocabulary in play$/,/^## Where/p' | awk 'sub(/^- /,""){i=index($0," — "); if(i) print substr($0,1,i-1)}')"
  [ "$leak" = 0 ] && ok "es/$1 hook vocab caps at tier $2" || bad "es/$1 hook leaked a term above tier $2"
done
allbad=0
while IFS=$'\t' read -r id _ _ _; do
  iacfg "$id" pro true global
  while IFS= read -r t; do
    [ -n "$t" ] || continue
    awk -F'\t' -v term="$t" 'NF==6 && $2==term && $5 ~ /^(RISKY|DECODE ONLY|DEAD|VULGAR)$/ {exit 1}' "$HERE/languages/$id/deck.tsv" || { allbad=1; printf '    %s leaked %s\n' "$id" "$t"; }
  done <<< "$(ctx | sed -n '/^## Vocabulary in play$/,/^## Where/p' | awk 'sub(/^- /,""){i=index($0," — "); if(i) print substr($0,1,i-1)}')"
done < "$HERE/languages/_manifest.tsv"
[ "$allbad" = 0 ] && ok "no risky register reaches in-answer context" || bad "risky register leaked to in-answer"

echo "— hook wiring —"
HJ="$HERE/../hooks/hooks.json"
jq -e '.hooks.SessionStart[0].hooks[0].command | test("inanswer.sh")' "$HJ" >/dev/null 2>&1 && ok "hooks.json points at inanswer.sh" || bad "hooks.json miswired"
jq -e '.hooks.SessionStart[0].hooks[0].command | test("CLAUDE_PLUGIN_ROOT")' "$HJ" >/dev/null 2>&1 && ok "hooks.json uses CLAUDE_PLUGIN_ROOT" || bad "hooks.json has a hardcoded path"

echo "— commands can actually onboard —"
for c in "$HERE/../commands/new-slang.md" "$HERE/../commands/slang.md"; do
  n=$(basename "$c")
  grep -q 'AskUserQuestion' "$c" && ok "$n allows AskUserQuestion" || bad "$n cannot ask the questions"
  grep -qE '^allowed-tools:.*\bBash\b' "$c" && ok "$n allows Bash (init.sh)" || bad "$n cannot write config"
done

echo
printf '%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" = 0 ]
