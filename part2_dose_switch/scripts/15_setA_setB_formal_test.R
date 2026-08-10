library(dplyr)

df <- read.csv("~/alu_brca/part2_dose_switch/results/macs_real/nearest_alu_setA_setB_combined.csv")

cat("--- Formal test: does Set B (vs Set A) predict Alu overlap, controlling for dose? ---\n")
df$set <- factor(df$set, levels = c("SetA_ER_H3K27ac", "SetB_ER_H3K27ac_PROseq"))
df$dose <- factor(df$dose, levels = c("10pM", "100pM", "1nM", "10nM"))
model <- glm(overlaps_alu ~ set * dose, data = df, family = binomial)
print(summary(model))

cat("\n--- Does dose modulate the set effect? ---\n")
model_no_int <- glm(overlaps_alu ~ set + dose, data = df, family = binomial)
print(anova(model_no_int, model, test = "Chisq"))

cat("\n--- Subfamily proportion: Set B as % of Set A, per subfamily ---\n")
subfam_counts <- df %>% filter(!is.na(nearest_alu_subfamily)) %>%
  count(set, nearest_alu_subfamily) %>%
  tidyr::pivot_wider(names_from = set, values_from = n, values_fill = 0)
subfam_counts$ratio_B_over_A <- round(subfam_counts$SetB_ER_H3K27ac_PROseq / subfam_counts$SetA_ER_H3K27ac, 3)
print(subfam_counts %>% arrange(ratio_B_over_A))

cat("\n--- Corrected: same model excluding 10pM (complete separation - 0/38 events) ---\n")
df_no10pM <- df %>% filter(dose != "10pM")
df_no10pM$dose <- droplevels(df_no10pM$dose)
model2 <- glm(overlaps_alu ~ set * dose, data = df_no10pM, family = binomial)
print(summary(model2))

model2_no_int <- glm(overlaps_alu ~ set + dose, data = df_no10pM, family = binomial)
cat("\n--- Does dose modulate the set effect? (excluding 10pM) ---\n")
print(anova(model2_no_int, model2, test = "Chisq"))

cat("\n--- Subfamily depletion test, restricted to n>=20 in Set A, FDR corrected ---\n")
subfam_counts_full <- df %>% filter(!is.na(nearest_alu_subfamily)) %>%
  count(set, nearest_alu_subfamily) %>%
  tidyr::pivot_wider(names_from = set, values_from = n, values_fill = 0) %>%
  filter(SetA_ER_H3K27ac >= 20)

total_A <- sum(subfam_counts_full$SetA_ER_H3K27ac)
total_B <- sum(subfam_counts_full$SetB_ER_H3K27ac_PROseq)

subfam_counts_full$pval <- apply(subfam_counts_full, 1, function(row) {
  a <- as.numeric(row["SetA_ER_H3K27ac"]); b <- as.numeric(row["SetB_ER_H3K27ac_PROseq"])
  tbl <- matrix(c(b, a - b, total_B - b, total_A - a - (total_B - b)), nrow = 2)
  fisher.test(tbl)$p.value
})
subfam_counts_full$fdr <- p.adjust(subfam_counts_full$pval, method = "BH")
subfam_counts_full$ratio <- round(subfam_counts_full$SetB_ER_H3K27ac_PROseq / subfam_counts_full$SetA_ER_H3K27ac, 3)
print(subfam_counts_full %>% arrange(fdr) %>% select(nearest_alu_subfamily, SetA_ER_H3K27ac, ratio, pval, fdr))
