#!/usr/bin/env bash
# Regenerate languages/gen-z/deck.tsv from the gen-z glossary.
# Run whenever skills/new-slang/references/gen-z/glossary.md changes.
set -euo pipefail
SRC="${1:?usage: build-genz-deck.sh <glossary.md> <out.tsv>}"
OUT="${2:?}"
awk -F'|' '
  /^\| *\*\*/ {
    t=$2; m=$3; e=$4; f=$5
    gsub(/\*\*/,"",t); gsub(/^ +| +$/,"",t)
    gsub(/^ +| +$/,"",m)
    gsub(/^ +| +$/,"",e); if (e=="—" || e=="-") e=""
    gsub(/`/,"",f); gsub(/^ +| +$/,"",f)
    caveat=""
    if (match(f, /^\[[^]]+\]/)) {
      flag=substr(f, RSTART+1, RLENGTH-2)
      caveat=substr(f, RSTART+RLENGTH); gsub(/^ +| +$/,"",caveat)
    } else flag=f
    if (flag !~ /^(SAFE|CASUAL|RISKY|DECODE ONLY|DEAD)$/) next
    if (t=="" || m=="") next
    tier = (flag=="SAFE") ? 1 : (flag=="CASUAL") ? 2 : 3
    printf "%d\t%s\t%s\t%s\t%s\t%s\n", tier, t, m, e, flag, caveat
  }
' "$SRC" > "$OUT"
echo "gen-z deck: $(wc -l < "$OUT" | tr -d ' ') cards"
