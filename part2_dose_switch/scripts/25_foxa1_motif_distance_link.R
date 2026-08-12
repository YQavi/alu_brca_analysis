library(dplyr)

RESULTS_DIR <- "~/alu_brca/part2_dose_switch/results/macs_real"
FOXA1_DIR <- "~/alu_brca/part2_dose_switch/data/raw/foxa1_motif"

# Universe = only AluY copies actually scanned in H11 (length >=250bp) -
# avoids conflating "no motif" with "too short to ever be scanned"
scanned_universe <- read.delim(file.path("~/data/files/repeatmasker/AluY_fulllength.bed"),
                                header = FALSE)
scanned_keys <- paste0(scanned_universe$V1, ":", scanned_universe$V2, "-", scanned_universe$V3)

motif_hits <- readLines(file.path(FOXA1_DIR, "aluY_copies_with_foxa1_motif.txt"))
cat("Scanned AluY universe:", length(scanned_keys), " | With FOXA1 motif:", length(motif_hits), "\n")

# Read raw nearest-Alu files directly (need actual Alu coordinates, not
# just subfamily name - the aggregated CSV doesn't retain these)
read_nearest_with_coords <- function(path, set_label, dose_label) {
  df <- read.delim(path, header = FALSE)
  n <- ncol(df)
  data.frame(
    peak_chrom = df[[1]], peak_start = df[[2]], peak_end = df[[3]],
    alu_chrom = df[[n-6]], alu_start = df[[n-5]], alu_end = df[[n-4]],
    subfamily = df[[n-3]], distance = df[[n]],
    set = set_label, dose = dose_label
  )
}

all_rows <- list()
for (dose in c("10pM","100pM","1nM","10nM")) {
  all_rows[[paste0("A_", dose)]] <- read_nearest_with_coords(
    file.path(RESULTS_DIR, paste0("SetA_ER_H3K27ac_", dose, "_nearest_alu.bed")), "SetA", dose)
  all_rows[[paste0("B_", dose)]] <- read_nearest_with_coords(
    file.path(RESULTS_DIR, paste0("SetB_v3_ER_H3K27ac_PROseq_", dose, "_nearest_alu.bed")), "SetB", dose)
}
combined <- bind_rows(all_rows)

# Restrict to AluY, and to copies actually within the scanned/length-filtered universe
aluY_rows <- combined %>%
  filter(subfamily == "AluY") %>%
  mutate(alu_key = paste0(alu_chrom, ":", alu_start, "-", alu_end)) %>%
  filter(alu_key %in% scanned_keys) %>%
  mutate(has_motif = alu_key %in% motif_hits)

cat("\nAluY nearest-Alu instances within scanned universe:", nrow(aluY_rows), "\n")
cat("  With motif:", sum(aluY_rows$has_motif), " | Without motif:", sum(!aluY_rows$has_motif), "\n")

cat("\n--- Does FOXA1 motif presence predict distance to enhancer? ---\n")
wt <- wilcox.test(distance ~ has_motif, data = aluY_rows)
cat(sprintf("With motif median=%.0f  Without motif median=%.0f  p=%.4f\n",
            median(aluY_rows$distance[aluY_rows$has_motif]),
            median(aluY_rows$distance[!aluY_rows$has_motif]), wt$p.value))

cat("\n--- Controlled model: motif presence x dose, controlling for set ---\n")
aluY_rows$dose <- factor(aluY_rows$dose, levels = c("10pM","100pM","1nM","10nM"))
model <- lm(log1p(distance) ~ has_motif * dose + set, data = aluY_rows)
print(summary(model))

write.csv(aluY_rows, file.path(RESULTS_DIR, "aluY_motif_vs_distance.csv"), row.names = FALSE)
