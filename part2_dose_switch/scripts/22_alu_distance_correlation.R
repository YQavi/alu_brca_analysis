library(dplyr)

RESULTS_DIR <- "~/alu_brca/part2_dose_switch/results/macs_real"
df <- read.csv(file.path(RESULTS_DIR, "nearest_alu_setA_setBv3_combined.csv"))

df$set <- factor(df$set, levels = c("SetA_ER_H3K27ac", "SetB_v3_ER_H3K27ac_PROseq"))
df$dose <- factor(df$dose, levels = c("10pM", "100pM", "1nM", "10nM"))

cat("--- Does distance to nearest Alu differ between Set A and Set B (continuous, not binary)? ---\n")
wt <- wilcox.test(distance ~ set, data = df)
cat(sprintf("Set A median=%.0f  Set B median=%.0f  p=%.4f\n",
            median(df$distance[df$set=="SetA_ER_H3K27ac"]),
            median(df$distance[df$set=="SetB_v3_ER_H3K27ac_PROseq"]), wt$p.value))

cat("\n--- Formal model: does distance predict set membership, controlling for dose? ---\n")
model <- glm(set == "SetB_v3_ER_H3K27ac_PROseq" ~ log1p(distance) * dose, data = df, family = binomial)
print(summary(model))

cat("\n--- Does distance correlate with subfamily age tier? (young/middle/old, continuous) ---\n")
alu_tiers <- list(
  young = readLines("~/data/files/repeatmasker/AluY_only.bed") %>% length(),  # placeholder, real tier check below
  NULL
)
# Tag each row's nearest-Alu tier by matching subfamily prefix
df$alu_tier <- case_when(
  grepl("^AluY", df$nearest_alu_subfamily) ~ "young",
  grepl("^AluS", df$nearest_alu_subfamily) ~ "middle",
  grepl("^AluJ", df$nearest_alu_subfamily) ~ "old",
  TRUE ~ "other"
)
df_tiered <- df %>% filter(alu_tier %in% c("young","middle","old"))
cat("Median distance by tier (Set A + Set B combined):\n")
print(df_tiered %>% group_by(alu_tier) %>% summarise(median_dist = median(distance), n = n()))

kw <- kruskal.test(distance ~ alu_tier, data = df_tiered)
cat(sprintf("\nKruskal-Wallis (distance ~ tier): p=%.4f\n", kw$p.value))
