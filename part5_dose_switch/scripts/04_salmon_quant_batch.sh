#!/bin/bash
set -uo pipefail   # dropped -e: one sample's failure shouldn't kill the whole batch

MAP=~/alu_brca/part5_dose_switch/data/raw/rnaseq/rnaseq_srx_srr_map.tsv
FASTQ_DIR=~/alu_brca/part5_dose_switch/data/raw/rnaseq/fastq
QUANT_DIR=~/alu_brca/part5_dose_switch/results/salmon_quant
INDEX=~/data/files/salmon_index/gencode_v49_index

mkdir -p "$FASTQ_DIR" "$QUANT_DIR"
cd "$FASTQ_DIR"

while IFS=$'\t' read -r srx srr; do
  OUT="${QUANT_DIR}/${srx}_${srr}"

  if [ -f "${OUT}/quant.sf" ]; then
    echo "=== Skipping $srx ($srr) - already quantified ==="
    continue
  fi

  echo "=== Processing $srx ($srr) ==="

  prefetch "$srr" -O ./
  fasterq-dump "$srr" -O ./ -e 4

  salmon quant -i "$INDEX" -l A \
    -r "${srr}.fastq" \
    -p 4 --validateMappings \
    -o "$OUT"

  rm -f "${srr}.fastq"
  rm -rf "${srr}"

  if [ -f "${OUT}/quant.sf" ]; then
    echo "=== Done $srx - success ==="
  else
    echo "=== WARNING: $srx did not produce quant.sf - check manually ==="
  fi
done < "$MAP"

echo "Batch complete."
