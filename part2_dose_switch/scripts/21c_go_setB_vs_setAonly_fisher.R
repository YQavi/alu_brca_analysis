library(org.Hs.eg.db)
library(AnnotationDbi)
library(dplyr)

RESULTS_DIR <- "~/alu_brca/part2_dose_switch/results/macs_real"

setA_genes <- readLines(file.path(RESULTS_DIR, "SetA_all_genes_2kb.txt"))
setB_genes <- readLines(file.path(RESULTS_DIR, "SetB_v3_all_genes_2kb.txt"))
setA_only <- setdiff(setA_genes, setB_genes)

cat("Set B (PROseq-confirmed):", length(setB_genes), "\n")
cat("Set A-only (not confirmed):", length(setA_only), "\n")
stopifnot(length(intersect(setB_genes, setA_only)) == 0)  # must be truly disjoint

# Annotate BOTH groups against genome-wide GO-BP (each gene needs its own
# real annotation, regardless of which group it's in)
all_genes <- union(setB_genes, setA_only)
gene2go <- AnnotationDbi::select(org.Hs.eg.db, keys = all_genes, keytype = "SYMBOL",
                                  columns = c("GO", "ONTOLOGY")) %>%
  filter(ONTOLOGY == "BP", !is.na(GO)) %>% distinct(SYMBOL, GO)
term_names <- AnnotationDbi::select(GO.db::GO.db, keys = unique(gene2go$GO),
                                     keytype = "GOID", columns = "TERM")

# Direct 2-group Fisher's exact per term - same structure as H8/H10
all_terms <- unique(gene2go$GO)
results <- data.frame()
for (term in all_terms) {
  term_genes <- gene2go %>% filter(GO == term) %>% pull(SYMBOL)
  b_hit <- length(intersect(setB_genes, term_genes))
  a_hit <- length(intersect(setA_only, term_genes))
  if (b_hit + a_hit < 5) next  # skip ultra-rare terms, same discipline as H8
  tbl <- matrix(c(b_hit, length(setB_genes) - b_hit,
                   a_hit, length(setA_only) - a_hit), nrow = 2)
  ft <- fisher.test(tbl)
  results <- rbind(results, data.frame(
    GO = term, setB_hit = b_hit, setB_total = length(setB_genes),
    setAonly_hit = a_hit, setAonly_total = length(setA_only),
    odds_ratio = ft$estimate, pval = ft$p.value
  ))
}
results$fdr <- p.adjust(results$pval, method = "BH")
results <- results %>% left_join(term_names, by = c("GO" = "GOID")) %>% arrange(fdr)

cat("\nTerms tested:", nrow(results), " | Significant at FDR<0.05:", sum(results$fdr < 0.05), "\n")
if (sum(results$fdr < 0.05) > 0) {
  print(results %>% filter(fdr < 0.05) %>%
          select(TERM, setB_hit, setAonly_hit, odds_ratio, fdr) %>% head(20))
} else {
  cat("No terms significant - consistent with the Alu-overlap null already found 3 ways.\n")
}
write.csv(results, file.path(RESULTS_DIR, "go_setB_vs_setAonly_fisher.csv"), row.names = FALSE)
