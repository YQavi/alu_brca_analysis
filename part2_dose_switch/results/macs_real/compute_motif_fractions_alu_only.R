library(dplyr)

read_fimo_fixed <- function(path, n_total, pcut = 0.0001) {
  df <- read.delim(file.path(path, "fimo.tsv"), comment.char = "#")
  df <- df[!is.na(df$motif_id), ]
  df <- df[df$p.value < pcut, ]
  df %>% distinct(sequence_name, motif_id) %>% count(motif_id, name = "n_seqs_with_hit") %>%
    mutate(total_seqs = n_total, fraction = n_seqs_with_hit / n_total)
}

n_pM <- as.integer(system("grep -c '^>' pM_star_alu_only_200bp.fasta", intern=TRUE))
n_nM <- as.integer(system("grep -c '^>' nM_star_alu_only_200bp.fasta", intern=TRUE))

pM <- read_fimo_fixed("fimo_results/pM_alu_only", n_pM) %>% mutate(group = "pM_star_alu")
nM <- read_fimo_fixed("fimo_results/nM_alu_only", n_nM) %>% mutate(group = "nM_star_alu")
combined <- bind_rows(pM, nM)
print(combined)

cat("\n--- Fisher's exact test per motif, Alu-restricted (fixed p<0.0001) ---\n")
for (m in c("MA0050.2","MA0137.3","MA0517.1","MA1623.1")) {
  pm_n <- combined %>% filter(motif_id == m, group == "pM_star_alu") %>% pull(n_seqs_with_hit)
  nm_n <- combined %>% filter(motif_id == m, group == "nM_star_alu") %>% pull(n_seqs_with_hit)
  if (length(pm_n) == 0) pm_n <- 0
  if (length(nm_n) == 0) nm_n <- 0
  tbl <- matrix(c(pm_n, n_pM - pm_n, nm_n, n_nM - nm_n), nrow = 2)
  ft <- fisher.test(tbl)
  cat(sprintf("%s: pM=%d/%d (%.2f%%) nM=%d/%d (%.2f%%) OR=%.2f p=%.2e\n",
              m, pm_n, n_pM, 100*pm_n/n_pM, nm_n, n_nM, 100*nm_n/n_nM, ft$estimate, ft$p.value))
}
