import subprocess
import numpy as np
import matplotlib.pyplot as plt
import csv

CHROM = "chr11"
START, END = 16793810, 16799810
BIN_SIZE = 50
DOSES = ["10pM", "100pM", "1nM", "10nM"]
# Maps each individual dose to its FOXA1/GATA3 pooled group -
# CONFIRM this mapping is still correct before trusting the output
FOXA1_GATA3_GROUP = {"10pM": "pM", "100pM": "pM", "1nM": "pM", "10nM": "nM"}
LOW_CONFIDENCE_DOSES = {"10pM"}
BASE = "/home/yq139/alu_brca/part2_dose_switch/data/raw"

params = {}
with open("/home/yq139/alu_brca/part2_dose_switch/results/composite_standardization_params.csv") as f:
    for row in csv.DictReader(f):
        params[row["dose"]] = {k: float(v) for k, v in row.items() if k != "dose"}

def get_binned_signal(bw_path, chrom, start, end, bin_size):
    bg = subprocess.run(
        ["bigWigToBedGraph", bw_path, "/dev/stdout", f"-chrom={chrom}", f"-start={start}", f"-end={end}"],
        capture_output=True, text=True
    ).stdout
    n_bins = (end - start) // bin_size
    bins = np.zeros(n_bins)
    for line in bg.strip().split("\n"):
        if not line: continue
        c, s, e, v = line.split("\t")
        s, e, v = int(s), int(e), float(v)
        b0, b1 = max(0, (s - start) // bin_size), min(n_bins, (e - start) // bin_size + 1)
        for b in range(b0, b1):
            bins[b] = v
    return bins

def alu_track(ax):
    alu_bed = subprocess.run(
        ["bash", "-c", f"awk -F'\\t' '$1==\"{CHROM}\" && $3>={START} && $2<={END}' ~/data/files/repeatmasker/hg38_alu_elements.bed"],
        capture_output=True, text=True
    ).stdout
    for line in alu_bed.strip().split("\n"):
        if not line: continue
        parts = line.split("\t")
        s, e, name = int(parts[1]), int(parts[2]), parts[3]
        ax.barh(0, e - s, left=s, height=0.6, color="#C0392B")
        ax.text((s + e) / 2, 0.55, name, fontsize=7, ha="center")
    ax.set_ylim(-0.5, 1)
    ax.set_yticks([])
    ax.set_xlabel(f"{CHROM}:{START:,}-{END:,}")

x = np.linspace(START, END, (END - START) // BIN_SIZE)

for dose in DOSES:
    group = FOXA1_GATA3_GROUP[dose]

    atac = get_binned_signal(f"{BASE}/enhancer_signal/GSE298769_E2_{dose}_merged.bw", CHROM, START, END, BIN_SIZE)
    h3k27ac = get_binned_signal(f"{BASE}/enhancer_signal/GSE298767_E2dose_{dose}_H3K27ac_merge.bw", CHROM, START, END, BIN_SIZE)
    pro_plus = get_binned_signal(f"{BASE}/GSE298770_MCF7_E2dosage_{dose}_finalmerge.finalSORTED.plus.bw", CHROM, START, END, BIN_SIZE)
    pro_minus = get_binned_signal(f"{BASE}/GSE298770_MCF7_E2dosage_{dose}_finalmerge.finalSORTED.minus_flipped.bw", CHROM, START, END, BIN_SIZE)
    proseq = np.abs(pro_plus) + np.abs(pro_minus)
    p = params[dose]
    atac_z = (np.log1p(np.clip(atac, 0, None)) - p["atac_mean"]) / p["atac_sd"]
    h3k27ac_z = (np.log1p(np.clip(h3k27ac, 0, None)) - p["h3k27ac_mean"]) / p["h3k27ac_sd"]
    proseq_z = (np.log1p(np.clip(proseq, 0, None)) - p["proseq_mean"]) / p["proseq_sd"]
    composite = (atac_z + h3k27ac_z + proseq_z) / 3

    foxa1 = get_binned_signal(f"{BASE}/GSE298767_FOXA1_{group}_R1_R2.bw", CHROM, START, END, BIN_SIZE)
    gata3 = get_binned_signal(f"{BASE}/GSE298767_GATA3_{group}_R1_R2.bw", CHROM, START, END, BIN_SIZE)

    fig, axes = plt.subplots(4, 1, figsize=(10, 7), gridspec_kw={"height_ratios": [1, 1, 1, 0.4]}, sharex=True)

    axes[0].fill_between(x, composite, 0, color="#2E86AB", alpha=0.85)
    axes[0].axhline(0, color="#888", linewidth=0.5)
    label = f"Composite (n=99, lower conf.)" if dose in LOW_CONFIDENCE_DOSES else "Composite enhancer score"
    axes[0].set_ylabel(label, fontsize=9, rotation=0, ha="right", va="center")

    axes[1].fill_between(x, foxa1, color="#7F8C8D")
    axes[1].set_ylabel(f"FOXA1 ({group}-pooled)", fontsize=9, rotation=0, ha="right", va="center")

    axes[2].fill_between(x, gata3, color="#E67E22")
    axes[2].set_ylabel(f"GATA3 ({group}-pooled)", fontsize=9, rotation=0, ha="right", va="center")

    alu_track(axes[3])

    fig.suptitle(f"{dose}: composite enhancer signal, FOXA1, GATA3, Alu positions", fontsize=12)
    fig.tight_layout()
    fig.savefig(f"/home/yq139/track_{dose}.png", dpi=300, bbox_inches="tight")
    print(f"saved track_{dose}.png")
