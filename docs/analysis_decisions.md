# Analysis Decision Log

| Date | Avenue | Decision | Rationale |
| --- | --- | --- | --- |
| 06/27/2026 | CIA Signature Gene Set | Pare down mcf7_GO_study_genes.txt (2,587 genes) to a smaller, high-confidence gene set to reduce noise | No overlaps between known ESR1 targets and the CIA gene list. A mix of  CIA genes that are also near ESR1 ChIP-seq peaks and CIA genes expressed in breast tissue used to construct the list. This uses known connections with breast tissue and focuses spatially near ESR1 sites.<br><br>Housekeeping genes are excluded by referencing Eisenberg & Levanon 2013. ER+ genes are defined from PAM50 gene list, OncotypeDX genes, ESR1-target compendium (Ross-Innes et al. 2012, Parker et al. 2009, Perou et al. 2000) |