#!/usr/bin/env Rscript
# 01_cia_signature_score.R
# Compute CIA signature scores and test subtype differences
# Part 1: CIA gene expression across PAM50 subtypes

library(dplyr)
library(ggplot2)
library(pheatmap)
library(survival)
library(readr)

# ── Paths ─────────────────────────────────────────────────────────────────
DATA_DIR   <- "~/alu_brca/part1_cia_expression/data/raw"
RESULT_DIR <- "~/alu_brca/part1_cia_expression/results"
FIG_DIR    <- "~/alu_brca/part1_cia_expression/figures"
dir.create(RESULT_DIR, recursive=TRUE, showWarnings=FALSE)
dir.create(FIG_DIR,    recursive=TRUE, showWarnings=FALSE)

# ── Load data ─────────────────────────────────────────────────────────────
cat("Loading data...\n")
expr <- read.table(
  file.path(DATA_DIR, "brca_expr_cia.tsv"),
  header=TRUE, sep="\t", row.names=1, check.names=FALSE
)
clin <- read.table(
  file.path(DATA_DIR, "brca_clinical_merged.tsv"),
  header=TRUE, sep="\t", check.names=FALSE
)
clin <- clin[, !duplicated(names(clin))]

# ── Step 1: align samples ─────────────────────────────────────────────────
shared_samples <- intersect(colnames(expr), clin$sampleId)
expr <- expr[, shared_samples]                        
clin <- clin[match(shared_samples, clin$sampleId), ] 
cat("Aligned samples:", length(shared_samples), "\n")


# ── Step 2: z-score expression per gene ───────────────────────────────────
expr_z <- t(scale(t(expr)))
expr_z[expr_z > 5]  <- 5
expr_z[expr_z < -5] <- -5
cat("Z-score range:", round(min(expr_z, na.rm=TRUE), 2),
    "to", round(max(expr_z, na.rm=TRUE), 2), "\n")


# ── Step 3: filter subtypes ───────────────────────────────────────────────
# YOUR CODE: remove BRCA_Normal and NA subtype samples from clin
subtypes <- c("BRCA_LumA", "BRCA_LumB", "BRCA_Basal", "BRCA_Her2")
unclassified <- clin[is.na(clin$SUBTYPE), ]
clin_filtered <- clin[clin$SUBTYPE %in% subtypes & !is.na(clin$SUBTYPE), ]
expr_filtered <- expr[, clin_filtered$sampleId]
cat("Analysis samples:", nrow(clin_filtered), "\n")
cat("Unclassified samples:", nrow(unclassified), "\n")


# ── Step 4: CIA signature score per sample ────────────────────────────────
expr_z_filtered <- expr_z[, clin_filtered$sampleId]
cia_score <- colMeans(expr_z_filtered, na.rm=TRUE)
cat("CIA score range:", round(min(cia_score), 3),
    "to", round(max(cia_score), 3), "\n")
cat("CIA score mean:", round(mean(cia_score), 3), "\n")



# ── Step 5: add score to clinical dataframe ───────────────────────────────
clin_filtered$cia_score <- cia_score[clin_filtered$sampleId]


# ── Step 6: Kruskal-Wallis test across subtypes ───────────────────────────
kw_result <- kruskal.test(cia_score ~ SUBTYPE, data=clin_filtered)
print(kw_result)



# ── Step 7: pairwise Wilcoxon tests ───────────────────────────────────────
# YOUR CODE: pairwise.wilcox.test with Bonferroni correction
pw_result <- pairwise.wilcox.test(
  clin_filtered$cia_score,
  clin_filtered$SUBTYPE,
  p.adjust.method = "bonferroni"
)
print(pw_result$p.value)
write.csv(pw_result$p.value,
          file.path(RESULT_DIR, "pairwise_wilcoxon_cia.csv"),
          quote=FALSE)



# ── Step 8: boxplot of CIA score by subtype ───────────────────────────────
subtype_order <- c("BRCA_LumA", "BRCA_LumB", "BRCA_Her2", "BRCA_Basal")
subtype_colors <- c("BRCA_LumA"="#08306B", "BRCA_LumB"="#2171B5",
                    "BRCA_Her2"="#E6550D", "BRCA_Basal"="#CB181D")

clin_filtered$SUBTYPE <- factor(clin_filtered$SUBTYPE, levels=subtype_order)

p <- ggplot(clin_filtered, aes(x=SUBTYPE, y=cia_score, fill=SUBTYPE)) +
  geom_boxplot(outlier.shape=NA, alpha=0.8) +
  geom_jitter(width=0.2, size=0.6, alpha=0.4) +
  scale_fill_manual(values=subtype_colors) +
  labs(title="CIA Signature Score by PAM50 Subtype",
       x="PAM50 Subtype", y="CIA Signature Score (mean z-score)") +
  theme_classic() +
  theme(legend.position="none")

ggsave(file.path(FIG_DIR, "cia_score_by_subtype.png"),
       p, width=7, height=5, dpi=150)



# ── Step 9: save scores ───────────────────────────────────────────────────
output <- clin_filtered %>%
  select(sampleId, patientId, SUBTYPE, OS_STATUS, OS_MONTHS, cia_score)

write.table(output,
            file.path(RESULT_DIR, "cia_scores_per_sample.tsv"),
            sep="\t", row.names=FALSE, quote=FALSE)
cat("Saved:", nrow(output), "samples with CIA scores\n")