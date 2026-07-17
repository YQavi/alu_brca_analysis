#!/bin/bash
set -euo pipefail
cd ~/alu_brca/part5_dose_switch

# Get JASPAR motifs for STAT1, STAT2, IRF1 (matching Kim's use of JASPAR,
# not Han's HOCOMOCO - note this in your writeup as a methods difference)
for motif in MA0137.3 MA0517.1 MA0050.2; do  # STAT1, STAT2, IRF1 JASPAR IDs - verify current IDs
  wget -q "https://jaspar.genereg.net/api/v1/matrix/${motif}/?format=meme" -O data/raw/${motif}.meme
done
cat data/raw/MA*.meme > data/processed/stat_irf_motifs.meme

for peakset in pM_responsive nM_responsive; do
  bedtools slop -i data/processed/${peakset}_peaks.bed -g hg38.chrom.sizes -b 200 \
    > data/processed/${peakset}_200bp.bed
  bedtools getfasta -fi hg38.fa -bed data/processed/${peakset}_200bp.bed \
    > data/processed/${peakset}_200bp.fasta
  fimo --thresh 0.005 --oc results/fimo_${peakset} \
    data/processed/stat_irf_motifs.meme data/processed/${peakset}_200bp.fasta
done
