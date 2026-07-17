library(dplyr)

read_fimo <- function(path) {
  read.delim(file.path(path, "fimo.tsv"), comment.char = "#") %>%
    distinct(sequence_name, motif_id)
}

pm_hits <- read_fimo("results/fimo_pM_responsive")
nm_hits <- read_fimo("results/fimo_nM_responsive")

n_pm_peaks <- length(readLines("data/processed/pM_responsive_200bp.bed"))
n_nm_peaks <- length(readLines("data/processed/nM_responsive_200bp.bed"))

frac_table <- bind_rows(
  pm_hits %>% count(motif_id) %>% mutate(group = "pM", total = n_pm_peaks),
  nm_hits %>% count(motif_id) %>% mutate(group = "nM", total = n_nm_peaks)
) %>%
  mutate(fraction = n / total)

print(frac_table)

# Fisher's exact test per motif: is STAT1 fraction enriched in pM vs nM?
for (m in unique(frac_table$motif_id)) {
  pm_n <- frac_table %>% filter(motif_id == m, group == "pM") %>% pull(n)
  nm_n <- frac_table %>% filter(motif_id == m, group == "nM") %>% pull(n)
  tbl <- matrix(c(pm_n, n_pm_peaks - pm_n, nm_n, n_nm_peaks - nm_n), nrow = 2)
  ft <- fisher.test(tbl)
  cat(sprintf("%s: OR=%.2f, p=%.2e\n", m, ft$estimate, ft$p.value))
}

write.csv(frac_table, "results/stat1_irf_fraction_by_dose.csv", row.names = FALSE)
