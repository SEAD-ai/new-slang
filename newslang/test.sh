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
"$HERE/init.sh" it beginner true false >/dev/null 2>&1 && jq -e '.language=="it"' "$HERE/config.json" >/dev/null && ok "init writes valid config" || bad "init broken"
"$HERE/init.sh" klingon pro >/dev/null 2>&1 && bad "init accepted unknown language" || ok "init rejects unknown language"
"$HERE/init.sh" es wizard >/dev/null 2>&1 && bad "init accepted bad level" || ok "init rejects bad level"

echo
printf '%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" = 0 ]
