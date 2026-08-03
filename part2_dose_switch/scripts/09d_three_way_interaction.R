library(dplyr)
library(tidyr)

df <- read.csv("~/alu_brca/part2_dose_switch/results/macs_real/enhancer_alu_overlap_peaklevel.csv")

long <- df %>%
  pivot_longer(c(young, middle, old), names_to = "alu_tier", values_to = "overlap") %>%
  mutate(alu_tier = factor(alu_tier, levels = c("old", "middle", "young")),
         strength_tier = factor(strength_tier, levels = c("weak", "strong")),
         dose = factor(dose, levels = c("100pM", "1nM", "10nM")))

cat("--- Full three-way interaction model ---\n")
model3 <- glm(overlap ~ strength_tier * alu_tier * dose, data = long, family = binomial)
print(summary(model3))

cat("\n--- Odds ratios, three-way interaction terms only ---\n")
coefs <- summary(model3)$coefficients
three_way <- coefs[grepl("strength_tierstrong:alu_tier.*:dose", rownames(coefs)), , drop = FALSE]
print(data.frame(OR = round(exp(three_way[, "Estimate"]), 3),
                  p = round(three_way[, "Pr(>|z|)"], 4)))

cat("\n--- ANOVA: does adding the three-way interaction improve fit over the pooled model? ---\n")
model_pooled <- glm(overlap ~ strength_tier * alu_tier + dose, data = long, family = binomial)
print(anova(model_pooled, model3, test = "Chisq"))

cat("\n--- Simple-slopes: strength:middle-tier interaction, fit separately per dose ---\n")
cat("(interpretive aid alongside the formal 3-way test above, not a separate hypothesis test)\n")
for (d in levels(long$dose)) {
  sub <- long %>% filter(dose == d, alu_tier %in% c("old", "middle"))
  m <- glm(overlap ~ strength_tier * alu_tier, data = sub, family = binomial)
  cc <- summary(m)$coefficients
  int_row <- cc[grepl("strength_tierstrong:alu_tiermiddle", rownames(cc)), ]
  cat(sprintf("%s: strength:middle OR=%.2f  p=%.4f\n", d, exp(int_row["Estimate"]), int_row["Pr(>|z|)"]))
}
