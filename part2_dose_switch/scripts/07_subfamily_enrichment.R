library(dplyr)

subfamilies <- readLines("~/data/files/repeatmasker/all_subfamilies.txt")
exclude <- c("Alu", "FLAM_A", "FLAM_C", "FRAM", "FAM")
subfamilies <- setdiff(subfamilies, exclude)
cat("Testing", length(subfamilies), "subfamilies\n")

genome_bp <- 2.91e9
pM_total <- 2607; nM_total <- 13142

results <- data.frame()
for (sf in subfamilies) {
  bed_file <- sprintf("~/data/files/repeatmasker/subfam_%s.bed", sf)
  system(sprintf(
    "awk -F'\\t' '$4==\"%s\"' ~/data/files/repeatmasker/hg38_alu_elements.bed > %s",
    sf, bed_file
  ))
  bp <- as.numeric(system(sprintf("awk '{s+=$3-$2} END{print s+0}' %s", bed_file), intern=TRUE))
  if (is.na(bp) || bp == 0) { file.remove(bed_file); next }

  pM_ov <- as.numeric(system(sprintf(
    "bedtools intersect -u -a ~/alu_brca/part2_dose_switch/results/macs_real/pM_star_merged.bed -b %s | wc -l", bed_file
  ), intern=TRUE))
  nM_ov <- as.numeric(system(sprintf(
    "bedtools intersect -u -a ~/alu_brca/part2_dose_switch/results/macs_real/nM_star_merged.bed -b %s | wc -l", bed_file
  ), intern=TRUE))

  p_frac <- bp / genome_bp
  pM_exp <- pM_total * p_frac
  nM_exp <- nM_total * p_frac
  pM_p <- tryCatch(binom.test(pM_ov, pM_total, p_frac)$p.value, error=function(e) NA)
  nM_p <- tryCatch(binom.test(nM_ov, nM_total, p_frac)$p.value, error=function(e) NA)

  results <- rbind(results, data.frame(
    subfamily = sf, bp = bp,
    pM_obs = pM_ov, pM_exp = round(pM_exp,1), pM_ratio = round(pM_ov/pM_exp,3), pM_p = pM_p,
    nM_obs = nM_ov, nM_exp = round(nM_exp,1), nM_ratio = round(nM_ov/nM_exp,3), nM_p = nM_p
  ))
  file.remove(bed_file)
}

results$pM_fdr <- p.adjust(results$pM_p, method = "BH")
results$nM_fdr <- p.adjust(results$nM_p, method = "BH")
results <- results %>% arrange(nM_ratio)
print(results, row.names = FALSE)
write.csv(results, "~/alu_brca/part2_dose_switch/results/h7b_subfamily_enrichment.csv", row.names = FALSE)
cat("\nSaved", nrow(results), "subfamily results.\n")
