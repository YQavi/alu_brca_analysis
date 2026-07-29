library(DESeq2)
library(dplyr)

txi <- readRDS("~/alu_brca/part2_dose_switch/results/h3_txi.rds")
samples <- readRDS("~/alu_brca/part2_dose_switch/results/h3_samples.rds")

samples$dose <- factor(samples$dose, levels = c("Veh","1pM","10pM","100pM","1nM","10nM","100nM"))
rownames(samples) <- samples$srx_srr

dds <- DESeqDataSetFromTximport(txi, colData = samples, design = ~ dose)
dds <- dds[rowSums(counts(dds)) >= 10, ]  # filter near-zero-count genes before testing
dds <- DESeq(dds)

# Table S2's exact rule: log2FC > 0.6 (up) or < -0.6 (down), p < 0.05, vs vehicle
doses <- c("1pM","10pM","100pM","1nM","10nM","100nM")
sig_genes <- list()

for (d in doses) {
  res <- results(dds, contrast = c("dose", d, "Veh"))
  res_df <- as.data.frame(res) %>%
    tibble::rownames_to_column("gene_id") %>%
    filter(!is.na(pvalue), pvalue < 0.05, abs(log2FoldChange) > 0.6)
  sig_genes[[d]] <- res_df$gene_id
  cat(d, ": ", nrow(res_df), " significant genes\n", sep="")
}

# Table S2 "first significant dose" logic:
# pM responsive = first significant at 1pM, 10pM, or 100pM
# nM responsive = first significant at 1nM, 10nM, or 100nM (and NOT already pM responsive)
pM_order <- c("1pM","10pM","100pM")
nM_order <- c("1nM","10nM","100nM")

pM_responsive <- unique(unlist(sig_genes[pM_order]))
nM_responsive_raw <- unique(unlist(sig_genes[nM_order]))
nM_responsive <- setdiff(nM_responsive_raw, pM_responsive)  # "first" significant, per Table S2

cat("\npM-responsive genes (first sig. in pM range):", length(pM_responsive), "\n")
cat("nM-responsive genes (first sig. in nM range, not already pM):", length(nM_responsive), "\n")

writeLines(pM_responsive, "~/alu_brca/part2_dose_switch/results/pM_responsive_genes.txt")
writeLines(nM_responsive, "~/alu_brca/part2_dose_switch/results/nM_responsive_genes.txt")
saveRDS(dds, "~/alu_brca/part2_dose_switch/results/h3_dds.rds")
