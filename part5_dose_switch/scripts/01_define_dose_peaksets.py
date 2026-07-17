"""
Splits the full ERα ChIP-seq peak set (all E2 doses: 1pM,10pM,100pM,1nM,10nM,100nM)
into pM-responsive and nM-responsive groups, following Kim et al. 2026 Fig 2A logic:
a peak is assigned to the lowest dose at which it is first called significant by MACS,
then binned into pM (1-100pM) or nM (1nM-100nM) aggregate groups.

Input: per-dose MACS peak BED files (from step 00/01 fetch)
Output: pM_responsive_peaks.bed, nM_responsive_peaks.bed
"""
import pybedtools

DOSES_PM = ["1pM", "10pM", "100pM"]
DOSES_NM = ["1nM", "10nM", "100nM"]

def first_appearance(dose_order, peak_dir):
    seen = pybedtools.BedTool()
    first_dose_peaks = {d: [] for d in dose_order}
    for dose in dose_order:
        bed = pybedtools.BedTool(f"{peak_dir}/{dose}_peaks.narrowPeak")
        new_peaks = bed if len(seen) == 0 else bed.intersect(seen, v=True)
        first_dose_peaks[dose] = new_peaks
        seen = seen.cat(bed, postmerge=True) if len(seen) else bed
    return first_dose_peaks

if __name__ == "__main__":
    peak_dir = "../data/processed/macs_peaks"
    all_doses = DOSES_PM + DOSES_NM
    first_appear = first_appearance(all_doses, peak_dir)

    pm_peaks = pybedtools.BedTool().cat(*[first_appear[d] for d in DOSES_PM], postmerge=True)
    nm_peaks = pybedtools.BedTool().cat(*[first_appear[d] for d in DOSES_NM], postmerge=True)

    pm_peaks.saveas("../data/processed/pM_responsive_peaks.bed")
    nm_peaks.saveas("../data/processed/nM_responsive_peaks.bed")
    print(f"pM-responsive: {len(pm_peaks)} peaks")
    print(f"nM-responsive: {len(nm_peaks)} peaks")
