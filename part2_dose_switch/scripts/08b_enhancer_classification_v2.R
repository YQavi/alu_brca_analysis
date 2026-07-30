library(dplyr)

RESULTS_DIR <- "~/alu_brca/part2_dose_switch/results/macs_real"
doses <- c("100pM", "1nM", "10nM")  # 10pM excluded, too few peaks to score meaningfully

read_scored <- function(path, colname) {
  df <- read.delim(path, header = FALSE)
  df <- df[, c(1, 2, 3, ncol(df))]
  colnames(df) <- c("chrom", "start", "end", colname)
  df
}

all_scored <- list()
for (dose in doses) {
  atac <- read_scored(file.path(RESULTS_DIR, paste0("atac_scored_", dose, ".tmp")), "atac")
  h3k27ac <- read_scored(file.path(RESULTS_DIR, paste0("h3k27ac_scored_", dose, ".tmp")), "h3k27ac")
  pro_plus <- read_scored(file.path(RESULTS_DIR, paste0("proseq_plus_", dose, ".tmp")), "proseq_plus")
  pro_minus <- read_scored(file.path(RESULTS_DIR, paste0("proseq_minus_", dose, ".tmp")), "proseq_minus")

  stopifnot(nrow(atac) == nrow(h3k27ac), nrow(atac) == nrow(pro_plus), nrow(atac) == nrow(pro_minus))

  merged <- atac %>%
    mutate(
      h3k27ac = h3k27ac$h3k27ac,
      pro_plus_abs = abs(pro_plus$proseq_plus),
      pro_minus_abs = abs(pro_minus$proseq_minus),
      proseq_mag = pro_plus_abs + pro_minus_abs,
      # bidirectionality index: 0 = one-directional, 1 = perfectly balanced both strands
      # computed and saved for future eRNA-specific work, NOT folded into strength score
      proseq_bidir = ifelse(pmax(pro_plus_abs, pro_minus_abs) > 0,
                             pmin(pro_plus_abs, pro_minus_abs) / pmax(pro_plus_abs, pro_minus_abs), 0),
      dose = dose
    )

  # FIX 1: log-transform before scaling (all three signals are right-skewed)
  merged <- merged %>%
    mutate(
      atac_log = log1p(pmax(atac, 0)),
      h3k27ac_log = log1p(pmax(h3k27ac, 0)),
      proseq_log = log1p(pmax(proseq_mag, 0))
    )

  all_scored[[dose]] <- merged
}

combined <- bind_rows(all_scored)

# FIX 2: PCA-derived composite instead of unweighted average, computed WITHIN each dose
combined <- combined %>%
  group_by(dose) %>%
  group_modify(~ {
    df <- .x
    z <- scale(df[, c("atac_log", "h3k27ac_log", "proseq_log")])
    pc <- prcomp(z, center = FALSE, scale. = FALSE)
    score <- pc$x[, 1]
    # PCA sign is arbitrary - enforce that higher score = higher raw signal
    if (cor(score, rowSums(z)) < 0) score <- -score
    df$enhancer_score <- as.numeric(score)
    df$pc1_var_explained <- summary(pc)$importance[2, 1]
    df
  }) %>%
  ungroup()

cat("--- Variance explained by PC1 (composite score) per dose ---\n")
print(combined %>% group_by(dose) %>% summarise(pc1_var_explained = first(pc1_var_explained)))

combined <- combined %>%
  group_by(dose) %>%
  mutate(strength_tier = case_when(
    enhancer_score >= quantile(enhancer_score, 2/3, na.rm = TRUE) ~ "strong",
    enhancer_score <= quantile(enhancer_score, 1/3, na.rm = TRUE) ~ "weak",
    TRUE ~ "middle"
  )) %>%
  ungroup()

cat("\n--- Strength tier counts per dose (v2) ---\n")
print(table(combined$dose, combined$strength_tier))

write.csv(combined, file.path(RESULTS_DIR, "enhancer_strength_classification_v2.csv"), row.names = FALSE)

for (dose in doses) {
  for (tier in c("strong", "weak")) {
    sub <- combined %>% filter(dose == !!dose, strength_tier == tier) %>% select(chrom, start, end)
    write.table(sub, file.path(RESULTS_DIR, paste0(tier, "_enhancers_", dose, "_v2.bed")),
                sep = "\t", row.names = FALSE, col.names = FALSE, quote = FALSE)
  }
}
cat("\nv2 BED files written.\n")
