library(dplyr)

RESULTS_DIR <- "~/alu_brca/part2_dose_switch/results/macs_real"

read_nearest <- function(setname, dose) {
  path <- file.path(RESULTS_DIR, paste0(setname, "_", dose, "_nearest_alu.bed"))
  df <- read.delim(path, header = FALSE)
  n <- ncol(df)
  out <- data.frame(
    chrom = df[[1]], start = df[[2]], end = df[[3]],
    nearest_alu_subfamily = df[[n - 3]],
    distance = df[[n]]
  )
  out$set <- setname
  out$dose <- dose
  out$overlaps_alu <- out$distance == 0
  out
}

all_results <- list()
for (setname in c("SetA_ER_H3K27ac", "SetB_v3_ER_H3K27ac_PROseq")) {
  for (dose in c("10pM", "100pM", "1nM", "10nM")) {
    key <- paste0(setname, "_", dose)
    all_results[[key]] <- read_nearest(setname, dose)
  }
}
combined <- bind_rows(all_results)

cat("--- Overlap rate (distance=0) by set and dose ---\n")
print(combined %>% group_by(set, dose) %>%
        summarise(n = n(), pct_overlap = round(100 * mean(overlaps_alu), 1), .groups = "drop"))

cat("\n--- Median distance to nearest Alu (non-overlapping only) by set and dose ---\n")
print(combined %>% filter(!overlaps_alu) %>% group_by(set, dose) %>%
        summarise(n = n(), median_dist = median(distance), .groups = "drop"))

cat("\n--- Nearest-Alu subfamily distribution, Set A vs Set B (pooled across doses) ---\n")
top_subfams <- combined %>% count(nearest_alu_subfamily, sort = TRUE) %>% slice_head(n = 10) %>% pull(nearest_alu_subfamily)
print(combined %>% filter(nearest_alu_subfamily %in% top_subfams) %>%
        count(set, nearest_alu_subfamily) %>%
        tidyr::pivot_wider(names_from = set, values_from = n, values_fill = 0))

write.csv(combined, file.path(RESULTS_DIR, "nearest_alu_setA_setB_combined.csv"), row.names = FALSE)
cat("\nSaved combined nearest-Alu data (n=", nrow(combined), " rows).\n", sep="")
