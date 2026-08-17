library(dplyr)

readcounts <- read.table("~/richi_peak_readcounts.txt", header = FALSE,
                          col.names = c("n_reads", "chrom", "start", "end", "peak_name"))
peaks_hg38 <- read.delim("~/alu_brca/part2_dose_switch/results/macs_real/richi_peaks_hg38_sorted.bed",
                          header = FALSE, col.names = c("chrom", "start", "end", "peak_name"))

merged <- peaks_hg38 %>% inner_join(readcounts %>% select(peak_name, n_reads), by = "peak_name")
cat("Peaks with both hg38 coords and read count:", nrow(merged), "\n")

merged$tier <- ifelse(merged$n_reads >= median(merged$n_reads), "high_activity", "low_activity")
cat("Tier split:\n")
print(table(merged$tier))

write.table(merged %>% filter(tier == "high_activity") %>% select(chrom, start, end),
            "~/alu_brca/part2_dose_switch/results/macs_real/richi_high_activity_hg38.bed",
            sep = "\t", row.names = FALSE, col.names = FALSE, quote = FALSE)
write.table(merged %>% filter(tier == "low_activity") %>% select(chrom, start, end),
            "~/alu_brca/part2_dose_switch/results/macs_real/richi_low_activity_hg38.bed",
            sep = "\t", row.names = FALSE, col.names = FALSE, quote = FALSE)
