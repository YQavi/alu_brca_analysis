library(org.Hs.eg.db)
library(AnnotationDbi)
library(dplyr)

RESULTS_DIR <- "~/alu_brca/part2_dose_switch/results/macs_real"

setA_genes <- readLines(file.path(RESULTS_DIR, "SetA_all_genes_2kb.txt"))
setB_genes <- readLines(file.path(RESULTS_DIR, "SetB_v3_all_genes_2kb.txt"))

cat("Set A genes:", length(setA_genes), " | Set B genes:", length(setB_genes),
    " | Set B subset of Set A:", length(setdiff(setB_genes, setA_genes)) == 0, "\n")

setA_only <- setdiff(setA_genes, setB_genes)  # the real comparison group
cat("Set A-only (not PROseq-confirmed):", length(setA_only), "genes\n")

# REAL fix: genome-wide background, not a self-referential union
genome_background <- keys(org.Hs.eg.db, keytype = "SYMBOL")
cat("Genome-wide background:", length(genome_background), "genes\n")

gene2go <- AnnotationDbi::select(org.Hs.eg.db, keys = genome_background, keytype = "SYMBOL",
                                  columns = c("GO", "ONTOLOGY")) %>%
  filter(ONTOLOGY == "BP", !is.na(GO)) %>%
  distinct(SYMBOL, GO)

term_names <- AnnotationDbi::select(GO.db::GO.db, keys = unique(gene2go$GO),
                                     keytype = "GOID", columns = "TERM")

hypergeom_go <- function(genes, gene2go, background_size, label, min_term_size = 5) {
  genes <- intersect(genes, unique(gene2go$SYMBOL))
  term_counts <- gene2go %>% filter(SYMBOL %in% genes) %>% count(GO, name = "hit_in_set")
  term_totals <- gene2go %>% count(GO, name = "total_in_background")
  merged <- term_counts %>% inner_join(term_totals, by = "GO") %>%
    filter(total_in_background >= min_term_size)
  merged$pval <- mapply(function(hit, total_term, n_genes, N) {
    phyper(hit - 1, total_term, N - total_term, n_genes, lower.tail = FALSE)
  }, merged$hit_in_set, merged$total_in_background, length(genes), background_size)
  merged$fdr <- p.adjust(merged$pval, method = "BH")
  merged <- merged %>% left_join(term_names, by = c("GO" = "GOID")) %>% arrange(fdr)
  cat("\n---", label, ":", nrow(merged), "terms tested,",
      sum(merged$fdr < 0.05), "significant at FDR<0.05 ---\n")
  if (sum(merged$fdr < 0.05) > 0) {
    print(merged %>% filter(fdr < 0.05) %>% select(TERM, hit_in_set, total_in_background, fdr) %>% head(15))
  }
  merged
}

cat("\n================ Reference: each set vs genome-wide background ================\n")
res_A_genome <- hypergeom_go(setA_genes, gene2go, length(genome_background), "Set A vs genome")
res_B_genome <- hypergeom_go(setB_genes, gene2go, length(genome_background), "Set B v3 vs genome")

cat("\n================ THE REAL COMPARISON: PROseq-confirmed vs not, within Set A ================\n")
res_direct <- hypergeom_go(setB_genes, gene2go %>% filter(SYMBOL %in% setA_genes),
                            length(setA_genes), "Set B v3 vs (Set A-only, i.e. within-SetA comparison)")

write.csv(res_A_genome, file.path(RESULTS_DIR, "go_setA_vs_genome.csv"), row.names = FALSE)
write.csv(res_B_genome, file.path(RESULTS_DIR, "go_setB_vs_genome.csv"), row.names = FALSE)
write.csv(res_direct, file.path(RESULTS_DIR, "go_setB_vs_setA_direct.csv"), row.names = FALSE)
