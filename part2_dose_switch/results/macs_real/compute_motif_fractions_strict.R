library(dplyr)

read_fimo_qval <- function(path, n_total, qcut = 0.05) {
  df <- read.delim(file.path(path, "fimo.tsv"), comment.char = "#")
  df <- df[!is.na(df$motif_id), ]
  df <- df[df$q.value < qcut, ]
  df %>% distinct(sequence_name, motif_id) %>% count(motif_id, name = "n_seqs_with_hit") %>%
    mutate(total_seqs = n_total, fraction = n_seqs_with_hit / n_total)
}

pM <- read_fimo_qval("fimo_results/pM_star_v2", 2706) %>% mutate(group = "pM_star")
nM <- read_fimo_qval("fimo_results/nM_star_v2", 18893) %>% mutate(group = "nM_star")
combined <- bind_rows(pM, nM)
print(combined)

cat("\n--- Fisher's exact test per motif (q<0.05) ---\n")
for (m in unique(combined$motif_id)) {
  pm_n <- combined %>% filter(motif_id == m, group == "pM_star") %>% pull(n_seqs_with_hit)
  nm_n <- combined %>% filter(motif_id == m, group == "nM_star") %>% pull(n_seqs_with_hit)
  if (length(pm_n) == 0) pm_n <- 0
  if (length(nm_n) == 0) nm_n <- 0
  tbl <- matrix(c(pm_n, 2706 - pm_n, nm_n, 18893 - nm_n), nrow = 2)
  ft <- fisher.test(tbl)
  cat(sprintf("%s: pM=%d/2706 (%.2f%%) nM=%d/18893 (%.2f%%) OR=%.2f p=%.2e\n",
              m, pm_n, 100*pm_n/2706, nm_n, 100*nm_n/18893, ft$estimate, ft$p.value))
}
