#!/usr/bin/env python3

import sys

if len(sys.argv) != 3:
    sys.exit("Usage: python3 04_vcf_to_fasta.py input.vcf output.fasta")

vcf = sys.argv[1]
out = sys.argv[2]

samples = []
seqs = {}

with open(vcf) as f:
    for line in f:
        if line.startswith("##"):
            continue

        if line.startswith("#CHROM"):
            parts = line.rstrip("\n").split("\t")
            samples = parts[9:]
            seqs = {s: [] for s in samples}
            continue

        parts = line.rstrip("\n").split("\t")
        ref = parts[3]
        alts = parts[4].split(",")

        # Keep only biallelic SNPs
        if len(ref) != 1 or len(alts) != 1 or len(alts[0]) != 1:
            continue

        alt = alts[0]

        for sample, gt_field in zip(samples, parts[9:]):
            gt = gt_field.split(":")[0]

            if gt in ("0/0", "0|0"):
                base = ref
            elif gt in ("1/1", "1|1"):
                base = alt
            elif gt in ("0/1", "1/0", "0|1", "1|0"):
                base = "N"
            else:
                base = "N"

            seqs[sample].append(base)

with open(out, "w") as g:
    for sample in samples:
        g.write(f">{sample}\n")
        sequence = "".join(seqs[sample])
        for i in range(0, len(sequence), 80):
            g.write(sequence[i:i+80] + "\n")
