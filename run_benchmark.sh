#!/bin/bash
# benchmarks/croc/run_benchmark.sh
# This script is designed to be run INSIDE the Apptainer container, 
# from the temporary workspace directory where the benchmark was copied.

OUTPUT_DIR=$1
PLACEMENT_SCRIPT=$2

set -e

# Redirect stdout and stderr to both the log file and the shell using tee
exec > >(tee "$OUTPUT_DIR/run.log") 2>&1

echo "[INFO] Starting run in croc benchmark"
echo "[INFO] Workspace: $(pwd)"
echo "[INFO] Output directory: $OUTPUT_DIR"

if [ -f "/workspace/openroad.env" ]; then
    echo "[INFO] Environment variables loaded:"
    cat /workspace/openroad.env
fi

# We assume we are in the benchmark root
cd openroad

echo "[INFO] Running Placement ($PLACEMENT_SCRIPT)..."
# Use offscreen platform for GUI
export QT_QPA_PLATFORM=offscreen
openroad -gui -exit "$PLACEMENT_SCRIPT"

echo "[INFO] Running Report extraction..."
openroad -exit scripts/reports.tcl

echo "[INFO] Copying reports to output directory..."
cp -r reports/* "$OUTPUT_DIR/" 2>/dev/null || true
cp -r save "$OUTPUT_DIR/" 2>/dev/null || true

echo "[INFO] Croc benchmark run completed successfully."
