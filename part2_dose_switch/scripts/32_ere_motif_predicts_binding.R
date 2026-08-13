library(dplyr)

MACS_DIR <- "~/alu_brca/part2_dose_switch/results/macs_real"
MOTIF_DIR <- "~/alu_brca/part2_dose_switch/data/raw/foxa1_motif"

test_binding <- function(sf) {
  pos <- read.delim(file.path(MOTIF_DIR, paste0(sf, "_ere_positive.bed")), header = FALSE)
  neg <- read.delim(file.path(MOTIF_DIR, paste0(sf, "_ere_negative.bed")), header = FALSE)

  write.table(pos, "/tmp/pos.bed", sep = "\t", row.names = FALSE, col.names = FALSE, quote = FALSE)
  write.table(neg, "/tmp/neg.bed", sep = "\t", row.names = FALSE, col.names = FALSE, quote = FALSE)
  system("sort -k1,1 -k2,2n /tmp/pos.bed > /tmp/pos_sorted.bed")
  system("sort -k1,1 -k2,2n /tmp/neg.bed > /tmp/neg_sorted.bed")

  pos_hit <- as.integer(system(sprintf(
    "bedtools intersect -u -a /tmp/pos_sorted.bed -b %s/ER_10nM_real_peaks.narrowPeak | wc -l", MACS_DIR), intern = TRUE))
  neg_hit <- as.integer(system(sprintf(
    "bedtools intersect -u -a /tmp/neg_sorted.bed -b %s/ER_10nM_real_peaks.narrowPeak | wc -l", MACS_DIR), intern = TRUE))

  tbl <- matrix(c(pos_hit, nrow(pos) - pos_hit, neg_hit, nrow(neg) - neg_hit), nrow = 2)
  ft <- fisher.test(tbl)
  cat(sprintf("\n%s: motif+ ERalpha overlap=%d/%d (%.3f%%)  motif- overlap=%d/%d (%.3f%%)\n",
              sf, pos_hit, nrow(pos), 100*pos_hit/nrow(pos), neg_hit, nrow(neg), 100*neg_hit/nrow(neg)))
  print(ft)
}

test_binding("AluSc")
test_binding("AluJr4")

cat("\n=== Pooled across all 4 doses (more power) ===\n")
test_binding_pooled <- function(sf) {
  pos <- read.delim(file.path(MOTIF_DIR, paste0(sf, "_ere_positive.bed")), header = FALSE)
  neg <- read.delim(file.path(MOTIF_DIR, paste0(sf, "_ere_negative.bed")), header = FALSE)
  write.table(pos, "/tmp/pos.bed", sep="\t", row.names=FALSE, col.names=FALSE, quote=FALSE)
  write.table(neg, "/tmp/neg.bed", sep="\t", row.names=FALSE, col.names=FALSE, quote=FALSE)
  system("sort -k1,1 -k2,2n /tmp/pos.bed > /tmp/pos_sorted.bed")
  system("sort -k1,1 -k2,2n /tmp/neg.bed > /tmp/neg_sorted.bed")
  pos_hit <- as.integer(system(sprintf("bedtools intersect -u -a /tmp/pos_sorted.bed -b %s/ER_all_doses_merged.bed | wc -l", MACS_DIR), intern=TRUE))
  neg_hit <- as.integer(system(sprintf("bedtools intersect -u -a /tmp/neg_sorted.bed -b %s/ER_all_doses_merged.bed | wc -l", MACS_DIR), intern=TRUE))
  tbl <- matrix(c(pos_hit, nrow(pos)-pos_hit, neg_hit, nrow(neg)-neg_hit), nrow=2)
  ft <- fisher.test(tbl)
  cat(sprintf("\n%s (pooled): motif+ overlap=%d/%d (%.3f%%)  motif- overlap=%d/%d (%.3f%%)\n",
              sf, pos_hit, nrow(pos), 100*pos_hit/nrow(pos), neg_hit, nrow(neg), 100*neg_hit/nrow(neg)))
  print(ft)
}
test_binding_pooled("AluSc")
test_binding_pooled("AluJr4")
