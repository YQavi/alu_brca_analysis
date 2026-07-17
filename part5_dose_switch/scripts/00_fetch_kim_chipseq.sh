#!/bin/bash
set -euo pipefail
cd ~/alu_brca/part5_dose_switch/data/raw

# Check what's actually on the series page before downloading blind -
# supplementary files (peaks/bigwigs) save you from reprocessing FASTQ.
esearch -db gds -query "GSE298767" | efetch -format docsum > gse298767_docsum.xml
echo "Inspect gse298767_docsum.xml for supplementary file types before proceeding."
echo "If MACS peak beds are deposited as supplementary files, prefer those over FASTQ."
