#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")/../"

PY_SETUP="jobs/setup_pyenv.sh"
MAIN="src/main.sh"
MAX_ORDER=8

LOG="data/output/job1/orders1to${MAX_ORDER}_special_wh.log"
INSTR="special_wh"

bash "$PY_SETUP"
source ~/.venv_313/bin/activate

bash "$MAIN" "$LOG" "$MAX_ORDER" "$INSTR"
