#!/bin/bash
awk -F'\t' '$3=="transcript"' ~/data/files/gencode.v49.annotation.gtf \
  | sed -n 's/.*transcript_id "\([^"]*\)".*gene_id "\([^"]*\)".*/\1\t\2/p' \
  > tx2gene.tsv
wc -l tx2gene.tsv
