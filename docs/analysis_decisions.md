# Analysis Decision Log

## Part 1 — CIA Gene Expression Across PAM50 Subtypes

[2026-06] [Gene set construction]
Decision: High-confidence CIA signature = CIA-proximal genes (mcf7_active_cias.bed)
          within 50kb of ESR1 ChIP-seq peak (MCF7 ENCODE ENCSR463GOT)
Rationale: Proximity to ESR1 peak focuses set on genes most likely regulated
           through the Alu-ERE mechanism confirmed by OR=1.78 (p=1.16e-10).
Alternative rejected: All 2570 CIA genes — alphabetically ordered, no
                      functional prioritisation, includes housekeeping genes.

[2026-06] [Gene annotation version]
Observation: 3/809 CIA genes overlap published ER+ literature gene lists.
Root cause: CIA list uses Gencode v49; literature uses older annotations.
Decision: Filter to 724 protein-coding-like genes for TCGA matching.
          85 lncRNA/novel transcripts set aside for secondary analysis.
Note: FAM-prefix genes may be incorrectly excluded — review post-download.

[2026-06] [Statistical approach]
Subtype differences: Kruskal-Wallis + pairwise Wilcoxon, Bonferroni correction
Per-gene heatmap: Kruskal-Wallis per gene, BH FDR < 0.05
Survival: log-rank test, median split within each PAM50 subtype separately
Signature score: mean z-score per sample (interpretable) + GSVA (robust)

[2026-06] [Confounders]
1. Tumor purity — ESTIMATE score as covariate in linear model
2. Immune infiltration — run with/without immune CIA genes separately
3. Sample size imbalance — report N per subtype, use non-parametric tests

[2026-06] [Controls]
1. Normal-tissue CIA genes (fig2F_study_genes.txt)
2. Expression-matched random genes (same N, matched median expression)
3. ESR1-target non-CIA genes (ESR1 peaks not overlapping CIAs)
