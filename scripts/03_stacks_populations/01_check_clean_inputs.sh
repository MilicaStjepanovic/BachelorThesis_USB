#!/bin/bash

set -euo pipefail

BASE=~/reducta_clean
BAMDIR=$BASE/03_bams_clean
META=$BASE/04_metadata
POPMAP=$META/popmap_reducta_camilla_clean.txt

echo "Checking clean Reducta + Camilla input set"
echo

echo "Total BAMs:"
find "$BAMDIR" -name "*.bam" | wc -l

echo "Reducta BAMs:"
find "$BAMDIR" -name "*_Red_red.bam" | wc -l

echo "Camilla BAMs:"
find "$BAMDIR" -name "*.bam" \
  | xargs -n1 basename \
  | sort \
  | grep -E "DS2-3|DS7-1|DS7-5|DS7-10|AB84|AB85|cam" || true

echo
echo "Popmap lines:"
wc -l "$POPMAP"

echo
echo "Malformed popmap lines:"
awk 'NF != 2 {print NR, $0}' "$POPMAP"

find "$BAMDIR" -name "*.bam" \
  | xargs -n1 basename \
  | sed 's/\.bam$//' \
  | sort > "$META/bam_names_clean.txt"

awk '{print $1}' "$POPMAP" \
  | sort > "$META/popmap_names_clean.txt"

echo
echo "In popmap but not BAMs:"
comm -23 "$META/popmap_names_clean.txt" "$META/bam_names_clean.txt"

echo
echo "In BAMs but not popmap:"
comm -13 "$META/popmap_names_clean.txt" "$META/bam_names_clean.txt"

find "$BAMDIR" -name "*.bam" | sed 's/$/.bai/' > "$META/expected_bai_files.txt"

while read bai
do
  if [ ! -f "$bai" ]; then
    echo "$bai"
  fi
done < "$META/expected_bai_files.txt" > "$META/missing_bai_files.txt"

echo
echo "Missing BAI files:"
cat "$META/missing_bai_files.txt"

echo
echo "Check complete."
