library(dplyr)
library(tidyr)
library(survival)
library(survminer)

RESULTS_DIR <- "~/alu_brca/part2_dose_switch/results"
PART1_DIR   <- "~/alu_brca/part1_cia_expression/data/raw"
FIG_DIR     <- file.path(RESULTS_DIR, "figures")

# ── Load and pivot to wide matrix ──────────────────────────────────────────
cat("Loading long-format expression...\n")
long <- read.delim(file.path(RESULTS_DIR, "alu_survival_expr_long.tsv"))

expr_wide <- long %>%
  pivot_wider(names_from = sampleId, values_from = value, values_fn = mean) %>%
  tibble::column_to_rownames("gene_symbol") %>%
  as.matrix()
cat("Matrix:", nrow(expr_wide), "genes x", ncol(expr_wide), "samples\n")

# ── Z-score per gene, same method as Part 1 ────────────────────────────────
expr_z <- t(scale(t(expr_wide)))
expr_z[expr_z > 5]  <- 5
expr_z[expr_z < -5] <- -5

# ── Gene sets ────────────────────────────────────────────────────────────
proximal_genes <- readLines(file.path(RESULTS_DIR, "macs_real", "alu_proximal_genes.txt"))
distal_genes   <- readLines(file.path(RESULTS_DIR, "macs_real", "alu_distal_genes.txt"))
proximal_genes <- intersect(proximal_genes, rownames(expr_z))
distal_genes   <- intersect(distal_genes, rownames(expr_z))
cat("Proximal genes matched in expression data:", length(proximal_genes), "\n")
cat("Distal genes matched in expression data:", length(distal_genes), "\n")

proximal_score <- colMeans(expr_z[proximal_genes, ], na.rm = TRUE)
distal_score   <- colMeans(expr_z[distal_genes, ], na.rm = TRUE)

scores <- data.frame(
  sampleId = colnames(expr_z),
  alu_proximal_score = proximal_score,
  alu_distal_score = distal_score
)

# ── Merge with clinical data ────────────────────────────────────────────────
clin <- read.table(file.path(PART1_DIR, "brca_clinical_merged.tsv"),
                    header = TRUE, sep = "\t", check.names = FALSE)
clin <- clin[, !duplicated(names(clin))]

merged <- inner_join(scores, clin, by = "sampleId")
cat("Merged samples:", nrow(merged), "\n")

# ── Survival setup ──────────────────────────────────────────────────────────
merged$OS_STATUS_num <- as.numeric(substr(merged$OS_STATUS, 1, 1))
merged <- merged %>% filter(!is.na(OS_MONTHS), !is.na(OS_STATUS_num))
cat("Samples with valid survival data:", nrow(merged), "\n")

# median split for KM curves
merged$proximal_group <- ifelse(merged$alu_proximal_score > median(merged$alu_proximal_score, na.rm=TRUE), "High", "Low")
merged$distal_group   <- ifelse(merged$alu_distal_score > median(merged$alu_distal_score, na.rm=TRUE), "High", "Low")

# ── Cox models (continuous score, more powerful than median split) ─────────
cat("\n--- Cox PH: Alu-proximal score ---\n")
cox_prox <- coxph(Surv(OS_MONTHS, OS_STATUS_num) ~ alu_proximal_score, data = merged)
print(summary(cox_prox))

cat("\n--- Cox PH: Alu-distal score ---\n")
cox_dist <- coxph(Surv(OS_MONTHS, OS_STATUS_num) ~ alu_distal_score, data = merged)
print(summary(cox_dist))

# ── KM plots ─────────────────────────────────────────────────────────────
fit_prox <- survfit(Surv(OS_MONTHS, OS_STATUS_num) ~ proximal_group, data = merged)
p1 <- ggsurvplot(fit_prox, data = merged, pval = TRUE, risk.table = TRUE,
                  title = "Survival by Alu-proximal ERα-target gene score",
                  palette = c("#E67E22", "#2E86AB"))
ggsave(file.path(FIG_DIR, "h6_survival_alu_proximal.png"), p1$plot, width = 7, height = 5, dpi = 300)

fit_dist <- survfit(Surv(OS_MONTHS, OS_STATUS_num) ~ distal_group, data = merged)
p2 <- ggsurvplot(fit_dist, data = merged, pval = TRUE, risk.table = TRUE,
                  title = "Survival by Alu-distal ERα-target gene score",
                  palette = c("#E67E22", "#2E86AB"))
ggsave(file.path(FIG_DIR, "h6_survival_alu_distal.png"), p2$plot, width = 7, height = 5, dpi = 300)

write.table(merged, file.path(RESULTS_DIR, "alu_survival_scores_merged.tsv"),
            sep = "\t", row.names = FALSE, quote = FALSE)
cat("\nSaved merged scores + survival data.\n")
