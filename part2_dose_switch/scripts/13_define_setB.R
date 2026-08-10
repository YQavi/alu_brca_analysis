library(dplyr)

RESULTS_DIR <- "~/alu_brca/part2_dose_switch/results/macs_real"
SIGDIR <- "~/alu_brca/part2_dose_switch/data/raw/enhancer_signal"

read_bed4 <- function(path, colname) {
  df <- read.delim(path, header = FALSE)
  ncols <- ncol(df)
  df <- df[, c(1, 2, 3, ncols)]
  colnames(df) <- c("chrom", "start", "end", colname)
  df
}

for (dose in c("10pM", "100pM", "1nM", "10nM")) {
  setA <- read.delim(file.path(RESULTS_DIR, paste0("SetA_ER_H3K27ac_", dose, ".bed")), header = FALSE)[, 1:3]
  colnames(setA) <- c("chrom", "start", "end")

  pro_plus <- read_bed4(file.path(SIGDIR, paste0("proseq_plus_setA_", dose, ".tmp")), "pro_plus")
  pro_minus <- read_bed4(file.path(SIGDIR, paste0("proseq_minus_setA_", dose, ".tmp")), "pro_minus")

  setA$pro_plus_abs <- abs(pro_plus$pro_plus)
  setA$pro_minus_abs <- abs(pro_minus$pro_minus)
  setA$bidir <- ifelse(pmax(setA$pro_plus_abs, setA$pro_minus_abs) > 0,
                        pmin(setA$pro_plus_abs, setA$pro_minus_abs) / pmax(setA$pro_plus_abs, setA$pro_minus_abs), 0)

  med <- median(setA$bidir)
  setA$in_setB <- setA$bidir >= med

  cat(sprintf("%s: median bidir=%.4f, SetB (>=median)=%d / %d SetA regions\n",
              dose, med, sum(setA$in_setB), nrow(setA)))

  write.table(setA %>% filter(in_setB) %>% select(chrom, start, end),
              file.path(RESULTS_DIR, paste0("SetB_ER_H3K27ac_PROseq_", dose, ".bed")),
              sep = "\t", row.names = FALSE, col.names = FALSE, quote = FALSE)
  write.csv(setA, file.path(RESULTS_DIR, paste0("setA_bidir_full_", dose, ".csv")), row.names = FALSE)
}
