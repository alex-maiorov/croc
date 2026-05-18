# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

# Stage 02: Prepare Placement (Repair Netlist + Global Placement 1)
#
# This stage performs:
# - Initial repair of the netlist (tie cells, buffers)
# - First Global placement (rough) and setup repair
#
# Required environment variables:
#   PROJ_NAME    - Project name (e.g., "croc")
#   TOP_DESIGN   - Top module name
#
# Input checkpoint: 01_${PROJ_NAME}.floorplan
# Output checkpoint: 02-02_${PROJ_NAME}.gpl1_repaired

###############################################################################
# Setup
###############################################################################
source scripts/startup.tcl

# Load checkpoint from previous stage
load_checkpoint 01_${proj_name}.floorplan

# Set layers used for estimate_parasitics
setDefaultParasitics
set_dont_use $dont_use_cells


utl::report "###############################################################################"
utl::report "# Stage 02: PREPARE PLACEMENT"
utl::report "###############################################################################"

utl::report "###############################################################################"
utl::report "# 02-01: Initial Repair Netlist"
utl::report "###############################################################################"

# Don't touch clock-tree related nets as repair_timing can insert buffers
# which then prevents CTS from running
set clock_nets [get_nets -of_objects [get_pins -of_objects "*_reg" -filter "name == CLK"]]
set_dont_touch $clock_nets

utl::report "Repair tie fanout"
repair_tie_fanout $tieHiPin 
repair_tie_fanout $tieLoPin 

utl::report "Remove buffers"
remove_buffers

utl::report "Repair design"
repair_design -verbose

save_checkpoint 02-01_${proj_name}.pre_place


utl::report "###############################################################################"
utl::report "# 02-02: Global Placement (1) and Setup Repair"
utl::report "###############################################################################"

set_thread_count 8

# Read density from environment variable or use default
set placement_density 0.60
if { [info exists env(OPENROAD_PLACEMENT_DENSITY)] } {
    set placement_density $env(OPENROAD_PLACEMENT_DENSITY)
    utl::report "Using placement density from environment: $placement_density"
}

# Rough placement to get parasitics from steiner-tree estimate so we can run repair_timing
utl::report "Global Placement (1)"
global_placement -density $placement_density
report_metrics "02-02_${proj_name}.gpl1"
report_image "02-02_${proj_name}.gpl1" true true
save_checkpoint 02-02_${proj_name}.gpl1

utl::report "Estimate parasitics"
estimate_parasitics -placement
utl::report "Repair design"
repair_design -verbose
save_checkpoint 02-02_${proj_name}.gpl1_fix

utl::report "Repair setup"
repair_timing -setup -verbose
save_checkpoint 02-02_${proj_name}.gpl1_repaired

utl::report "###############################################################################"
utl::report "# Stage 02 prepare complete: Checkpoint saved to ${save_dir}/02-02_${proj_name}.gpl1_repaired.zip"
utl::report "###############################################################################"
