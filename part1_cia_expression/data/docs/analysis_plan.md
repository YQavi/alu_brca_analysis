# Part 1: CIA Gene Expression Across PAM50 Subtypes
# Analysis Plan — written BEFORE data download

## Hypothesis
CIA-proximal genes will be more highly expressed in Luminal A/B tumors than Basal-like because ESR1-driven enhancer activation at Alu-ERE sites is specific to ER+ lineage identity. If confirmed in patient tumors, this generalises the MCF-7 cell-line finding to primary tissue and suggests CIA activation is a feature of ER+ breast cancer identity rather than a cell-line artefact.

## Primary question
A positive result will be a significant difference in CIA-proximal genes expression between breast cancer subtypes. 

## Secondary questions
This analysis will also test the gene expression difference in normal breast tissues as well to establish a baseline.

## Input data
mcf7_active_cias.bed - /home/yq139/results/aluome_figures/results/mcf7/mcf7_active_cias.bed
Breast Invasive Carcinoma (TCGA, PanCancer Atlas) mRNA RSEM expression via cBioPortal
gencode.v49.annotation.gtf - /home/yq139/data/files/gencode.v49.annotation.gtf

## Gene signature definition
CIA signature score defined as mean z-score across CIA genes per sample. Z-scoring normalises for differences in absolute expression level between genes. Mean z-score chosen over PCA first component for interpretability and direct comparability with survival outcome.

## Statistical tests
Kruskal-Wallis chosen for subtype comparison because CIA score distribution is not assumed normal. BH FDR correction for per-gene heatmap to control false discovery rate across multiple genes. Log-rank test for survival.

## Survival analysis plan
Median split chosen for CIA score within each PAM50 subtype separately, to avoid confounding survival result with known subtype prognostic differences. Primary survival test in Luminal A as the subtype with highest prior probability of CIA-driven transcription.

## Controls
Three parallel control gene lists: (1) normal-tissue CIA genes to test generalisability, (2) expression-matched random genes to test specificity, (3) ESR1-target non-CIA genes to test whether CIA membership adds information beyond ESR1 binding. TCGA matched normals used as tissue-normal baseline — no external cell line needed.

## Confounders to address
1. Tumor purity — TCGA bulk RNA-seq samples contain a mix of tumor cells and normal stromal/immune cells. A Luminal A tumor that is 30% tumor cells will look different from one that is 90% tumor cells. TCGA BRCA clinical files include ESTIMATE purity scores. You'll add tumor purity as a covariate in a linear model when testing CIA score vs subtype, to ensure the subtype difference isn't driven by purity differences between subtypes.
2. Immune infiltration — Your CIA gene list includes immune genes (B2M, CD44, IFIT2, IL6 from the GO enrichment). Basal-like tumors are more immune-infiltrated than Luminal tumors. If those immune CIA genes drive any expression difference you see, it could be immune cells rather than tumor-intrinsic CIA activation. Handle this by running the analysis twice: once with the full gene list, once with immune genes removed (flag any gene in the "Immune response" GO set).
3. Sample size imbalance — TCGA BRCA is heavily enriched for Luminal A (the most common subtype). If Luminal A has 500 samples and HER2-enriched has 70, statistical tests have very different power across subtypes. Report the N per subtype clearly, and for the primary statistical test use a method that doesn't assume equal group sizes (Kruskal-Wallis handles this correctly).

## Expected outputs
Heatmap: CIA-proximal gene expression across PAM50 subtypes
Boxplot: CIA gene signature score (mean z-score) per subtype
Kaplan-Meier survival curve stratified by CIA gene signature score
TSV: per-sample CIA signature score for downstream use in Avenue 1

## What a negative result looks like
 If there isn't an observable differences in gene expression between subtype and/or conpared to normal
