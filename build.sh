#!/usr/bin/env bash
# Builds the mapper 210 (Namco 175) .rbf for the EverDrive N8 Pro.
#
# Krikzz's framework (base_sv, pin assignments) is fetched at a pinned commit rather than
# copied into this repo. The project is generated from his 001 mapper pack, with that pack's
# mappers swapped for ours.
#
# Usage: fpga/build.sh            (needs git and quartus_sh on PATH)
set -euo pipefail

EDN8_REPO=https://github.com/krikzz/edn8-pro-pub.git
EDN8_COMMIT=317f8caf8d2b917a260e94ec14d5edbbbfced8ba

HERE="$(cd "$(dirname "$0")" && pwd)"
WORK="$HERE/build"
SDK="$WORK/edn8-pro-pub"
PROJ="$SDK/fpga/210"

if [ ! -d "$SDK/.git" ]; then
	mkdir -p "$WORK"
	git clone "$EDN8_REPO" "$SDK"
fi
git -C "$SDK" checkout --quiet "$EDN8_COMMIT"

rm -rf "$PROJ"
mkdir -p "$PROJ"
cp "$HERE"/src/*.sv "$PROJ/"
cp "$SDK/fpga/001/top.qpf" "$SDK/fpga/001/top_assignment_defaults.qdf" "$PROJ/"

# Same settings and pins as pack 001, minus its mapper files, plus ours.
grep -v -E 'SYSTEMVERILOG_FILE map_[0-9a-z_]+\.sv' "$SDK/fpga/001/top.qsf" > "$PROJ/top.qsf"
for f in "$HERE"/src/*.sv; do
	echo "set_global_assignment -name SYSTEMVERILOG_FILE $(basename "$f")" >> "$PROJ/top.qsf"
done

(cd "$PROJ" && quartus_sh --flow compile top)

mkdir -p "$HERE/out"
cp "$PROJ/output_files/top.rbf" "$HERE/out/splatterworld.rbf"
echo "Built $HERE/out/splatterworld.rbf"
