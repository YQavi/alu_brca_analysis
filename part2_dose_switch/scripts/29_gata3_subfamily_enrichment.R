library(dplyr)

subfamilies <- readLines("~/data/files/repeatmasker/all_subfamilies.txt")
exclude <- c("Alu", "FLAM_A", "FLAM_C", "FRAM", "FAM")
subfamilies <- setdiff(subfamilies, exclude)
cat("Testing", length(subfamilies), "subfamilies against real GATA3 binding\n")

genome_bp <- 2.91e9
RESULTS_DIR <- "~/alu_brca/part2_dose_switch/results/macs_real"
pM_total <- as.integer(system(paste0("grep -cE '^chr([0-9]+|X|Y|M)\\b' ", RESULTS_DIR, "/GATA3_pM_peaks.narrowPeak"), intern=TRUE))
nM_total <- as.integer(system(paste0("grep -cE '^chr([0-9]+|X|Y|M)\\b' ", RESULTS_DIR, "/GATA3_nM_peaks.narrowPeak"), intern=TRUE))
cat("GATA3 pM total:", pM_total, "| nM total:", nM_total, "\n")

results <- data.frame()
for (sf in subfamilies) {
  bed_file <- sprintf("~/data/files/repeatmasker/subfam_%s.bed", sf)
  system(sprintf("awk -F'\\t' '$4==\"%s\"' ~/data/files/repeatmasker/hg38_alu_elements.bed > %s", sf, bed_file))
  bp <- as.numeric(system(sprintf("awk '{s+=$3-$2} END{print s+0}' %s", bed_file), intern=TRUE))
  if (is.na(bp) || bp == 0) { file.remove(bed_file); next }

  pM_ov <- as.numeric(system(sprintf("bedtools intersect -u -a %s/GATA3_pM_peaks.narrowPeak -b %s | grep -cE '^chr([0-9]+|X|Y|M)\\b'", RESULTS_DIR, bed_file), intern=TRUE))
  nM_ov <- as.numeric(system(sprintf("bedtools intersect -u -a %s/GATA3_nM_peaks.narrowPeak -b %s | grep -cE '^chr([0-9]+|X|Y|M)\\b'", RESULTS_DIR, bed_file), intern=TRUE))

  p_frac <- bp / genome_bp
  pM_p <- tryCatch(binom.test(pM_ov, pM_total, p_frac)$p.value, error=function(e) NA)
  nM_p <- tryCatch(binom.test(nM_ov, nM_total, p_frac)$p.value, error=function(e) NA)

  results <- rbind(results, data.frame(
    subfamily=sf, bp=bp, pM_obs=pM_ov, pM_exp=round(pM_total*p_frac,1),
    pM_ratio=round(pM_ov/(pM_total*p_frac),3), pM_p=pM_p,
    nM_obs=nM_ov, nM_exp=round(nM_total*p_frac,1),
    nM_ratio=round(nM_ov/(nM_total*p_frac),3), nM_p=nM_p
  ))
  file.remove(bed_file)
}
results$pM_fdr <- p.adjust(results$pM_p, method="BH")
results$nM_fdr <- p.adjust(results$nM_p, method="BH")
results <- results %>% arrange(nM_fdr)
cat("\n--- Significant at FDR<0.05 ---\n")
print(results %>% filter(pM_fdr < 0.05 | nM_fdr < 0.05))
write.csv(results, file.path(RESULTS_DIR, "h18_gata3_subfamily_enrichment.csv"), row.names=FALSE)
