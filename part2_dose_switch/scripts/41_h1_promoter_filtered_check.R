library(dplyr)

genome_bp <- 2.91e9
alu_tiers <- list(
  young = "~/data/files/repeatmasker/alu_young.bed",
  middle = "~/data/files/repeatmasker/alu_middle.bed",
  old = "~/data/files/repeatmasker/alu_old.bed"
)
tier_bp <- sapply(alu_tiers, function(f) {
  as.numeric(system(sprintf("awk '{s+=$3-$2} END{print s}' %s", f), intern = TRUE))
})

for (dose in c("10pM", "100pM", "1nM", "10nM")) {
  total <- as.integer(system(sprintf("wc -l < ER_%s_distal_only_clean.bed", dose), intern = TRUE))
  cat(sprintf("\n=== %s (n=%d, promoter-filtered) ===\n", dose, total))
  for (tier in names(alu_tiers)) {
    ov <- as.integer(system(sprintf("bedtools intersect -u -a ER_%s_distal_only_clean.bed -b %s | wc -l",
                                     dose, alu_tiers[[tier]]), intern = TRUE))
    exp <- total * (tier_bp[tier] / genome_bp)
    cat(sprintf("  %s: obs=%d exp=%.1f ratio=%.3f\n", tier, ov, exp, ov/exp))
  }
}
