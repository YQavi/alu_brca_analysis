# Han et al. 2025 (JBC 301(7):108499) — digitized reference values
# Source: full text (JBC/ScienceDirect) + bioRxiv preprint 2022.09.23.509212
# No raw data/GEO accession available as of 2026-07 — see analysis_decisions.md.
# Use these as an external direction-of-effect check, NOT as ground truth counts.

## Assay design
- ER CUT&RUN, MCF7 + UCD12 cells, hg38 (GRCh38)
- E2 doses: 10^-12, 10^-10, 10^-8 M (+ ETOH control), 1 hr treatment
- ~50,000 avg peaks/condition (MCF7), ~30,000 avg peaks/condition (UCD12)
- Peak calling: custom Savitzky-Golay smoothing + scipy find_peaks, min 250bp spacing
- Motif calling: FIMO, HOCOMOCO v11 database (NOTE: Kim et al. used JASPAR —
  mismatch to flag if replicating exactly; JASPAR STAT1 motif is close enough
  for a directional check)

## K-means peak clusters (k=5, from 6 minus 1 discarded)
| Cluster | Definition                          | ERE enrichment | Notes |
|---------|--------------------------------------|----------------|-------|
| 1       | Specific to 10^-12 M E2 (lowest)     | Lowest         | STAT1 = top enriched motif (C1 pattern); STAT2, CPEB1, PAX5, FOX family, IRF family also enriched |
| 2       | Specific to 10^-10 M E2              | Low            | — |
| 3       | Specific to 10^-8 M E2 (highest)     | ~20% of 4,651 differential peaks had EREs | Highest single-dose peak count of the specific-dose clusters |
| 4       | Progressive increase across doses    | Higher         | C2 pattern: ESR1/ESR2, NR1H, RXR, RAR motifs enriched |
| 5       | Progressive increase across doses    | Highest        | Same C2 pattern, strongest |

## Key claims to test against
1. STAT1 motif fraction DECREASES monotonically as E2 dose increases (top hit at 10^-12 M)
2. STAT1 knockdown reduces ER CUT&RUN signal specifically at 10^-12 M E2, minimal effect at 10^-8 M
3. Even at the highest dose (10^-8 M), only ~20% of dose-specific peaks carry a canonical ERE —
   most ER binding genome-wide is non-canonical regardless of dose
4. STAT1 expression is higher in postmenopausal vs premenopausal TCGA breast cancer patients
5. High STAT1 expression correlates with worse survival in ER+ breast cancer (Kaplan-Meier, TCGA)

## What would count as replication in the Kim-only fallback
If STAT1/IRF motif fraction in Kim et al.'s pM-responsive ERα peaks is elevated relative to
nM-responsive peaks, in the same direction as Han's cluster 1 vs cluster 3/4/5 pattern, that's
a same-direction, different-lab, different-assay (ChIP-seq vs CUT&RUN) replication — weaker than
a coordinate-level peak overlap, but still a real independent check.
