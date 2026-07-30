#!/usr/bin/env Rscript
# Part 5 figure generator - reads structured result CSVs, produces one
# appropriately-typed figure per result, saved to results/figures/.
# Run from part2_dose_switch/ directory, or adjust RESULTS_DIR below.

suppressPackageStartupMessages({
  if (!require("ggplot2", quietly = TRUE)) install.packages("ggplot2", repos="https://cloud.r-project.org")
  library(ggplot2)
  library(dplyr)
})

RESULTS_DIR <- "~/alu_brca/part2_dose_switch/results"
FIG_DIR     <- file.path(RESULTS_DIR, "figures")
dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)

PM_COLOR <- "#2E86AB"; NM_COLOR <- "#E67E22"

theme_part5 <- theme_minimal(base_size = 12) +
  theme(panel.grid.minor = element_blank(),
        plot.title = element_text(face = "bold", size = 13),
        legend.position = "top")

save_fig <- function(p, name, w = 6.5, h = 5) {
  ggsave(file.path(FIG_DIR, paste0(name, ".png")), p, width = w, height = h, dpi = 300)
  ggsave(file.path(FIG_DIR, paste0(name, ".pdf")), p, width = w, height = h)
  cat("saved:", name, "\n")
}

# ---- Type 1: ordered counts, wide dynamic range -> log-scale bar chart ----
plot_dose_response <- function(csv = "dose_peak_counts.csv") {
  df <- read.csv(file.path(RESULTS_DIR, csv)) %>% arrange(order)
  df$dose <- factor(df$dose, levels = df$dose)
  p <- ggplot(df, aes(dose, peak_count)) +
    geom_col(fill = PM_COLOR, width = 0.6) +
    geom_text(aes(label = format(peak_count, big.mark = ",")), vjust = -0.5, size = 3.5) +
    scale_y_log10(labels = scales::comma) +
    labs(title = "Dose-response: real, verified ERalpha peak counts",
         x = NULL, y = "ERalpha peaks (standard chromosomes, log scale)") +
    theme_part5
  save_fig(p, "dose_response_peaks")
}

# ---- Type 2: ratio-vs-null across categories -> grouped bar + reference line ----
plot_tier_enrichment <- function(csv = "h1_tier_enrichment.csv") {
  df <- read.csv(file.path(RESULTS_DIR, csv))
  df$tier <- factor(df$tier, levels = c("young", "middle", "old"),
                     labels = c("Young\n(AluY/Ya5/Yb8...)", "Middle\n(AluS*)", "Old\n(AluJ*)"))
  df$dose_group <- factor(df$dose_group, levels = c("pM_star", "nM_star"),
                           labels = c("pM* (10+100pM)", "nM* (1+10nM)"))
  df$label <- ifelse(df$pvalue < 0.001,
                      sprintf("p=%.1e", df$pvalue),
                      sprintf("p=%.2f%s", df$pvalue, ifelse(df$pvalue > 0.05, " (ns)", "")))

  p <- ggplot(df, aes(tier, ratio, fill = dose_group)) +
    geom_col(position = position_dodge(0.7), width = 0.6) +
    geom_hline(yintercept = 1, linetype = "dashed") +
    geom_text(aes(label = label), position = position_dodge(0.7), vjust = -0.5, size = 2.8) +
    scale_fill_manual(values = c(PM_COLOR, NM_COLOR)) +
    labs(title = "H1: ERalpha depletion at Alu, graded by subfamily age",
         subtitle = "Dashed line = expected under random placement",
         x = NULL, y = "Observed / expected overlap ratio", fill = NULL) +
    ylim(0, 1.15) + theme_part5
  save_fig(p, "h1_alu_tier_enrichment")
}

# ---- Type 3: proportion comparison across groups -> grouped bar ----
plot_motif_comparison <- function(csv = "h2_motif_comparison.csv") {
  df <- read.csv(file.path(RESULTS_DIR, csv))
  df$dose_group <- factor(df$dose_group, levels = c("pM_star", "nM_star"),
                           labels = c("pM* peaks", "nM* peaks"))
  labs_df <- df %>% group_by(motif_name) %>%
    summarise(y = max(fraction) * 100 + 1.5, pvalue = first(pvalue), .groups = "drop") %>%
    mutate(label = sprintf("p=%.2f", pvalue))

  p <- ggplot(df, aes(motif_name, fraction * 100, fill = dose_group)) +
    geom_col(position = position_dodge(0.7), width = 0.6) +
    geom_text(data = labs_df, aes(motif_name, y, label = label), inherit.aes = FALSE, size = 3) +
    scale_fill_manual(values = c(PM_COLOR, NM_COLOR)) +
    labs(title = "H2: no dose-differential STAT1/IRF motif enrichment",
         subtitle = "Fixed p<0.0001 threshold, calibrated against random genomic background",
         x = NULL, y = "% of peaks with motif", fill = NULL) +
    theme_part5
  save_fig(p, "h2_motif_comparison")
}

# ---- Type 4: odds ratio + CI -> forest / dot-whisker plot (log-scale x-axis) ----
plot_odds_ratio_forest <- function(csv = "h3_odds_ratio.csv") {
  df <- read.csv(file.path(RESULTS_DIR, csv))
  p <- ggplot(df, aes(x = odds_ratio, y = comparison)) +
    geom_vline(xintercept = 1, linetype = "dashed") +
    geom_errorbar(aes(xmin = ci_low, xmax = ci_high), width = 0.15, orientation = "y", color = PM_COLOR, linewidth = 0.8) +
    geom_point(size = 4, color = PM_COLOR) +
    geom_text(aes(label = sprintf("OR=%.2f  [%.2f, %.2f]  p=%.2f", odds_ratio, ci_low, ci_high, pvalue)),
              vjust = -1.3, size = 3.2) +
    scale_x_log10() +
    labs(title = "H3: CIA genes vs. pM-responsive genes",
         x = "Odds ratio (log scale), 95% CI", y = NULL) +
    theme_part5 + theme(axis.text.y = element_text(size = 9))
  save_fig(p, "h3_cia_pM_overlap_forest", h = 3)
}

# ---- Type 5 (template, for continuous data e.g. ATAC-seq signal) ----
# Use when comparing a numeric distribution (not a proportion/ratio) across
# groups - boxplot/violin preserves distribution shape that a bar-of-means hides.
plot_continuous_by_group <- function(csv, value_col, group_col, title, ylab) {
  df <- read.csv(file.path(RESULTS_DIR, csv))
  p <- ggplot(df, aes(.data[[group_col]], .data[[value_col]], fill = .data[[group_col]])) +
    geom_violin(alpha = 0.5, trim = FALSE) +
    geom_boxplot(width = 0.15, outlier.size = 0.5) +
    scale_fill_manual(values = c(PM_COLOR, NM_COLOR, "#7F8C8D")) +
    labs(title = title, x = NULL, y = ylab) +
    theme_part5 + theme(legend.position = "none")
  save_fig(p, tools::file_path_sans_ext(basename(csv)))
}

# ---- run all current figures ----
plot_dose_response()
plot_tier_enrichment()
plot_motif_comparison()
plot_odds_ratio_forest()

cat("\nAll figures written to", FIG_DIR, "\n")

# ---- ATAC-seq baseline accessibility by Alu tier ----
plot_atac_accessibility <- function(raw_csv = "atac_tier_signal.csv", set.seed_val = 42) {
  df <- read.csv(file.path(RESULTS_DIR, raw_csv))
  set.seed(set.seed_val)
  df_sub <- df %>% group_by(tier) %>% slice_sample(n = 20000) %>% ungroup()
  df_sub$tier <- factor(df_sub$tier, levels = c("young", "middle", "old"),
                         labels = c("Young", "Middle", "Old"))

  p <- ggplot(df_sub, aes(tier, signal + 1, fill = tier)) +
    geom_violin(alpha = 0.5, trim = TRUE) +
    geom_boxplot(width = 0.1, outlier.shape = NA) +
    scale_y_log10() +
    scale_fill_manual(values = c(PM_COLOR, "#7F8C8D", NM_COLOR)) +
    labs(title = "Baseline chromatin accessibility (vehicle ATAC-seq) by Alu tier",
         subtitle = "Means: young=2.03, middle=1.73, old=1.99 - no support for young-Alu silencing",
         x = NULL, y = "ATAC signal + 1 (log scale)") +
    theme_part5 + theme(legend.position = "none")
  save_fig(p, "h4_atac_accessibility_by_tier")
}
plot_atac_accessibility()

plot_tf_comparison <- function(csv = "h7_tf_comparison_alu_tiers.csv") {
  df <- read.csv(file.path(RESULTS_DIR, csv))
  df$tier <- factor(df$tier, levels = c("young","middle","old"),
                     labels = c("Young","Middle","Old"))
  df$label <- paste0(df$factor, "_", df$dose)

  p <- ggplot(df, aes(tier, ratio, fill = label)) +
    geom_col(position = position_dodge(0.75), width = 0.7) +
    geom_hline(yintercept = 1, linetype = "dashed") +
    labs(title = "FOXA1 replicates ERalpha's young-Alu depletion; GATA3 diverges",
         subtitle = "Dashed line = expected under random genome-wide placement",
         x = NULL, y = "Observed / expected overlap ratio", fill = NULL) +
    theme_part5
  save_fig(p, "h7_tf_alu_tier_comparison", w = 7.5)
}
plot_tf_comparison()

plot_subfamily_forest <- function(csv = "h7b_subfamily_enrichment.csv", min_bp = 1e6) {
  df <- read.csv(file.path(RESULTS_DIR, csv)) %>%
    filter(bp >= min_bp) %>%   # drop ultra-rare subfamilies with unstable estimates
    mutate(sig = nM_fdr < 0.05,
           subfamily = reorder(subfamily, nM_ratio))

  p <- ggplot(df, aes(nM_ratio, subfamily, color = sig)) +
    geom_vline(xintercept = 1, linetype = "dashed") +
    geom_point(size = 2.5) +
    scale_color_manual(values = c(`TRUE` = "#E67E22", `FALSE` = "grey60"),
                        labels = c("ns", "FDR<0.05"), name = NULL) +
    scale_x_log10() +
    labs(title = "Subfamily-resolved Alu enrichment (nM* peaks)",
         subtitle = "Subfamilies with >=1Mbp genome coverage; dashed line = expected",
         x = "Observed / expected ratio (log scale)", y = NULL) +
    theme_part5 + theme(axis.text.y = element_text(size = 7))
  save_fig(p, "h8_subfamily_forest", h = 7)
}
plot_subfamily_forest()

# ---- H9: ERalpha vs FOXA1 inheritance, per subfamily ----
plot_tf_inheritance <- function(csv = "h9_tf_subfamily_comparison.csv") {
  df <- read.csv(file.path(RESULTS_DIR, csv))
  df$subfamily <- factor(df$subfamily, levels = c("AluY", "AluSc", "AluJr4"))
  df$dose_group <- factor(df$dose_group, levels = c("pM_star", "nM_star"),
                           labels = c("pM* (10+100pM)", "nM* (1+10nM)"))
  df$factor <- factor(df$factor, levels = c("ERalpha", "FOXA1"), labels = c("ERalpha", "FOXA1"))

  p <- ggplot(df, aes(subfamily, ratio, fill = factor)) +
    geom_col(position = position_dodge(0.7), width = 0.6) +
    geom_hline(yintercept = 1, linetype = "dashed") +
    facet_wrap(~dose_group) +
    scale_fill_manual(values = c("ERalpha" = PM_COLOR, "FOXA1" = "#7F8C8D")) +
    labs(title = "AluY exclusion is FOXA1-inherited; AluJr4 enrichment is not",
         subtitle = "Dashed line = expected under random placement",
         x = NULL, y = "Observed / expected overlap ratio", fill = NULL) +
    theme_part5
  save_fig(p, "h9_tf_inheritance_by_subfamily", w = 8, h = 5)
}
plot_tf_inheritance()

# ---- H9: sequence composition, AluY vs AluSc (both tested to be non-explanatory) ----
plot_seq_composition <- function(csv = "h9_sequence_composition.csv") {
  df <- read.csv(file.path(RESULTS_DIR, csv))
  df_long <- df %>%
    tidyr::pivot_longer(c(gc_pct, cpg_oe), names_to = "metric", values_to = "value") %>%
    mutate(metric = factor(metric, levels = c("gc_pct", "cpg_oe"),
                            labels = c("GC content", "CpG obs/exp ratio")))

  p <- ggplot(df_long, aes(subfamily, value, fill = subfamily)) +
    geom_col(width = 0.5) +
    facet_wrap(~metric, scales = "free_y") +
    scale_fill_manual(values = c(PM_COLOR, "#7F8C8D")) +
    labs(title = "Sequence composition does not explain differential depletion",
         subtitle = "AluSc is more depleted than AluY despite lower CpG content",
         x = NULL, y = NULL) +
    theme_part5 + theme(legend.position = "none")
  save_fig(p, "h9_sequence_composition", w = 6.5, h = 4.5)
}
plot_seq_composition()

plot_enhancer_alu_forest <- function(csv = "h10_enhancer_alu_fdr.csv") {
  df <- read.csv(file.path(RESULTS_DIR, csv))
  df$label <- paste0(df$dose, " / ", df$alu_tier)
  df$label <- factor(df$label, levels = rev(df$label[order(df$dose, df$alu_tier)]))
  df$sig <- factor(ifelse(df$significant, "FDR < 0.05", "ns"), levels = c("ns", "FDR < 0.05"))

  p <- ggplot(df, aes(odds_ratio, label, color = sig)) +
    geom_vline(xintercept = 1, linetype = "dashed") +
    geom_point(size = 3) +
    scale_color_manual(values = c("ns" = "grey60", "FDR < 0.05" = NM_COLOR)) +
    scale_x_log10() +
    labs(title = "Strong vs. weak enhancers: Alu tier overlap, by dose",
         subtitle = "Odds ratio, strong/weak; only 10nM-middle survives FDR correction (9 tests)",
         x = "Odds ratio (log scale)", y = NULL, color = NULL) +
    theme_part5 + theme(axis.text.y = element_text(size = 9))
  save_fig(p, "h10_enhancer_alu_forest", h = 5)
}
plot_enhancer_alu_forest()

plot_foxa1_motif_rate <- function(csv = "h11_foxa1_motif_rate.csv") {
  df <- read.csv(file.path(RESULTS_DIR, csv)) %>% distinct(subfamily, .keep_all = TRUE)
  df$subfamily <- factor(df$subfamily, levels = c("AluY", "AluSc", "AluJr4"))

  p <- ggplot(df, aes(subfamily, fraction * 100, fill = subfamily)) +
    geom_col(width = 0.5) +
    scale_fill_manual(values = c(PM_COLOR, "#7F8C8D", NM_COLOR)) +
    labs(title = "FOXA1 motif is rarer in young Alu, explaining its exclusion",
         subtitle = "AluJr4 carries the FOXA1 motif ~8x more often than AluY (p<2.2e-16)",
         x = NULL, y = "% of copies with FOXA1 motif") +
    theme_part5 + theme(legend.position = "none")
  save_fig(p, "h11_foxa1_motif_rate")
}
plot_foxa1_motif_rate()
