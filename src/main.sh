#!/bin/bash

set -euo pipefail

if [ "$#" -ne 3 ]; then
	echo >&2 "Usage: $0 <log_file> <max_order> <instructions>"
	exit 1
fi

PROJ_DIR="$(dirname "$0")/../"
SRC="data/input/small_graph_s_bandwidths.db"
MIN_ORDER=1
TBL_NAME="con_graphs_1to11"
ORDER_COL="num_vertices"
G6_COL="graph6"
BAND_COL="band_01neg"
KEY_FMT="n%d"

LOG="$1"
MAX_ORDER="$2"
INSTR="$3"

if [ -f "$LOG" ]; then
	echo >&2 "Log file already exists: '$LOG'"
	exit 1
fi

mkdir -p "$(dirname "$LOG")"

if [ "$INSTR" == "special_wh" ]; then
	K="$MAX_ORDER"
else
	K="${INSTR%%;*}"
fi

PY_TMP_MAT="$(mktemp).mat"
JL_TMP_MAT="$(mktemp).mat"
trap 'rm -f "$PY_TMP_MAT" "$JL_TMP_MAT"' EXIT

python src/main_pt1.py "$SRC" "$PY_TMP_MAT" "$MIN_ORDER" "$MAX_ORDER" "$K" \
	"$TBL_NAME" "$ORDER_COL" "$G6_COL" "$BAND_COL" "$KEY_FMT"
julia --project="$PROJ_DIR" -e 'using Pkg; Pkg.instantiate()'
julia --project="$PROJ_DIR" src/main_pt2.jl "$JL_TMP_MAT" "$MIN_ORDER" "$MAX_ORDER" \
	"$INSTR" "$KEY_FMT"
matlab -batch "addpath('src'); \
	main_pt3('$PY_TMP_MAT', '$JL_TMP_MAT', '$LOG', $MIN_ORDER, $MAX_ORDER, '$KEY_FMT')"
