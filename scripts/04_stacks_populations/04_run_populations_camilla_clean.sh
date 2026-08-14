#!/bin/bash

set -euo pipefail

module load stacks

BASE=~/reducta_clean
GSTACKS=$BASE/05_gstacks
POPMAP=$BASE/04_metadata/popmap_reducta_camilla_clean.txt
OUT=$BASE/06_populations
LOGDIR=$BASE/09_logs

mkdir -p "$OUT" "$LOGDIR"

echo "Running populations"
echo "GSTACKS: $GSTACKS"
echo "POPMAP: $POPMAP"
echo "OUT: $OUT"
date

populations \
  -P "$GSTACKS" \
  -M "$POPMAP" \
  --vcf \
  --plink \
  -O "$OUT" \
  -t 8 \
  > "$LOGDIR/populations_camilla_clean.stdout.log" \
  2> "$LOGDIR/populations_camilla_clean.stderr.log"

echo "populations finished"
date
