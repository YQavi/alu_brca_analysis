## Q1: What biological mechanism would cause CIA-proximal genes to be more highly expressed in Luminal A/B (ER+) tumors than in Basal-like (ER-) tumors? What would that mean about the relationship between Alu elements and estrogen signalling at a population level?

CIA = CAGE inter-Alu -> TSS + Alu

Genes near a CIA would be more expressed in ER+ tumors compared to ER- tumors due to differences in epigenetic marks blurring the boundary (H3K4me3?). Mutations in FOXA1 or GATA3 change the chromatin conformation into an always open, accessible state. At a population level, differences in Alu elements can change the predisposition to ER+ cancer.

**CIA-proximal genes will be more highly expressed in Luminal A/B tumors than Basal-like because ESR1-driven enhancer activation at Alu-ERE sites is specific to ER+ lineage identity. If confirmed in patient tumors, this generalises the MCF-7 cell-line finding to primary tissue and suggests CIA activation is a feature of ER+ breast cancer identity rather than a cell-line artefact.**


## Q2: What would it mean if CIA-proximal gene expression is elevated in Basal-like tumors instead? Would that falsify the MCF-7 findings or be explainable another way?

If CIA-proximal gene expression is instead elevated in ER- tumors, that could imply a universality to Alu elements being importance in tumorigenesis (the regulatory machinery can be hijacked to either silence the ER or constitutively activate some other aspect). This would not falsify the MCF-7 findings, alu-eRNA could be utilized multiple ways.

**So CIA gene expression being elevated in Basal tumors could simply reflect immune cell contamination in bulk RNA-seq rather than tumor-intrinsic CIA activation.**


## Q3: The gene list you have (mcf7_GO_study_genes.txt) came from MCF-7 active CIAs — a cancer cell line. What is the risk of using this list to test an enrichment in TCGA patient data, and how might you control for it?

Homogenous cell line data would be dangerous to represent the population due to variations between people. There's also tumor stage to consider(?). Controls in place would be using normal cells along with another subtype to amplify the Alu differences.

**The control you should use: run the same analysis with two additional gene lists — (1) a random set of 2,587 genes matched for expression level and chromosome distribution, and (2) the normal-tissue CIA gene list from fig2F_study_genes.txt. If your MCF-7 CIA gene list shows stronger subtype specificity than both controls, the result is meaningful.**

## Q4: If CIA gene expression predicts survival, is that evidence that CIAs are causing the outcome, or could there be another explanation? What would you need to rule out confounding?

No, more explorations would be needed to solidify the findings. A KO experiment would help show the importance of CIA gene expression. Multiple replicates should be tested to reduce effects of a condounding variable (pulling different sets of experimental MCF-7 data).

**High CIA gene expression in Luminal A tumors could predict good survival simply because Luminal A is the best-prognosis subtype, not because CIAs specifically matter. To address this computationally you need to test CIA gene signature survival prediction within each subtype separately, particularly within Luminal A alone, rather than across all subtypes pooled.**
