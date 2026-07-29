library(dplyr)

df <- read.csv("atac_tier_signal.csv")
cat("rows per tier:\n"); print(table(df$tier))

summary_stats <- df %>% group_by(tier) %>%
  summarise(mean = mean(signal), median = median(signal),
            sd = sd(signal), n = n(), .groups = "drop")
print(summary_stats)

cat("\n--- Wilcoxon rank-sum tests (normal approximation, exact=FALSE) ---\n")
young <- df$signal[df$tier == "young"]
middle <- df$signal[df$tier == "middle"]
old <- df$signal[df$tier == "old"]

cat("young vs old:\n")
print(wilcox.test(young, old, exact = FALSE))
cat("\nyoung vs middle:\n")
print(wilcox.test(young, middle, exact = FALSE))
cat("\nmiddle vs old:\n")
print(wilcox.test(middle, old, exact = FALSE))

write.csv(summary_stats, "atac_tier_signal_summary.csv", row.names = FALSE)
