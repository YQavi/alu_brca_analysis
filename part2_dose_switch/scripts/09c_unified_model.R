library(dplyr)
library(tidyr)

df <- read.csv("~/alu_brca/part2_dose_switch/results/macs_real/enhancer_alu_overlap_peaklevel.csv")

long <- df %>%
  pivot_longer(c(young, middle, old), names_to = "alu_tier", values_to = "overlap") %>%
  mutate(alu_tier = factor(alu_tier, levels = c("old", "middle", "young")),  # old = reference
         strength_tier = factor(strength_tier, levels = c("weak", "strong")),
         dose = factor(dose, levels = c("100pM", "1nM", "10nM")))

model <- glm(overlap ~ strength_tier * alu_tier + dose, data = long, family = binomial)
cat("--- Unified model: overlap ~ strength_tier * alu_tier + dose ---\n")
print(summary(model))

cat("\n--- Odds ratios with 95% CI ---\n")
print(exp(cbind(OR = coef(model), confint(model))))
