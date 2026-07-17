# Analysis Decision Log

| Date | Avenue | Decision | Rationale | Alternative considered |
| :---: | :---: | --- | ---| --- |
| 06/27/2026 | Part 1 - CIA Signature Gene Set | Pare down mcf7_GO_study_genes.txt (2,587 genes) to a smaller, high-confidence gene set to reduce noise | No overlaps between known ESR1 targets and the CIA gene list. A mix of  CIA genes that are also near ESR1 ChIP-seq peaks and CIA genes expressed in breast tissue used to construct the list. This uses known connections with breast tissue and focuses spatially near ESR1 sites.<br><br>Housekeeping genes are excluded by referencing Eisenberg & Levanon 2013. ER+ genes are defined from PAM50 gene list, OncotypeDX genes, ESR1-target compendium (Ross-Innes et al. 2012, Parker et al. 2009, Perou et al. 2000) | Using all 2570 CIA genes — rejected because set is alphabetically ordered with no functional prioritisation and includes many genes unlikely to show ER-specific regulation |
| 06/28/2026 | Part 1 - Data Validation - Subtype Distribution | Proceed with TCGA distribution. Note in methods that TCGA overrepresents aggressive subtypes relative to population | LumA is 46% vs ~70% in SEER population statistics. Explanation: TCGA is not a population-representative cohort — it oversamples aggressive/rare subtypes for scientific interest. Basal (16%) and HER2 (7%) are enriched relative to population. This is expected and documented in TCGA BRCA publications. Does not affect our analysis since we compare within TCGA | 
| 06/28/2026 | Part 1 - NA Subtype Handling |  Keep as separate "Unclassified" group | 103 samples have missing PAM50 subtype. All are primary tumors with survival data — not technical failures<br><br>Planned extension: use CIA signature score to predict subtype for these 103 samples (k-NN or centroid-based classifiertrained on the 981 labeled samples), then test whether CIA-predicted subtype correlates with actual survival. This converts missing data into a prospective validation of the CIA signature as a subtype biomarker
| 06/29/2026 | Part 1 - ER status proxy | Use PAM50 subtype as ER+ proxy throughout:<br><br> ER+ = BRCA_LumA + BRCA_LumB (n=696)<br><br> ER- = BRCA_Basal (n=171)<br><br> HER2-enriched treated separately (n=78)<br><br> Normal-like excluded from primary analysis (n=36, likely stromal contamination, not a true tumor subtype) | ER_STATUS_BY_IHC absent from PanCancer Atlas clinical file. PAM50 is more reproducible than IHC and is the current clinical standard for molecular subtyping.
| 06/30/2026 | Part 1 - Expression Profile Selection | Selected brca_tcga_pan_can_atlas_2018_rna_seq_v2_mrna (raw RSEM) | CIA signature score requires per-gene z-scoring across all 1084 samples from a common baseline. Using pre-z-scored values would double-normalise and distort relative expression. Raw RSEM values normalise for read depth and transcript length, making genes comparable within the study |
| 06/30/2026 | Part 1 - Final signature size after TCGA mapping | Minimum gene set threshold: 250-300 genes. Analysis yieled 419 genes mapped to TCGA Entrez IDs/724 protein-coding CIA genes | Signature captures functional breadth across CIA-proximal pathways, not a curated known-pathway list. Dropping below 250 would risk the score being dominated by a single functional category rather than reflecting the full Alu-ERE regulatory landscape |
| 2026-06 | Part 1 | Exclude BRCA_Normal (n=36) from primary subtype comparison | PAM50 Normal-like tumors are NOT normal tissue — likely heavily stromal-contaminated tumors, not a true subtype. Including as baseline would be biologically misleading as true matched normals are absent from this dataset | Include as a sixth subtype; include as biological control baseline — both rejected due to ambiguous biological identity |
| 2026-06 | Part 1 | Expression matrix accepted as clean; 2 samples dropped via inner join | RSEM range 0–249,463 is expected; no NAs; high values reflect highly expressed genes. 2 samples had clinical data only and NA subtype — inner join exclusion causes no information loss | Impute missing expression values — rejected as only 2 samples affected |
[2026-07] [Part 5] [Han et al. data availability — gate 1]
Checked JBC published page, ScienceDirect mirror, and full bioRxiv preprint
(2022.09.23.509212) text. No Data Availability statement or GEO accession
found in any version. This is atypical for a 2025 JBC paper and blocks
direct peak-coordinate overlap for H2 as originally planned.
Decision: email corresponding authors (Ramachandran, Kabos) requesting data;
in parallel, proceed with H2 as a within-Kim-only motif co-occurrence test
(STAT1/IRF motifs inside Kim et al.'s pM-responsive ERα peaks) as a fallback
that doesn't require Han's raw data. Upgrade to full two-lab overlap if a
reply provides access.

[2026-07] [Part 5] [Kim et al. GEO accessions — confirmed]
RNA-seq: GSE298771 | ChIP-seq: GSE298767 | ATAC-seq: GSE298769
PRO-seq: GSE298770 | Superseries: GSE298773 | RIME: MSV000098072
Source: Data and Materials section, bioRxiv 2025.08.08.669412 full text.

[2026-07] [Part 5] [Han et al. data availability — gate 1]
Checked JBC published page, ScienceDirect mirror, and full bioRxiv preprint
(2022.09.23.509212) text. No Data Availability statement or GEO accession
found in any version. This is atypical for a 2025 JBC paper and blocks
direct peak-coordinate overlap for H2 as originally planned.
Decision: email corresponding authors (Ramachandran, Kabos) requesting data;
in parallel, proceed with H2 as a within-Kim-only motif co-occurrence test
(STAT1/IRF motifs inside Kim et al.'s pM-responsive ERα peaks) as a fallback
that doesn't require Han's raw data. Upgrade to full two-lab overlap if a
reply provides access.

[2026-07] [Part 5] [Kim et al. GEO accessions — confirmed]
RNA-seq: GSE298771 | ChIP-seq: GSE298767 | ATAC-seq: GSE298769
PRO-seq: GSE298770 | Superseries: GSE298773 | RIME: MSV000098072
Source: Data and Materials section, bioRxiv 2025.08.08.669412 full text.

[2026-07] [Part 5] [Option 3 motif IDs corrected]
MA0517.1 is STAT1::STAT2 heterodimer, not standalone STAT2. Corrected set:
STAT1=MA0137.3, STAT2=MA1623.1, IRF1=MA0050.2, dimer=MA0517.1 (included).
Source: JASPAR (jaspar.elixir.no), cross-checked against Kolendowski/Weichselbaum-
era literature use of MA0137.2/MA0050.1 as the STAT1/IRF1 convention.

[2026-07] [Part 5] [Real bug: wrong SRX accessions downloaded/aligned for ER 10pM]
Positionally-inferred SRX accessions (assumed sequential by dose) were wrong -
GEO's SRX assignment for GSE298767 is not sequential by treatment condition.
Downloaded/aligned files were actually ER@1nM rep3 (SRX29018172) + two 10nM
input reps (SRX29018173/174), not ER@10pM. This produced a near-zero MACS3
peak call that looked like a parameter problem but was a sample-identity
problem. Root cause found by directly grep'ing the GEO MINiML XML for the
true Title->SRX mapping rather than inferring from list position.
Fix: built accession_map_verified.tsv from the XML, verified before every
download from here forward. Misdownloaded files were not wasted - renamed
and kept as real ER@1nM/input@10nM data, useful for later doses.

[2026-07] [Part 5] [10pM input alignment rate anomaly]
ER_10pM_input_v2 aligned at 64.59% vs treatment's 94.05% - a larger gap
than expected between input and ChIP. ~38M reads still aligned, sufficient
for background estimation, so proceeded without re-trimming/re-downloading.
Worth adapter-trimming (fastp/cutadapt) before aligning future input samples
if the pattern recurs at other doses.

[2026-07] [Part 5] [First real, trustworthy peak set: ER 10pM]
99 peaks called, ER_10pM_v2_real (MACS3, q<0.05, correct SRX-verified
accessions, MAPQ>=30 filtered, 36.4M treatment / 32.8M input reads).
Fold enrichment 7-77x, peak widths ~200-450bp - biologically plausible,
consistent with low-dose ERBS being the smallest/most selective cistrome
per Kim et al. Fig S3B. This supersedes both the Path A bigwig
approximation and the earlier mismapped-sample zero-peak result.

[2026-07] [Part 5] [Coordinate bug: GREB1 validation used hg19 coordinates on hg38 data]
Earlier GREB1 sanity-check window (chr2:11,674,000-11,677,000) was hg19 -
true hg38 GREB1 gene body is chr2:11,482,341-11,642,789, ~30kb away and
non-overlapping. Both the original bigwig comparison and the ER_10pM_v2
peak-overlap check were invalid as a result. Re-ran with correct hg38
coordinates. All genomic coordinate checks going forward verified against
hg38 explicitly before use.
