# Alu Regulatory Elements in Breast Cancer — TCGA Extension

## Project overview
Extension of Costallat et al. (2022) Alu-CIA regulatory framework
to ER+ breast cancer using TCGA BRCA data.

## Avenues
- Part 1: CIA gene expression across PAM50 subtypes
- Part 2: FOXA1 amplification and CIA gene expression
- Part 3: Alu-ERE methylation loss in tumor vs normal
- Part 4: ESR1 mutation and Alu-ERE binding site loss

## Data sources
- TCGA BRCA: cBioPortal (https://www.cbioportal.org)
- Reference Alu atlas: ~/results/aluome_figures/
- ENCODE MCF-7 ChIP-seq: ~/data/mcf7/

## Key input files (from prior analysis)
- CIA atlas: ~/results/aluome_figures/results/cia/all_cias.bed
- MCF-7 active CIAs: ~/results/aluome_figures/results/mcf7/mcf7_active_cias.bed
- ERE-Alu ESR1 sites: ~/results/aluome_figures/results/mcf7/esr1_alu_overlap.bed
- CIA gene list: ~/results/aluome_figures/results/mcf7/mcf7_GO_study_genes.txt

## Analysis log
See analysis_decisions.md for rationale behind key choices.