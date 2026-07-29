pvals <- c(
  "100pM_young"=0.342, "100pM_middle"=0.022, "100pM_old"=0.183,
  "1nM_young"=1.000,   "1nM_middle"=0.820,   "1nM_old"=0.568,
  "10nM_young"=0.791,  "10nM_middle"=0.001,  "10nM_old"=0.449
)
fdr <- p.adjust(pvals, method = "BH")
bonf <- p.adjust(pvals, method = "bonferroni")
data.frame(test = names(pvals), raw_p = pvals, fdr = round(fdr, 4), bonferroni = round(bonf, 4))
