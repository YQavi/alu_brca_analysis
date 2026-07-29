library(dplyr)

df <- read.csv("~/alu_brca/part2_dose_switch/results/macs_real/enhancer_alu_overlap.csv")
df <- df %>% filter(dose != "10pM")  # too small to test meaningfully

cat("--- Strong vs weak, direct Fisher's exact per dose per Alu tier ---\n")
for (d in unique(df$dose)) {
  strong <- df %>% filter(dose == d, tier == "strong")
  weak   <- df %>% filter(dose == d, tier == "weak")
  for (alu_tier in c("young", "middle", "old")) {
    s_ov <- strong[[paste0(alu_tier, "_overlap")]]
    w_ov <- weak[[paste0(alu_tier, "_overlap")]]
    s_tot <- strong$total; w_tot <- weak$total
    tbl <- matrix(c(s_ov, s_tot - s_ov, w_ov, w_tot - w_ov), nrow = 2)
    ft <- fisher.test(tbl)
    cat(sprintf("%s / %s: strong=%d/%d weak=%d/%d OR=%.2f p=%.3f\n",
                d, alu_tier, s_ov, s_tot, w_ov, w_tot, ft$estimate, ft$p.value))
  }
}
