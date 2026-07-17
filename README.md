# Alu Regulatory Elements in Breast Cancer

Computational extension of Costallat et al. (2022) Alu-CIA regulatory
framework to ER+ breast cancer using TCGA BRCA data and ENCODE MCF-7
ChIP-seq. Four analytical parts, each building on the last.

## Parts

### Part 1 — CIA gene expression across PAM50 subtypes
Tests whether CIA-proximal genes are specifically elevated in Luminal A/B
(ER+) vs Basal-like (ER-) breast cancer in TCGA patient tumors.
Validates MCF-7 cell-line findings at population scale.

### Part 2 — FOXA1 amplification and CIA gene expression  
Tests whether FOXA1 copy number gain predicts higher CIA gene signature
scores and worse survival in ER+ tumors. Connects a clinically observed
somatic event to the Alu-ERE regulatory mechanism.

### Part 3 — Alu-ERE methylation loss in tumor vs normal
Tests whether Alu elements at ESR1-bound ERE sites are specifically
hypomethylated in ER+ breast tumors using TCGA 450k methylation data.
Provides mechanistic link between Alu demethylation and CIA activation.

### Part 4 — ESR1 mutation and Alu-ERE binding site loss
Tests whether ESR1 somatic mutations (endocrine resistance mechanism)
alter binding at Alu-ERE sites specifically vs conventional ERE sites.

## Repository structure
alu_brca/

├── README.md

├── docs/

│   └── analysis_decisions.md    # Rationale for every key choice

├── part1_cia_expression/

│   ├── data/                    # Gene lists and processed data

│   ├── scripts/                 # Analysis scripts

│   ├── notebooks/               # Documented curation notebooks

│   ├── results/                 # Output TSVs

│   └── figures/                 # Output figures

├── part2_foxa1_amplification/

├── part3_alu_methylation/

└── part4_esr1_mutations/

## Prior work this builds on
Cell-line analysis (MCF-7, ENCODE data) is in a separate repository.
Key outputs used here:
- CIA atlas: `mcf7_active_cias.bed` (68,529 CIAs)
- ERE-Alu ESR1 sites: `esr1_alu_overlap.bed` (OR=1.78, p=1.16e-10)
- CIA signature genes: `cia_signature_genes_coding.txt` (724 genes)

## Data sources
- TCGA BRCA PanCancer Atlas: cBioPortal (open access)
- ENCODE MCF-7 ChIP-seq: encodeproject.org (open access)
- Reference genome: GRCh38 / hg38

## Citation
Results based on data from the TCGA Research Network:
https://www.cancer.gov/tcga