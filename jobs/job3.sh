#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")/../"

PY_SETUP="jobs/setup_pyenv.sh"
MAIN="src/main.sh"
MAX_ORDER=7

bash "$PY_SETUP"
source ~/.venv_313/bin/activate

for ((k = 1; k <= MAX_ORDER; k++)); do
	log="data/output/job3/orders1to${MAX_ORDER}_k${k}_oneneg.log"
	instr="$k;-1,1"
	bash "$MAIN" "$log" "$MAX_ORDER" "$instr"
done
