library(dplyr)

# Fallback if biomaRt unavailable/slow: use a local conversion via the GTF itself
gtf_genes <- system("awk -F'\t' '$3==\"gene\"' ~/data/files/gencode.v49.annotation.gtf",
                     intern = TRUE)
gene_map <- data.frame(line = gtf_genes) %>%
  mutate(
    ensembl_id = sub('.*gene_id "([^"]*)".*', '\\1', line),
    ensembl_id = sub('\\.[0-9]+$', '', ensembl_id),
    symbol     = sub('.*gene_name "([^"]*)".*', '\\1', line)
  ) %>%
  select(ensembl_id, symbol)

pM_ensembl <- readLines("pM_responsive_genes.txt")
pM_symbols <- gene_map %>% filter(ensembl_id %in% pM_ensembl) %>% pull(symbol) %>% unique()

cia_genes <- read.delim("~/alu_brca/part1_cia_expression/data/cia_genes_entrez_map.tsv")$symbol

overlap <- intersect(cia_genes, pM_symbols)
cat("CIA genes total:", length(cia_genes), "\n")
cat("pM-responsive genes (converted to symbol):", length(pM_symbols), "\n")
cat("Overlap:", length(overlap), "\n")
print(overlap)

# Fisher's exact: is CIA-gene membership associated with pM-responsiveness,
# using ~20,000 protein-coding genes as the background universe
universe_size <- 20000
tbl <- matrix(c(
  length(overlap), length(cia_genes) - length(overlap),
  length(pM_symbols) - length(overlap),
  universe_size - length(cia_genes) - length(pM_symbols) + length(overlap)
), nrow = 2)
print(fisher.test(tbl))
