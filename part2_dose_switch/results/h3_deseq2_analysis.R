library(tximport)
library(DESeq2)
library(dplyr)

quant_dir <- "~/alu_brca/part2_dose_switch/results/salmon_quant"
tx2gene <- read.delim("~/alu_brca/part2_dose_switch/results/tx2gene_noversion.tsv", header = FALSE)

# Sample metadata - dose group per SRX, from the verified accession map
samples <- data.frame(
  srx_srr = list.dirs(quant_dir, recursive = FALSE, full.names = FALSE)
) %>%
  mutate(
    dose = case_when(
      grepl("SRX29017826|SRX29017827|SRX29017834", srx_srr) ~ "Veh",
      grepl("SRX29017836|SRX29017837|SRX29017838", srx_srr) ~ "1pM",
      grepl("SRX29017839|SRX29017840|SRX29017841", srx_srr) ~ "10pM",
      grepl("SRX29017842|SRX29017843|SRX29017844", srx_srr) ~ "100pM",
      grepl("SRX29017847|SRX29017848|SRX29017828", srx_srr) ~ "1nM",
      grepl("SRX29017829|SRX29017830|SRX29017831", srx_srr) ~ "10nM",
      grepl("SRX29017832|SRX29017833|SRX29017835", srx_srr) ~ "100nM",
      TRUE ~ NA_character_
    ),
    dose_group = case_when(
      dose %in% c("1pM","10pM","100pM") ~ "pM_star",
      dose %in% c("1nM","10nM","100nM") ~ "nM_star",
      dose == "Veh" ~ "Veh"
    )
  )

stopifnot(all(!is.na(samples$dose)))  # catch any SRX not matched, before proceeding blind
print(samples)

files <- file.path(quant_dir, samples$srx_srr, "quant.sf")
names(files) <- samples$srx_srr
stopifnot(all(file.exists(files)))

txi <- tximport(files, type = "salmon", tx2gene = tx2gene, ignoreTxVersion = TRUE)

saveRDS(txi, "~/alu_brca/part2_dose_switch/results/h3_txi.rds")
saveRDS(samples, "~/alu_brca/part2_dose_switch/results/h3_samples.rds")
cat("tximport complete:", nrow(txi$counts), "genes x", ncol(txi$counts), "samples\n")
