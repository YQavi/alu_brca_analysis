library(dplyr)

RESULTS_DIR <- "~/alu_brca/part2_dose_switch/results/macs_real"
classif <- read.csv(file.path(RESULTS_DIR, "enhancer_strength_classification_v2.csv"))
classif$row_id <- seq_len(nrow(classif))

# Flag Alu overlap for every classified enhancer region
bed_path <- file.path(RESULTS_DIR, "enhancer_coords_for_alu_overlap.bed")
write.table(classif %>% select(chrom, start, end, row_id),
            bed_path, sep = "\t", row.names = FALSE, col.names = FALSE, quote = FALSE)

out_path <- file.path(RESULTS_DIR, "enhancer_alu_any_overlap.bed")
system(sprintf("bedtools intersect -c -a %s -b %s > %s",
               bed_path, "~/data/files/repeatmasker/hg38_alu_elements.bed", out_path))

alu_overlap <- read.delim(out_path, header = FALSE,
                           col.names = c("chrom", "start", "end", "row_id", "alu_overlap_count"))

classif <- classif %>%
  left_join(alu_overlap %>% select(row_id, alu_overlap_count), by = "row_id") %>%
  mutate(has_alu = alu_overlap_count > 0)

cat("--- Regions with vs without Alu overlap, per dose ---\n")
print(table(classif$dose, classif$has_alu))

cat("\n--- Bidirectionality index (PRO-seq): Alu-overlapping vs non-overlapping, per dose ---\n")
pvals <- c()
for (d in unique(classif$dose)) {
  sub <- classif %>% filter(dose == d)
  alu_bidir <- sub$proseq_bidir[sub$has_alu]
  nonalu_bidir <- sub$proseq_bidir[!sub$has_alu]
  wt <- wilcox.test(alu_bidir, nonalu_bidir)
  pvals[d] <- wt$p.value
  cat(sprintf("%s: Alu median=%.3f (n=%d)  non-Alu median=%.3f (n=%d)  raw p=%.4f\n",
              d, median(alu_bidir, na.rm = TRUE), length(alu_bidir),
              median(nonalu_bidir, na.rm = TRUE), length(nonalu_bidir), wt$p.value))
}
cat("\nFDR-corrected p-values:\n")
print(p.adjust(pvals, method = "BH"))

# Unified model, same discipline as the H10 fix - test main effects and
# interaction directly rather than trusting per-dose point estimates alone
cat("\n--- Unified model: proseq_bidir ~ has_alu * strength_tier + dose ---\n")
classif$dose <- factor(classif$dose, levels = c("100pM", "1nM", "10nM"))
classif$strength_tier <- factor(classif$strength_tier, levels = c("weak", "middle", "strong"))
model <- lm(proseq_bidir ~ has_alu * strength_tier + dose, data = classif)
print(summary(model))

write.csv(classif, file.path(RESULTS_DIR, "enhancer_alu_bidirectionality.csv"), row.names = FALSE)
cat("\nSaved.\n")

cat("\n--- Full interaction model: proseq_bidir ~ has_alu * strength_tier * dose ---\n")
model_full <- lm(proseq_bidir ~ has_alu * strength_tier * dose, data = classif)
print(summary(model_full))

cat("\n--- Does dose actually modulate the has_alu effect? ANOVA comparison ---\n")
model_no_dose_interaction <- lm(proseq_bidir ~ has_alu * strength_tier + dose, data = classif)
print(anova(model_no_dose_interaction, model_full))
