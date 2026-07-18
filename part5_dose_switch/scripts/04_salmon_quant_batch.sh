#!/bin/bash
set -euo pipefail

MAP=~/alu_brca/part5_dose_switch/data/raw/rnaseq/rnaseq_srx_srr_map.tsv
FASTQ_DIR=~/alu_brca/part5_dose_switch/data/raw/rnaseq/fastq
QUANT_DIR=~/alu_brca/part5_dose_switch/results/salmon_quant
INDEX=~/data/files/salmon_index/gencode_v49_index

mkdir -p "$FASTQ_DIR" "$QUANT_DIR"
cd "$FASTQ_DIR"

while IFS=$'\t' read -r srx srr; do
  echo "=== Processing $srx ($srr) ==="

  prefetch "$srr" -O ./
  fasterq-dump "$srr" -O ./ -e 4

  salmon quant -i "$INDEX" -l A \
    -r "${srr}.fastq" \
    -p 4 --validateMappings \
    -o "${QUANT_DIR}/${srx}_${srr}"

  rm -f "${srr}.fastq" "${srr}"
  rm -rf "$srr"

  echo "=== Done $srx ==="
done < "$MAP"

echo "All 21 samples quantified."
