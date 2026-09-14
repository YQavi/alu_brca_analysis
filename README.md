# Alu Regulatory Elements in Breast Cancer

Computational extension of Costallat et al. (2022) Alu-CIA regulatory framework to ER+ breast cancer, using TCGA BRCA data and ENCODE MCF-7 ChIP-seq as the original scope. **Part 2, as actually executed, diverged substantially from its original description below — see the flag under Part 2.**

## Prior work this builds on

Cell-line analysis (MCF-7, ENCODE data) is in a separate repository. Key outputs used here:
- CIA atlas: `mcf7_active_cias.bed` (68,529 CIAs)
- ERE-Alu ESR1 sites: `esr1_alu_overlap.bed` (OR=1.78, p=1.16e-10)
- CIA signature genes: `cia_signature_genes_coding.txt` (724 genes)

---

## Parts

### Part 1 — CIA gene expression across PAM50 subtypes
Tests whether CIA-proximal genes are specifically elevated in Luminal A/B (ER+) vs. Basal-like (ER-) breast cancer in TCGA patient tumors. Validates MCF-7 cell-line findings at population scale.

### Part 2 — as originally scoped vs. as actually executed

**Originally scoped:** FOXA1 copy-number amplification and CIA gene signature scores, connecting a clinically observed somatic event to the Alu-ERE regulatory mechanism, tested for association with survival in ER+ tumors.

**⚠️ As actually executed (`part2_dose_switch/`), this became a different, unrelated investigation.** Real content: dose-resolved ERα/FOXA1/GATA3 ChIP-seq, ATAC-seq, and PRO-seq (Kim et al. 2026 dataset, MCF-7, four estradiol doses + vehicle) — testing whether Alu subfamily age controls transcription factor access at the sequence level, not FOXA1 copy-number amplification in TCGA tumors. **This needs a decision, not a silent merge**: either the original FOXA1-amplification/TCGA-survival analysis for Part 2 was never carried out and should still be planned separately, or the project was deliberately redirected and this section's original description should be retired/renumbered. Flagging rather than assuming.

A note within the executed work: an early test (H3) checked whether the real, Costallat-derived CIA gene signature (`cia_signature_genes_coding.txt`) overlapped with dose-responsive genes identified in the new investigation — **null result**. A separate, unrelated hypothesis (STAT1/interferon-response, from Han et al.) was also tested and ruled out around the same point — these are two distinct negative results, not the same test.

### Part 3 — Alu-ERE methylation loss in tumor vs. normal
Tests whether Alu elements at ESR1-bound ERE sites are specifically hypomethylated in ER+ breast tumors, using TCGA 450k methylation data. Provides a mechanistic link between Alu demethylation and CIA activation. **Status: not covered by any work in this conversation — confirm separately whether this has been run.**

### Part 4 — ESR1 mutation and Alu-ERE binding site loss
Tests whether ESR1 somatic mutations (an endocrine-resistance mechanism) alter binding at Alu-ERE sites specifically, versus conventional ERE sites. **Status: not covered by any work in this conversation — confirm separately whether this has been run.**

---

## What "part2_dose_switch" actually contains (real, extensively validated)

Given the scale of this divergence, the actual content is documented here rather than folded into Part 2's original description above.

**Core, confirmed results:**
1. ERα is depleted at young Alu, at every individual dose (10pM excluded, n=1/tier).
2. FOXA1 shows nearly the same exclusion pattern, placing it upstream of ERα's own preference.
3. Individual-copy resolution (full-lineage, current/final version): middle lineage p=0.0095, young lineage p=0.047, old lineage null (p=0.48 — an earlier subfamily-specific version suggested an effect here; superseded).
4. Intact ERE sequence directly predicts real, measured ERα binding at AluJr4 (OR=5.68, p=0.00015).
5. PRO-seq signal near confirmed ERα peaks shows a real ~5x dose-response at 1nM vs. vehicle; far Alu only ~2x.

**Motif enrichment, full-lineage odds ratios (real vs. shuffled background):**

| Motif | AluY | AluS | AluJ |
|---|---|---|---|
| FOXA1 | 0.03 | 0.06 | 0.17 |
| GATA3 | 0.06 | 0.18 | 0.57 |
| ERE (ERα's own) | 0.14 | 2.77 | 2.87 |

FOXA1/GATA3 are depleted below chance at every age tier, including old — never true enrichment, only reduced suppression with age. Only ERE crosses into genuine enrichment, at middle/old tiers.

**Retracted/superseded:** the AGG→AGC single-base-pair claim (did not survive verification); the original combined "14–29x" ERE enrichment framing (AluSc's 28.9x was inflated, real value 2.7x at strict threshold; AluJr4's 14.4x strengthened to 37.1x); old-tier individual-copy "suggestive" framing (superseded by full-lineage null).

**Honest nulls:** Set A/B transcriptional confirmation, GO enrichment, TCGA survival — all null. One real positive unconnected to the Alu mechanism: 8 DESeq2-validated dose-responsive genes.

Full rationale for every decision and correction: `part2_dose_switch/docs/analysis_decisions.md`.

---

## Repository structure

```
alu_brca/
├── README.md
├── docs/
│   └── analysis_decisions.md          rationale for every key choice (original 4-part scope)
├── part1_cia_expression/
│   ├── data/
│   ├── scripts/
│   ├── notebooks/
│   ├── results/
│   └── figures/
├── part2_dose_switch/                 diverged from original Part 2 scope - see flag above
│   ├── data/raw/
│   ├── results/macs_real/
│   ├── results/figures/
│   ├── results/pints_peaks/
│   ├── scripts/
│   ├── igv/
│   └── docs/analysis_decisions.md     decision log specific to the executed dose_switch work
├── part3_[methylation]/               status unconfirmed
└── part4_[esr1_mutation]/             status unconfirmed
```

## Data sources
- TCGA BRCA PanCancer Atlas: cBioPortal (open access)
- ENCODE MCF-7 ChIP-seq: encodeproject.org (open access)
- GSE298767/298769/298770/298771 (Kim et al. 2026) — used by `part2_dose_switch` specifically
- Reference genome: GRCh38 / hg38

## Citation
Results based on data from the TCGA Research Network: https://www.cancer.gov/tcga
