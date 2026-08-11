"""
Generates an IGV session XML bundling every signal track and annotation
BED from the whole project, grouped logically by assay and dose.
"""
import os

BASE = os.path.expanduser("~/alu_brca/part2_dose_switch")
RAW = f"{BASE}/data/raw"
RESULTS = f"{BASE}/results/macs_real"
REPEATMASKER = os.path.expanduser("~/data/files/repeatmasker")

tracks = []

# Signal tracks (bigwig) - ER/FOXA1/GATA3/H3K27ac/ATAC/PRO-seq, per dose
for dose in ["Veh", "10pM", "100pM", "1nM", "10nM"]:
    for prefix, factor in [
        (f"{RAW}/GSE298767_ER_{dose}.bw", "ERalpha"),
    ]:
        if os.path.exists(prefix):
            tracks.append((prefix, f"ERa_{dose}", "0,100,150"))

for dose in ["pM", "nM"]:
    for factor, color in [("FOXA1", "150,150,150"), ("GATA3", "230,126,34")]:
        p = f"{RAW}/GSE298767_{factor}_{dose}_R1_R2.bw"
        if os.path.exists(p):
            tracks.append((p, f"{factor}_{dose}", color))

for dose in ["100pM", "1nM", "10nM"]:
    p = f"{RAW}/enhancer_signal/GSE298767_E2dose_{dose}_H3K27ac_merge.bw"
    if os.path.exists(p):
        tracks.append((p, f"H3K27ac_{dose}", "0,150,0"))
    p = f"{RAW}/enhancer_signal/GSE298769_E2_{dose}_merged.bw"
    if os.path.exists(p):
        tracks.append((p, f"ATAC_{dose}", "128,0,128"))
    for strand in ["plus", "minus"]:
        p = f"{RAW}/enhancer_signal/GSE298770_MCF7_E2dosage_{dose}_finalmerge.finalSORTED.{strand}{'_flipped' if strand=='minus' else ''}.bw"
        if os.path.exists(p):
            tracks.append((p, f"PROseq_{dose}_{strand}", "200,0,0"))

# Peak / annotation BEDs
peak_files = {
    "ERa_10pM_peaks": f"{RESULTS}/ER_10pM_v2_real_peaks.narrowPeak",
    "ERa_100pM_peaks": f"{RESULTS}/ER_100pM_real_peaks.narrowPeak",
    "ERa_1nM_peaks": f"{RESULTS}/ER_1nM_real_peaks.narrowPeak",
    "ERa_10nM_peaks": f"{RESULTS}/ER_10nM_real_peaks.narrowPeak",
    "Strong_enhancers_10nM": f"{RESULTS}/strong_enhancers_10nM_v2.bed",
    "Weak_enhancers_10nM": f"{RESULTS}/weak_enhancers_10nM_v2.bed",
}
for name, path in peak_files.items():
    if os.path.exists(path):
        tracks.append((path, name, "50,50,50"))

# Alu subfamily annotation tracks
alu_files = {
    "Alu_young": f"{REPEATMASKER}/alu_young.bed",
    "Alu_middle": f"{REPEATMASKER}/alu_middle.bed",
    "Alu_old": f"{REPEATMASKER}/alu_old.bed",
    "AluY": f"{REPEATMASKER}/AluY_only.bed",
    "AluSc": f"{REPEATMASKER}/AluSc_only.bed",
    "AluJr4": f"{REPEATMASKER}/AluJr4_only.bed",
}
for name, path in alu_files.items():
    if os.path.exists(path):
        tracks.append((path, name, "180,180,0"))

missing = [t for t in tracks if not os.path.exists(t[0])]
found = [t for t in tracks if os.path.exists(t[0])]

xml_lines = ['<?xml version="1.0" encoding="UTF-8" standalone="no"?>',
             '<Session genome="hg38" locus="All" version="8">',
             '    <Resources>']
for path, name, color in found:
    xml_lines.append(f'        <Resource path="{path}" name="{name}" color="{color}" />')
xml_lines += ['    </Resources>', '</Session>']

out_path = f"{BASE}/igv/alu_brca_part2_session.xml"
with open(out_path, "w") as f:
    f.write("\n".join(xml_lines))

print(f"Session written: {out_path}")
print(f"Tracks included: {len(found)}")
if missing:
    print(f"\nSkipped (file not found, check paths): {len(missing)}")
    for m in missing[:10]:
        print(f"  {m[1]}: {m[0]}")

# --- Newer tracks added after initial script version ---
extra_tracks = []

h3k27ac_peaks = {
    "H3K27ac_10pM_peaks": f"{RESULTS}/H3K27ac_10pM_real_peaks.narrowPeak",
    "H3K27ac_100pM_peaks": f"{RESULTS}/H3K27ac_100pM_real_peaks.narrowPeak",
    "H3K27ac_1nM_peaks": f"{RESULTS}/H3K27ac_1nM_real_peaks.narrowPeak",
    "H3K27ac_10nM_peaks": f"{RESULTS}/H3K27ac_10nM_real_peaks.narrowPeak",
}
for name, path in h3k27ac_peaks.items():
    extra_tracks.append((path, name, "0,150,0"))

for dose in ["10pM", "100pM", "1nM", "10nM"]:
    extra_tracks.append((f"{RESULTS}/SetA_ER_H3K27ac_{dose}.bed", f"SetA_{dose}", "0,100,150"))
    extra_tracks.append((f"{RESULTS}/SetB_ER_H3K27ac_PROseq_{dose}.bed", f"SetB_{dose}", "200,0,150"))

PINTS_DIR = f"{BASE}/results/pints_peaks"
for dose in ["10pM", "100pM", "1nM", "10nM"]:
    for kind, color in [("bidirectional", "200,0,0"), ("divergent", "150,0,150")]:
        extra_tracks.append((f"{PINTS_DIR}/PROseq_{dose}_1_{kind}_peaks.bed", f"PINTS_{kind}_{dose}", color))

extra_found = [t for t in extra_tracks if os.path.exists(t[0])]
extra_missing = [t for t in extra_tracks if not os.path.exists(t[0])]

print(f"\n--- Newer tracks ---")
print(f"Additional tracks found: {len(extra_found)}")
if extra_missing:
    print(f"Additional tracks missing: {len(extra_missing)}")
    for m in extra_missing:
        print(f"  {m[1]}: {m[0]}")

all_found = found + extra_found
xml_lines = ['<?xml version="1.0" encoding="UTF-8" standalone="no"?>',
             '<Session genome="hg38" locus="All" version="8">',
             '    <Resources>']
for path, name, color in all_found:
    xml_lines.append(f'        <Resource path="{path}" name="{name}" color="{color}" />')
xml_lines += ['    </Resources>', '</Session>']

with open(out_path, "w") as f:
    f.write("\n".join(xml_lines))
print(f"\nSession rewritten with {len(all_found)} total tracks: {out_path}")
