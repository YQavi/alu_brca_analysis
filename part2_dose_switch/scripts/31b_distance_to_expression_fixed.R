library(dplyr)
library(tximport)
library(DESeq2)

RESULTS_DIR <- "~/alu_brca/part2_dose_switch/results"
MACS_DIR <- file.path(RESULTS_DIR, "macs_real")

quant_dir <- file.path(RESULTS_DIR, "salmon_quant")
tx2gene <- read.delim(file.path(RESULTS_DIR, "tx2gene_noversion.tsv"), header = FALSE)
samples <- data.frame(srx_srr = list.dirs(quant_dir, recursive = FALSE, full.names = FALSE)) %>%
  mutate(dose = case_when(
    grepl("SRX29017826|SRX29017827|SRX29017834", srx_srr) ~ "Veh",
    grepl("SRX29017839|SRX29017840|SRX29017841", srx_srr) ~ "10pM",
    grepl("SRX29017842|SRX29017843|SRX29017844", srx_srr) ~ "100pM",
    grepl("SRX29017829|SRX29017830|SRX29017831", srx_srr) ~ "10nM",
    TRUE ~ NA_character_
  )) %>% filter(!is.na(dose))
samples$dose <- factor(samples$dose, levels = c("Veh","10pM","100pM","10nM"))
rownames(samples) <- samples$srx_srr
files <- file.path(quant_dir, samples$srx_srr, "quant.sf")
names(files) <- samples$srx_srr
txi <- tximport(files, type = "salmon", tx2gene = tx2gene, ignoreTxVersion = TRUE)
dds <- DESeqDataSetFromTximport(txi, colData = samples, design = ~ dose)
dds <- dds[rowSums(counts(dds)) >= 10, ]
dds <- DESeq(dds)
res_10nM <- as.data.frame(results(dds, contrast = c("dose", "10nM", "Veh"))) %>%
  tibble::rownames_to_column("ensembl_id")

gtf_genes <- system("awk -F'\t' '$3==\"gene\"' ~/data/files/gencode.v49.annotation.gtf", intern = TRUE)
gene_map <- data.frame(line = gtf_genes) %>%
  mutate(ensembl_id = sub('.*gene_id "([^"]*)".*', '\\1', line),
         ensembl_id = sub('\\.[0-9]+$', '', ensembl_id),
         symbol = sub('.*gene_name "([^"]*)".*', '\\1', line)) %>%
  select(ensembl_id, symbol)
res_10nM <- res_10nM %>% left_join(gene_map, by = "ensembl_id") %>% filter(!is.na(symbol))

# FIX: dedupe res_10nM by symbol - keep the most significant (lowest padj)
# entry per gene symbol, a defensible, standard convention
res_10nM_dedup <- res_10nM %>% filter(!is.na(padj)) %>%
  group_by(symbol) %>% slice_min(padj, n = 1, with_ties = FALSE) %>% ungroup()
cat("res_10nM: ", nrow(res_10nM), " rows ->", nrow(res_10nM_dedup), "after deduping by symbol\n")

enh_dist <- read.csv(file.path(MACS_DIR, "nearest_alu_setA_setBv3_combined.csv")) %>%
  filter(dose == "10nM", set == "SetA_ER_H3K27ac") %>%
  mutate(start = as.integer(start), end = as.integer(end)) %>%
  distinct(chrom, start, end, .keep_all = TRUE)  # FIX: dedupe tied nearest-Alu rows

sorted <- tempfile()
system(sprintf("sort -k1,1 -k2,2n %s/SetA_ER_H3K27ac_10nM.bed > %s", MACS_DIR, sorted))
gene_link <- system(sprintf("bedtools closest -a %s -b ~/data/files/gencode_genes_sorted.bed -d", sorted), intern = TRUE)
gl_df <- do.call(rbind, strsplit(gene_link, "\t"))
gl_df <- data.frame(chrom = gl_df[,1], start = as.integer(gl_df[,2]), end = as.integer(gl_df[,3]),
                     symbol = gl_df[, ncol(gl_df) - 1], gene_dist = as.integer(gl_df[, ncol(gl_df)])) %>%
  filter(gene_dist <= 2000) %>%
  distinct(chrom, start, end, .keep_all = TRUE)  # FIX: dedupe tied nearest-gene rows
cat("Genes within 2kb, deduped:", nrow(gl_df), "\n")

merged <- enh_dist %>%
  inner_join(gl_df, by = c("chrom", "start", "end")) %>%
  inner_join(res_10nM_dedup, by = "symbol")

cat("Final, deduplicated genes with both distance and DESeq2 result:", nrow(merged), "\n")
cat("Any remaining duplicate peaks?", sum(duplicated(merged %>% select(chrom,start,end))), "\n")

cat("\n--- Does distance to nearest Alu correlate with dose-response magnitude? ---\n")
ct <- cor.test(merged$distance, abs(merged$log2FoldChange), method = "spearman", exact = FALSE)
cat(sprintf("Spearman rho=%.3f, p=%.4f\n", ct$estimate, ct$p.value))

cat("\n--- Do significant dose-responders (FDR<0.05) sit at different Alu distances? ---\n")
merged$sig <- merged$padj < 0.05
if (sum(merged$sig) >= 3 && sum(!merged$sig) >= 3) {
  wt <- wilcox.test(distance ~ sig, data = merged)
  cat(sprintf("Significant (n=%d) median=%.0f  Non-significant (n=%d) median=%.0f  p=%.4f\n",
              sum(merged$sig), median(merged$distance[merged$sig]),
              sum(!merged$sig), median(merged$distance[!merged$sig]), wt$p.value))
}
write.csv(merged, file.path(MACS_DIR, "h20_distance_vs_expression_dedup.csv"), row.names = FALSE)
