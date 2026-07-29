#!/bin/bash
set -euo pipefail
cd ~/alu_brca/part2_dose_switch/data/raw
mkdir -p ../processed/bdg_peaks

for dose in 10pM 100pM 1nM 10nM; do
  bigWigToBedGraph GSE298767_ER_${dose}.bw ../processed/ER_${dose}.bedGraph
  bigWigToBedGraph GSE298767_IN_${dose}.bw ../processed/IN_${dose}.bedGraph

  macs3 bdgcmp -t ../processed/ER_${dose}.bedGraph -c ../processed/IN_${dose}.bedGraph \
    -m FE -p 1 -o ../processed/ER_${dose}_FE.bdg

  macs3 bdgpeakcall -i ../processed/ER_${dose}_FE.bdg -c 2 -l 200 -g 30 \
    -o ../processed/bdg_peaks/ER_${dose}_peaks.narrowPeak
done

# Merge into pM* and nM* groups matching Kim et al.'s own combined designation
cat ../processed/bdg_peaks/ER_10pM_peaks.narrowPeak ../processed/bdg_peaks/ER_100pM_peaks.narrowPeak \
  | sort -k1,1 -k2,2n | bedtools merge -i - > ../processed/pM_responsive_peaks_approx.bed
cat ../processed/bdg_peaks/ER_1nM_peaks.narrowPeak ../processed/bdg_peaks/ER_10nM_peaks.narrowPeak \
  | sort -k1,1 -k2,2n | bedtools merge -i - > ../processed/nM_responsive_peaks_approx.bed

echo "pM* peaks (approx): $(wc -l < ../processed/pM_responsive_peaks_approx.bed)"
echo "nM* peaks (approx): $(wc -l < ../processed/nM_responsive_peaks_approx.bed)"
