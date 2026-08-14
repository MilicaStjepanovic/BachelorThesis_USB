#!/bin/bash

set -euo pipefail

module load stacks

BASE=~/reducta_clean
BAMDIR=$BASE/03_bams_clean
POPMAP=$BASE/04_metadata/popmap_reducta_camilla_clean.txt
OUT=$BASE/05_gstacks
LOGDIR=$BASE/09_logs

mkdir -p "$OUT" "$LOGDIR"

echo "Running gstacks"
echo "BAMDIR: $BAMDIR"
echo "POPMAP: $POPMAP"
echo "OUT: $OUT"
date

gstacks \
  -I "$BAMDIR" \
  -M "$POPMAP" \
  -O "$OUT" \
  -t 8 \
  > "$LOGDIR/gstacks_camilla_clean.stdout.log" \
  2> "$LOGDIR/gstacks_camilla_clean.stderr.log"

echo "gstacks finished"
date
