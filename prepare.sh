#!/bin/bash
# Croc benchmark preparation
set -euo pipefail

# 1. Source the environment
source env.sh

# 2. Synthesis (using their established script)
echo "[INFO] Running Yosys synthesis..."
cd yosys
./run_synthesis.sh --synth
cd ..

# 3. Preparation (OpenROAD Flow)
echo "[INFO] Running OpenROAD floorplan and preparation..."

# We must run these from the 'openroad/' directory to match the 
# relative paths used in the TCL scripts (like 'source scripts/startup.tcl')
cd openroad

# Stage 01: Floorplan
openroad -exit scripts/01_floorplan.tcl -log logs/01_floorplan.log

# Note: For alex_gpl parameter sweep, it uses the 02_prepare_placement_with_gradpass.tcl 
# to save time on repeating the first global placement.
# But for upstream, the full 02_placement.tcl does everything starting from the floorplan.
# We run the prepare stage here so it's ready for the alex_gpl run.
openroad -exit scripts/02_prepare_placement_with_gradpass.tcl -log logs/02_prepare_placement.log

echo "[INFO] Benchmark preparation complete."
