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
[2026-07] [Part 2] [Han et al. data availability — gate 1]
Checked JBC published page, ScienceDirect mirror, and full bioRxiv preprint
(2022.09.23.509212) text. No Data Availability statement or GEO accession
found in any version. This is atypical for a 2025 JBC paper and blocks
direct peak-coordinate overlap for H2 as originally planned.
Decision: email corresponding authors (Ramachandran, Kabos) requesting data;
in parallel, proceed with H2 as a within-Kim-only motif co-occurrence test
(STAT1/IRF motifs inside Kim et al.'s pM-responsive ERα peaks) as a fallback
that doesn't require Han's raw data. Upgrade to full two-lab overlap if a
reply provides access.

[2026-07] [Part 2] [Kim et al. GEO accessions — confirmed]
RNA-seq: GSE298771 | ChIP-seq: GSE298767 | ATAC-seq: GSE298769
PRO-seq: GSE298770 | Superseries: GSE298773 | RIME: MSV000098072
Source: Data and Materials section, bioRxiv 2025.08.08.669412 full text.

[2026-07] [Part 2] [Han et al. data availability — gate 1]
Checked JBC published page, ScienceDirect mirror, and full bioRxiv preprint
(2022.09.23.509212) text. No Data Availability statement or GEO accession
found in any version. This is atypical for a 2025 JBC paper and blocks
direct peak-coordinate overlap for H2 as originally planned.
Decision: email corresponding authors (Ramachandran, Kabos) requesting data;
in parallel, proceed with H2 as a within-Kim-only motif co-occurrence test
(STAT1/IRF motifs inside Kim et al.'s pM-responsive ERα peaks) as a fallback
that doesn't require Han's raw data. Upgrade to full two-lab overlap if a
reply provides access.

[2026-07] [Part 2] [Kim et al. GEO accessions — confirmed]
RNA-seq: GSE298771 | ChIP-seq: GSE298767 | ATAC-seq: GSE298769
PRO-seq: GSE298770 | Superseries: GSE298773 | RIME: MSV000098072
Source: Data and Materials section, bioRxiv 2025.08.08.669412 full text.

[2026-07] [Part 2] [Option 3 motif IDs corrected]
MA0517.1 is STAT1::STAT2 heterodimer, not standalone STAT2. Corrected set:
STAT1=MA0137.3, STAT2=MA1623.1, IRF1=MA0050.2, dimer=MA0517.1 (included).
Source: JASPAR (jaspar.elixir.no), cross-checked against Kolendowski/Weichselbaum-
era literature use of MA0137.2/MA0050.1 as the STAT1/IRF1 convention.

[2026-07] [Part 2] [Real bug: wrong SRX accessions downloaded/aligned for ER 10pM]
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

[2026-07] [Part 2] [10pM input alignment rate anomaly]
ER_10pM_input_v2 aligned at 64.59% vs treatment's 94.05% - a larger gap
than expected between input and ChIP. ~38M reads still aligned, sufficient
for background estimation, so proceeded without re-trimming/re-downloading.
Worth adapter-trimming (fastp/cutadapt) before aligning future input samples
if the pattern recurs at other doses.

[2026-07] [Part 2] [First real, trustworthy peak set: ER 10pM]
99 peaks called, ER_10pM_v2_real (MACS3, q<0.05, correct SRX-verified
accessions, MAPQ>=30 filtered, 36.4M treatment / 32.8M input reads).
Fold enrichment 7-77x, peak widths ~200-450bp - biologically plausible,
consistent with low-dose ERBS being the smallest/most selective cistrome
per Kim et al. Fig S3B. This supersedes both the Path A bigwig
approximation and the earlier mismapped-sample zero-peak result.

[2026-07] [Part 2] [Coordinate bug: GREB1 validation used hg19 coordinates on hg38 data]
Earlier GREB1 sanity-check window (chr2:11,674,000-11,677,000) was hg19 -
true hg38 GREB1 gene body is chr2:11,482,341-11,642,789, ~30kb away and
non-overlapping. Both the original bigwig comparison and the ER_10pM_v2
peak-overlap check were invalid as a result. Re-ran with correct hg38
coordinates. All genomic coordinate checks going forward verified against
hg38 explicitly before use.

[2026-07] [Part 2] [Real peak counts: 3 of 4 doses complete]
10pM: 99 peaks | 100pM: 2,607 peaks | 1nM: 5,764 peaks (pre-alt-filter)
All MACS3 q<0.05, MAPQ>=30, correct verified SRX/SRR accessions.
Monotonic increase with dose, consistent with Kim et al. Fig S3B shape.
1nM used multi-replicate MACS3 mode (2 BAMs to -t, 2 to -c) combining
newly-aligned reps A/B with repC recovered from the earlier mismapped-
accession download.
Remaining: 10nM (partial FASTQ already on disk from mismapped download -
input reps 1,2 as SRR33796548/543; need rep3 + all 3 ER reps).

[2026-07] [Part 2] [MILESTONE: All 4 doses have real, verified peak sets]
10pM: 99 | 100pM: 2,607 | 1nM: 5,764 | 10nM: <PASTE FILTERED COUNT>
(standard chromosomes only, MACS3 q<0.05, MAPQ>=30, all SRX/SRR accessions
cross-verified via ENA before download). Monotonic dose-response increase
across all four points, consistent with Kim et al. Fig S3B shape.
This closes out the raw peak-calling phase of Week 2. Next: define
pM*/nM* combined groups (10pM+100pM vs 1nM+10nM, matching Kim et al.'s
own convention) and move to H1 (Alu subfamily enrichment) and H2
(STAT1/IRF motif co-occurrence) in Week 3.

[2026-07] [Part 2] [MILESTONE: All 4 doses have real, verified peak sets]
10pM: 99 | 100pM: 2,607 | 1nM: 5,764 | 10nM: 13,118
(standard chromosomes only, MACS3 q<0.05, MAPQ>=30, all SRX/SRR accessions
cross-verified via ENA before download). Monotonic dose-response increase
across all four points, consistent with Kim et al. Fig S3B shape.
This closes out the raw peak-calling phase of Week 2. Next: define
pM*/nM* combined groups (10pM+100pM vs 1nM+10nM, matching Kim et al.'s
own convention) and move to H1 (Alu subfamily enrichment) and H2
(STAT1/IRF motif co-occurrence) in Week 3.

[2026-07] [Part 2] [H1 first-pass result — with a major confound flagged]
Real subfamily-tiered Alu overlap (young/middle/old vs pM*/nM* merged peaks):
all tiers under-represented vs genome-wide null; young MOST depleted
(ratio 0.45) in both dose groups - opposite direction from H1's prediction.
CRITICAL CAVEAT: MAPQ>=30 filtering (used throughout all peak calls) likely
discriminates against young Alu specifically, since low-divergence copies
are the most prone to multi-mapping and thus most likely to be discarded
regardless of true ERalpha occupancy. Current result may reflect detection-
power bias, not biology. Before concluding H1 is false: rerun peak calling
allowing multi-mapped reads (e.g. bowtie2 -k with fractional/best-scoring
assignment, or a repeat-aware caller) and compare young-tier overlap rate
with vs without the MAPQ filter.

[2026-07] [Part 2] [H1 statistical result: significant graded depletion by Alu age]
binom.test results, all vs genome-wide null:
young pM* p=2.16e-4 | young nM* p=2.17e-17
middle pM* p=2.81e-13 | middle nM* p=6.8e-9
old pM* p=3.64e-3 | old nM* p=0.979 (NOT significant - only null result)
Pattern: depletion strength scales inversely with Alu age (young most
depleted, old ~indistinguishable from random). This gradient is consistent
with EITHER a real biological effect OR the MAPQ>=30 multi-mapping confound
(young Alu = most cross-mapping = most read loss), which would produce an
identical gradient for purely technical reasons. UNRESOLVED - cannot
currently distinguish the two explanations. Do not report/interpret this
result further until the multi-mapping confound is directly tested.

[2026-07] [Part 2] [H1 confound test result: MAPQ filter ruled out]
Reran 10pM peak calling without MAPQ filter (all mapped reads, no
uniqueness requirement). Young-Alu overlap did NOT improve - if anything
got worse (1/99 filtered -> 0/120 unfiltered). This is the opposite of
what the multi-mapping confound predicts, and argues the MAPQ>=30 filter
is not suppressing real young-Alu signal.
CONCLUSION (provisional, single-dose test): H1 as stated (young Alu
enriched for ERalpha binding) is NOT supported. The graded depletion
found last night (young most depleted, old ~null) appears to be a real
pattern, not a filtering artifact - though only directly confound-tested
at one dose (10pM) with a small peak count. Next: decide whether to (a)
accept this as a genuine negative result for H1 and reframe the Part 5
narrative accordingly, or (b) run the same unfiltered comparison at 100pM/
1nM/10nM for a larger-sample confirmation before committing to the
reframe.

[2026-07] [Part 2] [H1 CONFOUND RESOLVED: MAPQ filter ruled out across 3 doses]
Unfiltered vs filtered young-Alu overlap rate, per dose:
100pM: 0.65% -> 0.70% | 1nM: 0.71% -> 0.70% | 10nM: 0.66% -> 0.63%
All changes <0.1pp, no consistent direction - MAPQ filtering has no
material effect on young-Alu detection rate. This rules out multi-mapping
as the explanation for last night's depletion finding.
CONCLUSION: H1 (young Alu enriched for ERalpha binding) is NOT supported.
The reproducible finding is the opposite: ERalpha peaks show genuine,
filter-independent depletion at young Alu elements (~0.6-0.7% overlap vs
1.46% genome-wide expectation), graded by subfamily age (young most
depleted, old ~null). This is now a well-evidenced negative result for
the original H1 mechanism, not an artifact. Reframe needed for Part 5
narrative - see discussion needed on whether depletion itself is the
new finding to build the story around, or whether to pivot to H2 first
and revisit H1 framing after.

[2026-07] [Part 2] [H2 RESULT: no STAT1/IRF motif differential between pM*/nM*]
Threshold calibration: p<0.005 (Kim et al.'s stated threshold) was too
permissive for these short JASPAR PWMs at 400bp/dual-strand scan - both
groups saturated at 97-98% hit rate, uninformative. FIMO's internal
q-value was rejected as a comparison metric (independently FDR-corrected
per file, unfair given pM*=2706 vs nM*=18893 sequences - different
multiple-testing burden). Settled on fixed raw p<0.0001 threshold,
applied identically to both groups, validated against a random genomic
background (5/2700 random windows hit any motif at this threshold, vs
200-600/group in real peaks - confirms threshold has real discriminating
power, not just stringency for its own sake).

RESULT at calibrated threshold: STAT1 (MA0137.3) pM=10.64% nM=11.23%
OR=0.94 p=0.378 | STAT2 (MA1623.1) OR=1.03 p=0.551 | IRF1 (MA0050.2)
OR=0.95 p=0.352 | STAT1::STAT2 dimer (MA0517.1) OR=1.00 p=0.934.
No motif shows significant differential enrichment between dose groups.//
CONCLUSION: H2 not supported. This is now the second of two central
hypotheses (with H1) tested with real, calibrated, background-validated
methodology and found NOT to hold as originally framed. Both real,
trustworthy negative results - not artifacts. Needs a full narrative
reassessment before continuing to H3/H4/H5 as originally scoped.

[2026-07] [Part 2] [H2 Alu-restricted retest: confirms genome-wide null]
Restricted the STAT1/IRF motif comparison to only pM*/nM* peaks overlapping
Alu elements (n=270 pM*, n=2347 nM*), closing the gap where the earlier
H2 test had drifted from the original Alu-anchored formulation to a
genome-wide one. Result matches the genome-wide test almost exactly:
IRF1 OR=1.00 p=1.00, STAT2 OR=1.01 p=1.00, dimer OR=0.96 p=0.87,
STAT1 OR=1.13 p=0.56. No directional lean on any motif - true null,
not an underpowered miss. H2 is now tested in both its general and
Alu-specific forms and fails in both. This closes H2 testing for Part 5
pending any pivot to per-individual-dose (rather than pooled pM*/nM*)
resolution, which remains untested.

[2026-07] [Part 2] [H3 RESULT: no CIA-gene / pM-responsive-gene enrichment]
Test design note: original CIA expression matrix (brca_expr_cia.tsv) is
already restricted to 386 CIA genes, not genome-wide - true genome-wide
CIA-score-vs-pM-gene-set correlation (as originally scoped) was not
possible without rebuilding a full TCGA expression matrix. Ran the more
direct, narrower test instead: does CIA gene list membership overlap
with pM-responsive gene list membership more than chance.
Independently derived pM-responsive gene set (790 genes) via Salmon
(GENCODE v49 decoy-aware index) + DESeq2, applying Kim et al.'s Table S2
classification rule (log2FC>0.6, p<0.05, first-significant-dose logic)
to real RNA-seq data (GSE298771, all 21 samples, Veh+6 doses, 3 reps each).
CIA genes (n=419, from cia_genes_entrez_map.tsv): 18 overlap with
pM-responsive set. Fisher's exact: OR=1.09, 95% CI [0.64,1.76], p=0.70.
No enrichment - true null, CI tightly bracketing 1.

CONCLUSION: H3 not supported. This is the third of three original
hypotheses (H1, H2, H3) tested with real, independently-derived data
and found not to hold. All three real, methodologically sound negative
results, not artifacts - each was cross-checked (H1: MAPQ confound ruled
out across 3 doses; H2: threshold-calibrated and background-validated,
both genome-wide and Alu-restricted; H3: independently reproduced Kim's
gene classification rather than relying on unavailable exact gene lists).
This is a major finding for Part 5's narrative: the "Alu as dose-tunable
switch linking CIA biology to STAT1/immune cooperation" story is not
supported by the data as tested. Requires full narrative reassessment.

[2026-07] [Part 2] [Mechanistic test: chromatin accessibility does NOT explain H1 depletion]
Tested whether young-Alu ERalpha depletion (H1) is explained by baseline
chromatin silencing, using Kim et al.'s vehicle-condition ATAC-seq
(GSE298769, no dose applied - tests accessibility independent of ERalpha).
n=3.48M bedGraph intervals across all Alu elements genome-wide.
Mean signal: young=2.03, old=1.99, middle=1.73 (median=1 for all three).
Young Alu is NOT less accessible than old Alu - if anything marginally
more accessible. Wilcoxon tests all significant (p<2.2e-16) but
uninformative at this n; effect sizes are the relevant read, and they
run counter to the silencing hypothesis.
CONCLUSION: the chromatin-accessibility/host-defense-silencing explanation
for H1's depletion is not supported. The depletion itself remains a real,
robust, confound-tested finding (see H1 entries above) - but its
mechanistic explanation is still open. ERalpha avoids young Alu despite
young Alu being chromatin-accessible at baseline, which argues for a
more specific, sequence- or factor-level exclusion mechanism rather than
simple heterochromatin/silencing.

[2026-07] [Part 2] [Mechanistic test: CpG density does NOT explain within-tier ERalpha binding]
GC%/CpG o/e shows a real, monotonic gradient with Alu age (young=0.542/0.617,
middle=0.515/0.357, old=0.500/0.177 GC%/CpG o/e) - confirms age-tiering
validity independently. But within young Alu specifically, ERalpha-bound
copies (n=88, from nM* overlap) show no significant CpG o/e difference
from unbound copies (n=145,926): bound mean=0.626, unbound mean=0.605,
Wilcoxon p=0.20, t-test p=0.32, 95% CI crosses zero.
CONCLUSION: CpG density correlates with Alu age but does not predict
which specific young-Alu copies ERalpha binds. Ruled out as the causal
mechanism (joining chromatin accessibility, ruled out earlier). Sample
size for the bound group (n=88) is a real limitation - true null vs.
underpowered null cannot be fully distinguished at this n, but two tests
(accessibility, CpG) now point the same direction (not explanatory).
H1's depletion finding remains real and robust; its mechanism remains
open. Pausing further mechanism search here given time budget - moving
to TCGA survival layer next, will revisit Alu subfamily population
structure after.

[2026-07] [Part 2] [Data provenance gap discovered: brca_expr_cia.tsv]
The Part 1 CIA expression matrix (brca_expr_cia.tsv) has no documented
source - script 01_cia_signature_score.R reads it as a pre-existing input,
never generates it, and no earlier decision-log entry describes its origin.
Clinical schema (SUBTYPE field, OS_STATUS "0:LIVING" format, sample ID
pattern) strongly matches brca_tcga_pan_can_atlas_2018 on cBioPortal.
Proceeding on that assumption for Part 5's survival layer (fresh pull,
full gene coverage, documented query this time) rather than attempting
to reverse-engineer the undocumented original. Recommend Part 1's
provenance be confirmed/documented retroactively when time allows.

[2026-07] [Part 2] [H6 RESULT: no survival association for Alu-proximal or Alu-distal ERalpha-target genes]
TCGA BRCA PanCancer Atlas 2018 (n=1082 samples, 151 events), gene sets
defined as nearest genes to real ERalpha peaks that do/don't overlap Alu
elements (combined pM*+nM* peak set, n=13,144 total peaks -> 1,229
Alu-proximal / 7,948 Alu-distal genes by bedtools closest; 633/3,492
matched to TCGA expression after gene-symbol resolution, 5083/8486
overall symbol resolution rate).
Cox PH (continuous z-scored gene-set mean score):
  Alu-proximal: HR=0.97 [0.18,5.27] p=0.97, concordance=0.566
  Alu-distal:   HR=0.87 [0.12,6.29] p=0.89, concordance=0.548
Both null - no survival signal in either direction, wide CIs, concordance
near chance level (0.5). Data provenance note: brca_expr_cia.tsv's
original source was undocumented (see earlier entry); this analysis used
a freshly-pulled, documented cBioPortal query (brca_tcga_pan_can_atlas_2018)
instead, resolving that gap for this specific analysis at least.
CONCLUSION: H6 (survival layer of option 4) not supported. Completes the
full downstream test battery for Part 5: H1 (real depletion, mechanism
unexplained after 2 tests), H2 (no motif differential), H3 (no CIA gene
overlap), H6 (no survival association). The sole positive, robust finding
remains H1's age-graded ERalpha depletion at Alu elements - real,
confound-tested twice, but without an identified downstream consequence
or upstream mechanism at this point.

[2026-07] [Part 2] [H7 RESULT: FOXA1 replicates ERalpha's Alu depletion; GATA3 does not]
Same tiered-Alu overlap test (H1's method) applied to FOXA1 and GATA3
peaks (bigwig-derived, matched vehicle input, calibrated qpois cutoff
c=5 - peak totals cross-checked against Kim et al. Fig S5B, same order
of magnitude: FOXA1 41.8k/47.0k here vs their 51.7k/39.5k(10pM/10nM);
GATA3 9.1k/11.9k here vs their 8.4k/7.3k).
FOXA1: young=0.54-0.55x, middle=0.71-0.74x, old=0.95-0.97x - nearly
identical graded depletion pattern to ERalpha's original H1 result.
GATA3: young=0.67-0.73x (weaker depletion), middle=0.71-1.16x, old=
1.13-1.68x (ENRICHED, especially at nM dose) - opposite pattern from
FOXA1/ERalpha at the old-Alu tier.
CONCLUSION: young-Alu depletion is NOT ERalpha-specific - FOXA1 (the
pioneer factor that opens chromatin ahead of ERalpha) shows the same
pattern, suggesting the exclusion originates at or before the chromatin-
opening stage rather than being a property of ERalpha's own DNA binding
preference. This reframes H1: the interesting biology may be "why do
FOXA1/ERalpha avoid young Alu" (a pioneer-factor-level question) rather
than "why does ERalpha specifically avoid young Alu." GATA3's divergent
pattern (enrichment at old Alu) is a separate, real factor-specific
finding worth its own note.

[2026-07] [Part 2] [H8 RESULT: subfamily-resolved breakdown - AluY and AluSc drive depletion, AluJr4 reverses]
49 subfamilies tested individually (BH-FDR corrected across all), vs
pM*/nM* merged peaks. Significant after FDR<0.05:
  AluY (young, 33.4Mbp, largest young subfamily): pM ratio=0.40 FDR=0.015,
    nM ratio=0.42 FDR=6.7e-14 - main driver of H1's original signal.
  AluSc (middle/AluS lineage): pM ratio=0.11 FDR=0.030, nM ratio=0.43
    FDR=3.5e-4 - depletion as strong as AluY despite NOT being young.
  AluJo (old/AluJ lineage): pM ratio=0.30 FDR=0.030 only (not sig at nM).
  AluJr4 (old/AluJ lineage): nM ratio=1.90 FDR=2.6e-3 - ENRICHED, the
    one reversal in the dataset.
All other ~45 subfamilies non-significant after correction (many have
very low peak counts / low statistical power at this resolution).
CONCLUSION: depletion is not a uniform function of Alu age - it is real
and strong in AluY specifically (not "young Alu" broadly) and in AluSc
(a non-young subfamily), with AluJr4 as a genuine exception in the
opposite direction. This refines but does not overturn H1: reframe
going forward should reference AluY/AluSc specifically rather than
"young Alu" as a blanket category, since several other young subfamilies
(Ya5, Yb8, Ym1, etc.) had too few peaks for reliable individual testing.

[2026-07] [Part 2] [H9: FOXA1 subfamily-level + sequence + positional follow-ups]
FOXA1 at AluY/AluSc/AluJr4 (expected from bp fraction, observed from real peaks):
  AluY: ratio 0.52(pM)/0.54(nM) - closely matches ERalpha's own AluY depletion
    (0.40/0.42) - confirms AluY exclusion is FOXA1/pioneer-factor-inherited.
  AluSc: ratio 0.63(pM)/0.63(nM) - FOXA1 depletion present but WEAKER than
    ERalpha's own AluSc depletion (0.11/0.43) - suggests ERalpha adds
    additional exclusion at AluSc beyond what FOXA1 alone explains.
  AluJr4: ratio 0.85(pM)/0.92(nM) - near-neutral, FOXA1 does NOT show the
    enrichment ERalpha shows at nM (1.90x) - AluJr4 enrichment is
    ERalpha/GATA3-specific, not FOXA1-inherited.
Sequence composition: AluY GC=54.2%/CpGoe=0.595, AluSc GC=51.8%/CpGoe=0.431 -
both unremarkable relative to their own tier averages; AluSc's stronger
depletion is NOT explained by elevated CpG (it's lower than AluY's, yet
more depleted) - further weakens CpG as an explanation.
Chromosomal distribution: no dramatic single-chromosome hotspot for either
subfamily; mild chr19 skew noted but underpowered (AluSc bound n=20) to
treat as confident.
Distance-to-nearest-gene test: UNINFORMATIVE - median=0 for both bound
and unbound in both subfamilies, since most Alu copies are intronic
regardless of binding status. Wrong metric for the question; would need
intronic/intergenic classification or TSS-distance to be meaningful.
Not pursued further given time budget.

[2026-07] [Part 2] [H9 formalized: structured data + figures saved]
FOXA1-vs-ERalpha subfamily comparison and sequence composition data
written to h9_tf_subfamily_comparison.csv / h9_sequence_composition.csv,
figures generated (h9_tf_inheritance_by_subfamily, h9_sequence_composition).
This is the mechanistic centerpiece figure for the write-up: AluY exclusion
ratio nearly matches between ERalpha (0.40-0.42) and FOXA1 (0.52-0.54) -
FOXA1-inherited. AluJr4 enrichment is ERalpha-specific (ERalpha 0.46-1.90,
FOXA1 stays near-neutral 0.85-0.92) - NOT FOXA1-inherited. AluSc shows an
intermediate pattern - FOXA1 depletion present (0.63) but weaker than
ERalpha's own (0.11-0.43), suggesting ERalpha adds exclusion beyond what
FOXA1 alone accounts for.

[2026-07] [Part 2] [New extension scoped: strong/weak enhancer classification + Alu mapping]
Following completion of the H1-H9 mechanism-testing arc, scoping a new
extension using Kim et al. 2026's dose-resolved ATAC-seq (GSE298769),
H3K27ac ChIP-seq (part of GSE298767), and PRO-seq (GSE298770, availability
pending check) to classify strong vs. weak ERalpha-associated enhancers
across all 4 doses, then map Alu subfamily enrichment nearby using
existing infrastructure (alu_young/middle/old.bed, 49-subfamily set).
A third phase (nuclear speckle spatialization via Alu eRNA) was scoped
but tabled: no MCF-7-specific nuclear speckle proximity map (SON TSA-seq/
CUT&RUN) exists in public data - the one candidate paper found (Alexander
et al. 2025, Nat Cell Biol) ran genome-wide speckle assays in 786-O cells,
not MCF-7; its MCF-7 component was a HIF-2alpha overexpression RNA-seq
experiment, not a speckle map. Tabled pending either a real MCF-7 dataset
becoming available or a deliberate decision to use a cross-cell-line
proxy with explicit caveats.

[2026-07] [Part 2] [New extension scoped: strong/weak enhancer classification + Alu mapping]
Following completion of the H1-H9 mechanism-testing arc, scoping a new
extension using Kim et al. 2026's dose-resolved ATAC-seq (GSE298769),
H3K27ac ChIP-seq (part of GSE298767), and PRO-seq (GSE298770, availability
pending check) to classify strong vs. weak ERalpha-associated enhancers
across all 4 doses, then map Alu subfamily enrichment nearby using
existing infrastructure (alu_young/middle/old.bed, 49-subfamily set).
A third phase (nuclear speckle spatialization via Alu eRNA) was scoped
but tabled: no MCF-7-specific nuclear speckle proximity map (SON TSA-seq/
CUT&RUN) exists in public data - the one candidate paper found (Alexander
et al. 2025, Nat Cell Biol) ran genome-wide speckle assays in 786-O cells,
not MCF-7; its MCF-7 component was a HIF-2alpha overexpression RNA-seq
experiment, not a speckle map. Tabled pending either a real MCF-7 dataset
becoming available or a deliberate decision to use a cross-cell-line
proxy with explicit caveats.

[2026-07] [Part 2] [CORRECTION: 10nM standalone peak count was miscalculated]
The individual-dose 10nM peak count was reported as 13,118 in earlier
entries and figures. Re-verified: grep -cE "^chr..." (standard chromosomes)
= 13,129; grep -vcE (alt scaffolds) = 11. The correct standard-chromosome
count is 13,129 - the earlier 13,118 came from incorrectly subtracting
the 11 alt-scaffold peaks from what was already the filtered/standard
count, not from a file total. Corrected in dose_peak_counts.csv and
regenerated dose_response_peaks figure.
Scope of impact: narrow. This only affected the standalone dose-response
panel/figure. All H1/H2/H7/H8/H9 statistical results used the separately
and correctly computed nM_star_merged.bed total (13,142, from wc -l on
the actual merged file) - those are unaffected by this error.

[2026-07] [Part 2] [H10: enhancer strength x Alu tier, FDR-corrected]
Classified strong/weak ERalpha-associated enhancers per dose via composite
z-scored ATAC+H3K27ac+PROseq signal (terciles), then tested Alu tier
overlap (strong vs weak) via Fisher's exact, 9 tests (3 doses x 3 tiers,
10pM excluded - too few peaks, n=33/tier). BH-FDR applied across all 9.
RESULT: only 10nM/middle survives correction (OR=1.36, FDR=0.009,
Bonferroni=0.009 - robust). The 100pM/middle result that looked
suggestive pre-correction (raw p=0.022) does NOT survive (FDR=0.099) -
confirms this was likely a false positive from insufficient correction,
caught specifically because multiple-testing correction was checked
rather than assumed.
CONCLUSION: narrow but real extension of H1/H8 - enhancer strength has
a detectable relationship to Alu tier composition specifically at the
highest dose (10nM) and specifically for middle-tier (AluS-lineage) Alu,
not a broad cross-dose pattern. Young-tier (AluY) depletion itself shows
no strong/weak difference at any dose - consistent with H1's exclusion
being set at a stage upstream of, and independent from, how strong the
resulting enhancer becomes.

[2026-07] [Part 2] [H11 RESULT: FOXA1 motif rate explains FOXA1's own exclusion from AluY]
Scanned actual genomic instances of AluY (n=110,881), AluSc (n=36,338),
AluJr4 (n=20,966) for the FOXA1 motif (JASPAR MA0148.5), p<0.0001,
no saturation (rates well below ceiling, unlike earlier STAT1 miscalibration).
FOXA1 motif hit rate: AluY=0.058%, AluSc=0.132%, AluJr4=0.458% - monotonic,
matches the FOXA1 binding-depletion gradient from H7/H9 closely.
Fisher's exact, all highly significant: AluY vs AluJr4 OR=0.126 p<2.2e-16;
AluSc vs AluJr4 OR=0.288 p=3.9e-13; AluY vs AluSc OR=0.437 p=2.5e-5.
CONCLUSION: this closes the causal chain for the exclusion side of the
story. FOXA1 avoids AluY substantially because AluY has genuinely lost
the FOXA1 binding motif at a much higher rate than AluJr4, consistent
with normal sequence decay over evolutionary time acting specifically
on this regulatory motif (not just bulk GC/CpG content, which was
already ruled out as explanatory in H5/H9).
LIMIT: this explains depletion/avoidance, not ERalpha's positive
enrichment at AluJr4 (1.90x observed vs FOXA1's near-neutral 0.92x) -
that gap suggests an additional ERalpha/GATA3-specific mechanism beyond
FOXA1 motif availability, still unidentified. This is the final
mechanism-hunting result for Part 2; H11 + H7/H9 together form the
complete, evidence-based mechanistic account.

[2026-07] [Part 2] [H10 REVALIDATED: fixed methodology confirms and sharpens original finding]
Rebuilt H10 addressing 3 of 5 identified gaps: (1) log1p transform before
z-scoring (right-skewed signal), (2) PCA-derived composite instead of
unweighted average (PC1 explains 75.5-78.6% variance per dose - three
assays genuinely share one activity axis, validating the compositing
approach), (3) unified logistic regression (overlap ~ strength*alu_tier+dose,
n=14,337 peak-tier observations) replacing 9 patchwork Fisher tests + FDR.
Did NOT fix: independent enhancer boundary calling (would require new
peak calls from ATAC/H3K27ac/PROseq rather than reusing ERalpha peaks) -
flagged as a standing limitation, not resolved.
RESULT: confirms original finding on firmer ground. strength:middle-Alu
interaction significant (OR=1.54, CI[1.18,2.00], p=0.0014), now pooled
across all 3 doses rather than resting on one dose surviving correction.
strength:young-Alu interaction NOT significant (OR=1.19, CI crosses 1,
p=0.46) - confirms H1's core exclusion is strength-independent, on a
properly powered joint test rather than absence of signal in 3 separate
small tests. NEW finding invisible in the original approach: significant
dose main effect (10nM OR=1.53 vs 100pM, p<0.0001) - Alu overlap rate
rises with dose independent of enhancer strength.
Bidirectionality index (proseq_bidir) computed and saved in
enhancer_strength_classification_v2.csv for future eRNA-specific work,
not used in this analysis.

[2026-07] [Part 2] [H11 validation complete: composition-matched background reveals two-layer effect]
Dinucleotide-shuffled (composition-matched) background per subfamily:
AluY real=0.058% vs shuffled=2.91% (OR=0.02); AluSc real=0.138% vs
shuffled=3.25% (OR=0.04); AluJr4 real=0.520% vs shuffled=3.65% (OR=0.14).
All highly significant (p<3e-71 to 0). Threshold confirmed correctly
discriminating - not saturated, not the earlier genome-wide GC confound.
NEW INSIGHT: all three subfamilies (even AluJr4) show real << shuffled,
revealing a baseline structural suppression of the FOXA1 motif common to
Alu sequence generally (likely reflecting real Alu consensus structure,
not captured by dinucleotide composition alone) - separate from, and
layered under, the graded AluY<AluSc<AluJr4 age-dependent difference.
Precise conclusion going forward: Alu sequence generally suppresses
FOXA1 motif relative to composition-matched expectation; this
suppression is significantly stronger in younger subfamilies. The
AluY-vs-AluJr4 comparison (OR=0.111, length-filtered) remains the
primary causal claim and is unaffected by this validation.
H11 fully revalidated: length-truncation confound addressed (finding
unchanged), background threshold properly validated (composition-matched,
not genome-wide), both fixes complete.

[2026-07] [Part 2] [H11 validation complete: composition-matched background reveals two-layer effect]
Dinucleotide-shuffled (composition-matched) background per subfamily:
AluY real=0.058% vs shuffled=2.91% (OR=0.02); AluSc real=0.138% vs
shuffled=3.25% (OR=0.04); AluJr4 real=0.520% vs shuffled=3.65% (OR=0.14).
All highly significant (p<3e-71 to 0). Threshold confirmed correctly
discriminating - not saturated, not the earlier genome-wide GC confound.
NEW INSIGHT: all three subfamilies (even AluJr4) show real << shuffled,
revealing a baseline structural suppression of the FOXA1 motif common to
Alu sequence generally (likely reflecting real Alu consensus structure,
not captured by dinucleotide composition alone) - separate from, and
layered under, the graded AluY<AluSc<AluJr4 age-dependent difference.
Precise conclusion going forward: Alu sequence generally suppresses
FOXA1 motif relative to composition-matched expectation; this
suppression is significantly stronger in younger subfamilies. The
AluY-vs-AluJr4 comparison (OR=0.111, length-filtered) remains the
primary causal claim and is unaffected by this validation.
H11 fully revalidated: length-truncation confound addressed (finding
unchanged), background threshold properly validated (composition-matched,
not genome-wide), both fixes complete.

[2026-07] [Part 2] [H10 re-validated against original question: dose-specificity claim retracted]
Re-checked H10 directly against the original four-part research question
rather than the narrative that accumulated around it. Ran the full
three-way interaction model (overlap ~ strength*alu_tier*dose) to
formally test the "what dose activates the pathway" clause, which the
earlier pooled model (main effects only) could not address and which
the original since-abandoned per-dose Fisher approach had suggested
(10nM) without a proper test.
RESULT: ANOVA comparing pooled vs. three-way model: Deviance=9.67,
df=10, p=0.470. NOT significant - no evidence the strength:middle-Alu
relationship differs by dose. All individual three-way terms also
non-significant (best p=0.095, uncorrected).
CORRECTION: the impression that this effect is "10nM-specific" (from
simple per-dose point estimates: 100pM OR=2.23 p=0.074, 1nM OR=1.27
p=0.376, 10nM OR=1.57 p=0.0069) does NOT survive the formal interaction
test - this is a textbook case of one of three per-dose estimates
crossing p<0.05 by chance without the underlying difference between
doses being statistically supported. RETRACTING the dose-specific
framing used in figures/summaries to date.
Corrected conclusion: strength:middle-tier-Alu correlation is present
but dose-independent across the tested range (100pM-10nM) - "what dose
activates the pathway" has no defensible answer from this analysis.
Status of original 4-part research question: (1) strong/weak
classification - complete. (2) Alu correlation with strength - complete,
real effect confirmed (middle tier, pooled OR=1.54). (3) dose-specificity
- tested formally, NOT supported, retracted. (4) nuclear speckle spatial
validation - not attempted, no data available.

[2026-07] [Part 2] [H11 validation complete: composition-matched background reveals two-layer effect]
Dinucleotide-shuffled (composition-matched) background per subfamily:
AluY real=0.058% vs shuffled=2.91% (OR=0.02); AluSc real=0.138% vs
shuffled=3.25% (OR=0.04); AluJr4 real=0.520% vs shuffled=3.65% (OR=0.14).
All highly significant (p<3e-71 to 0). Threshold confirmed correctly
discriminating - not saturated, not the earlier genome-wide GC confound.
NEW INSIGHT: all three subfamilies (even AluJr4) show real << shuffled,
revealing a baseline structural suppression of the FOXA1 motif common to
Alu sequence generally (likely reflecting real Alu consensus structure,
not captured by dinucleotide composition alone) - separate from, and
layered under, the graded AluY<AluSc<AluJr4 age-dependent difference.
Precise conclusion going forward: Alu sequence generally suppresses
FOXA1 motif relative to composition-matched expectation; this
suppression is significantly stronger in younger subfamilies. The
AluY-vs-AluJr4 comparison (OR=0.111, length-filtered) remains the
primary causal claim and is unaffected by this validation.
H11 fully revalidated: length-truncation confound addressed (finding
unchanged), background threshold properly validated (composition-matched,
not genome-wide), both fixes complete.

[2026-07] [Part 2] [H10 re-validated against original question: dose-specificity claim retracted]
Re-checked H10 directly against the original four-part research question
rather than the narrative that accumulated around it. Ran the full
three-way interaction model (overlap ~ strength*alu_tier*dose) to
formally test the "what dose activates the pathway" clause, which the
earlier pooled model (main effects only) could not address and which
the original since-abandoned per-dose Fisher approach had suggested
(10nM) without a proper test.
RESULT: ANOVA comparing pooled vs. three-way model: Deviance=9.67,
df=10, p=0.470. NOT significant - no evidence the strength:middle-Alu
relationship differs by dose. All individual three-way terms also
non-significant (best p=0.095, uncorrected).
CORRECTION: the impression that this effect is "10nM-specific" (from
simple per-dose point estimates: 100pM OR=2.23 p=0.074, 1nM OR=1.27
p=0.376, 10nM OR=1.57 p=0.0069) does NOT survive the formal interaction
test - this is a textbook case of one of three per-dose estimates
crossing p<0.05 by chance without the underlying difference between
doses being statistically supported. RETRACTING the dose-specific
framing used in figures/summaries to date.
Corrected conclusion: strength:middle-tier-Alu correlation is present
but dose-independent across the tested range (100pM-10nM) - "what dose
activates the pathway" has no defensible answer from this analysis.
Status of original 4-part research question: (1) strong/weak
classification - complete. (2) Alu correlation with strength - complete,
real effect confirmed (middle tier, pooled OR=1.54). (3) dose-specificity
- tested formally, NOT supported, retracted. (4) nuclear speckle spatial
validation - not attempted, no data available.

[2026-07] [Part 2] [H12: Alu-eRNA bidirectionality test - real, dose-modulated, but diffuse effect]
Tested whether Alu-overlapping enhancer regions show bidirectional PRO-seq
signal (eRNA signature) differently than non-Alu regions, using the
proseq_bidir index computed during the H10 fix pass. n=21,500 classified
enhancer regions across 3 doses.
Raw per-dose Wilcoxon: significant only at 10nM (p=0.0001, FDR=0.00026);
null at 100pM/1nM (FDR=0.95 both) - same single-dose-significant shape
that proved to be a false pattern in H10's dose-specificity check, so
NOT trusted without the formal interaction test this time (lesson
applied from the H10 retraction).
Full 3-way model (proseq_bidir ~ has_alu*strength_tier*dose) vs. reduced
model: ANOVA F=8.54, p=4.7e-14 - UNLIKE H10, this formal test DOES
support dose-dependence. However the specific 3-way term matching the
raw per-dose pattern (has_alu:strong:dose10nM) is NOT significant
(p=0.21); the significant 3-way term is has_alu:strong:dose1nM (p=0.025,
one of many simultaneous terms, treated cautiously, uncorrected).
Real, robust 2-way effects: has_alu:strength_strong interaction is
negative and significant (est=-0.153, p=0.0066) - Alu overlap dampens
the bidirectionality boost seen in strong enhancers generally.
strength_strong:dose10nM is independently significant (est=0.067,
p=6.4e-06) - strong enhancers show elevated, dose-dependent bidirectional
signal regardless of Alu status.
CONCLUSION: there is a real, dose-modulated relationship between Alu
overlap and eRNA-like bidirectional transcription, but it is diffuse
across several interacting terms rather than isolated to one clean
dose x strength x Alu story. Do not report this as "Alu eRNA signal is
specific to dose X" - report as "Alu status significantly modulates
enhancer bidirectionality, and this relationship is dose-dependent
(formally tested), with the clearest single driver being reduced
Alu-associated bidirectionality specifically in strong enhancers."

[2026-07] [Part 2] [H10 validated: original composite score confirmed against true log-fold-enrichment]
Addressed the flagged gap that H10's composite score (PCA of raw z-scored
signal) never normalized against background/input, unlike proper ChIP-seq
practice. Computed true log10 fold-enrichment for H3K27ac specifically
(macs3 bdgcmp -m logFE -p 1, vs matched input per dose - ATAC/PROseq have
no deposited input in this dataset, so this correction is only possible
for H3K27ac).
RESULT: original composite score correlates strongly with true log10FE
(Spearman rho=0.81-0.83, all doses, n=21,500 peaks, essentially certain
p-values). Original strong/weak tier assignment shows a large, highly
significant separation in true log2FE (strong median ~12x enrichment,
weak median ~1.8x, p<1e-250 all doses).
CONCLUSION: the background-normalization gap flagged as a limitation was
real, but empirically confirmed NOT to have misled the strong/weak
classification underlying H10 and H12. Original results stand validated,
not just asserted. Limitation can now be described in the write-up as
"checked and confirmed non-material" rather than an open concern.

[2026-08] [Part 2] [New extension: independent H3K27ac peak calls, Step 1 complete]
Called H3K27ac peaks independently (MACS3 bdgcmp qpois -p1, bdgpeakcall
c=5) per dose, matched input, same calibration as FOXA1/GATA3. Real
counts, standard chromosomes only: 10pM=54,407, 100pM=52,497, 1nM=53,863,
10nM=56,066 - flat across doses, no dose gradient (unlike ERalpha's own
steep 99->13,118 climb). This is expected: H3K27ac marks broad active
chromatin, not exclusively ERalpha-driven activity, so dose-independence
here is biologically sensible rather than a red flag.
Next: intersect with real ERalpha peaks per dose to define Set A
(ERalpha + H3K27ac), independent of the reused-peak-boundary limitation
flagged earlier in H10.

[2026-08] [Part 2] [Step 2 bug caught: denominator mismatch, corrected]
Set A intersection script counted intersection numerator from alt-scaffold-
filtered peaks but denominator from unfiltered original files - off by
the alt-scaffold count per dose (11 at 10nM, confirmed exact match).
Corrected rates using proper filtered totals (99/2607/5764/13129):
10pM=75.8%, 100pM=54.9%, 1nM=51.7%, 10nM=41.1% ERalpha peaks confirmed
by independent H3K27ac.
FINDING: steep, monotonic decline in H3K27ac-confirmation rate with dose.
Validates the H10 "reused peak boundary" limitation empirically - a
substantial and growing fraction of nominal ERalpha peaks at high dose
lack independent active-enhancer evidence. Provides orthogonal support
for Kim et al.'s own pM (curated/functional) vs nM (pharmacological/
promiscuous) enhancer distinction.

[2026-08] [Part 2] [Set B defined: PROseq-confirmed subset of Set A, all doses]
Median bidirectionality split within Set A, per dose (not absolute
threshold - avoids arbitrary cutoff). All four doses split ~50/50 as
expected: 10pM 38/75, 100pM 716/1432, 1nM 1490/2978, 10nM 2701/5401.
Note: 10pM median bidir (0.150) is notably lower than 100pM/1nM/10nM
(0.277-0.297) - flagged as an observation only, not yet tested; small
n=75 at 10pM could explain instability as easily as a real dose effect.
Will test formally, not eyeball, when dose-dependence is examined.

[2026-08] [Part 2] [Bug: Set A/Set B column mismatch in nearest-Alu aggregation]
Set A files retained full 10-column narrowPeak format; Set B files
(script 13) were written with only 3 columns (chrom/start/end), an
inconsistency introduced when Set B was defined. bedtools closest output
therefore had different total column counts per set (17 vs 10), breaking
a script that assumed fixed absolute column positions. Fixed by indexing
relative to ncol() (Alu subfamily always ncol-3, distance always ncol)
rather than hardcoded positions - robust to either set's column width.

[2026-08] [Part 2] [New extension Step 4 result: Set B overlap difference is real-direction but not significant; young-Alu subfamily pattern does NOT replicate]
Formal test (10pM excluded due to complete separation, 0/38 events):
Set A vs Set B Alu-overlap difference: est=-0.149, p=0.41 - consistent
direction (Set B lower) across all 3 usable doses, but NOT statistically
significant at this sample size. Dose does not modulate the effect
(interaction p=0.93) - third independent confirmation of dose-independence
in this project (after H10, H12).
Subfamily-level test (n>=20 in Set A, FDR-corrected, Fisher's exact):
NOTHING survives FDR<0.05. Best case AluSz FDR=0.055 (middle-tier, not
young). AluY itself: FDR=0.661, not close to significant. The apparently
clean AluY-lineage depletion pattern seen in the raw uncorrected table
(driven by subfamilies with n=1-12) does NOT replicate once restricted
to adequately-powered subfamilies and corrected - same small-sample
instability pattern already documented in H8.
CONCLUSION: Set A vs Set B (txnal-activity-defined) shows a real-direction
but statistically inconclusive difference in Alu overlap; no specific
subfamily-level signal survives proper testing. This is a genuine null/
inconclusive result at current sample size, not a confirmed finding -
report accordingly. Larger n (e.g. pooling replicate enhancer definitions,
or lower-stringency Set B threshold) would be needed to resolve whether
the observed direction is real.

[2026-08] [Part 2] [PINTS numpy 2.0 incompatibility, patched]
pints_caller 1.2.1 failed on all 4 doses with ValueError in np.cross -
confirmed via numpy's own GitHub issue #26620 that 2D-vector support in
np.cross was deprecated in NumPy 2.0 and is now a hard error. Not a data
or command issue - PINTS predates this numpy change. Patched
pints/stats_engine.py get_elbow() directly (replaced np.cross with the
explicit 2D scalar cross-product formula, numpy-version-independent)
rather than downgrading numpy in the shared macs3 venv, which also runs
MACS3 peak calling used throughout the entire project.
