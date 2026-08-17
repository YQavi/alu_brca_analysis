library(dplyr)

read_nearest <- function(tier) {
  df <- read.delim(sprintf("~/alu_brca/part2_dose_switch/results/macs_real/richi_%s_nearest_alu.bed", tier), header = FALSE)
  n <- ncol(df)
  data.frame(tier = tier, alu_subfamily = df[[n - 3]], distance = df[[n]])
}

combined <- bind_rows(read_nearest("high_activity"), read_nearest("low_activity"))

cat("--- Median distance to nearest Alu (any subfamily), Richi's real data ---\n")
print(combined %>% group_by(tier) %>% summarise(median_dist = median(distance), n = n()))

wt <- wilcox.test(distance ~ tier, data = combined)
cat(sprintf("\nWilcoxon p = %.2e\n", wt$p.value))

cat("\n--- Subfamily composition near high-activity peaks (top 10) ---\n")
print(combined %>% filter(tier == "high_activity") %>% count(alu_subfamily, sort = TRUE) %>% head(10))

combined$alu_tier <- case_when(
  grepl("^AluY", combined$alu_subfamily) ~ "young",
  grepl("^AluS", combined$alu_subfamily) ~ "middle",
  grepl("^AluJ", combined$alu_subfamily) ~ "old",
  TRUE ~ "other"
)
cat("\n--- Age-tier composition by activity level ---\n")
print(combined %>% filter(alu_tier != "other") %>% count(tier, alu_tier) %>%
        tidyr::pivot_wider(names_from = tier, values_from = n, values_fill = 0))
