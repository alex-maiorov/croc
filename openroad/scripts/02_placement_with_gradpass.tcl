# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

# Stage 02: Placement with gradpass (Global Placement 2 + Detailed Placement)
#
# This stage performs:
# - Actual global placement (routability and timing driven with gradpass arguments)
# - Detailed placement (legalization)
#
# Required environment variables:
#   PROJ_NAME    - Project name (e.g., "croc")
#   TOP_DESIGN   - Top module name
#
# Input checkpoint: 02-02_${PROJ_NAME}.gpl1_repaired
# Output checkpoint: 02_${PROJ_NAME}.placed

###############################################################################
# Setup
###############################################################################
source scripts/startup.tcl

# Load checkpoint from prepare stage
load_checkpoint 02-02_${proj_name}.gpl1_repaired

# Set layers used for estimate_parasitics
setDefaultParasitics
set_dont_use $dont_use_cells

utl::report "###############################################################################"
utl::report "# Stage 02: PLACEMENT WITH GRADPASS"
utl::report "###############################################################################"

set_thread_count 8

# Density
set placement_density 0.60
if { [info exists env(OPENROAD_PLACEMENT_DENSITY)] } {
    set placement_density $env(OPENROAD_PLACEMENT_DENSITY)
    utl::report "Using placement density from environment: $placement_density"
}

# Routability overflow
set placement_overflow 0.1
if { [info exists env(OPENROAD_PLACEMENT_OVERFLOW)] } {
    set placement_overflow $env(OPENROAD_PLACEMENT_OVERFLOW)
}

# Timing Gradpass Variables Setup
set timing_gradpass_enable 1
if { [info exists env(OPENROAD_TIMING_GRADPASS_ENABLE)] } {
    set timing_gradpass_enable $env(OPENROAD_TIMING_GRADPASS_ENABLE)
}

set timing_gradpass_top_n 10
if { [info exists env(OPENROAD_TIMING_GRADPASS_TOP_N)] } {
    set timing_gradpass_top_n $env(OPENROAD_TIMING_GRADPASS_TOP_N)
}

set timing_gradpass_n_paths_per_endpoint 1
if { [info exists env(OPENROAD_TIMING_GRADPASS_N_PATHS_PER_ENDPOINT)] } {
    set timing_gradpass_n_paths_per_endpoint $env(OPENROAD_TIMING_GRADPASS_N_PATHS_PER_ENDPOINT)
}

set timing_gradpass_proj_weight 1e-3
if { [info exists env(OPENROAD_TIMING_GRADPASS_PROJ_WEIGHT)] } {
    set timing_gradpass_proj_weight $env(OPENROAD_TIMING_GRADPASS_PROJ_WEIGHT)
}

set timing_gradpass_end_to_end_weight 1e-7
if { [info exists env(OPENROAD_TIMING_GRADPASS_END_TO_END_WEIGHT)] } {
    set timing_gradpass_end_to_end_weight $env(OPENROAD_TIMING_GRADPASS_END_TO_END_WEIGHT)
}

set timing_gradpass_slack_sharpness 1.0
if { [info exists env(OPENROAD_TIMING_GRADPASS_SLACK_SHARPNESS)] } {
    set timing_gradpass_slack_sharpness $env(OPENROAD_TIMING_GRADPASS_SLACK_SHARPNESS)
}

set timing_gradpass_slack_offset 0.0
if { [info exists env(OPENROAD_TIMING_GRADPASS_SLACK_OFFSET)] } {
    set timing_gradpass_slack_offset $env(OPENROAD_TIMING_GRADPASS_SLACK_OFFSET)
}

set timing_gradpass_slack_upper 0.0
if { [info exists env(OPENROAD_TIMING_GRADPASS_SLACK_UPPER)] } {
    set timing_gradpass_slack_upper $env(OPENROAD_TIMING_GRADPASS_SLACK_UPPER)
}

set timing_gradpass_slack_clamp 1e32
if { [info exists env(OPENROAD_TIMING_GRADPASS_SLACK_CLAMP)] } {
    set timing_gradpass_slack_clamp $env(OPENROAD_TIMING_GRADPASS_SLACK_CLAMP)
}

set timing_gradpass_slack_slope 1e10
if { [info exists env(OPENROAD_TIMING_GRADPASS_SLACK_SLOPE)] } {
    set timing_gradpass_slack_slope $env(OPENROAD_TIMING_GRADPASS_SLACK_SLOPE)
}

set timing_gradpass_sta_run_interval 10
if { [info exists env(OPENROAD_TIMING_GRADPASS_STA_RUN_INTERVAL)] } {
    set timing_gradpass_sta_run_interval $env(OPENROAD_TIMING_GRADPASS_STA_RUN_INTERVAL)
}

set timing_gradpass_first_iter 0
if { [info exists env(OPENROAD_TIMING_GRADPASS_FIRST_ITER)] } {
    set timing_gradpass_first_iter $env(OPENROAD_TIMING_GRADPASS_FIRST_ITER)
}

set timing_gradpass_saturation_kl 3.0
if { [info exists env(OPENROAD_TIMING_GRADPASS_SATURATION_KL)] } {
    set timing_gradpass_saturation_kl $env(OPENROAD_TIMING_GRADPASS_SATURATION_KL)
}

set timing_gradpass_saturation_minl 1000.0
if { [info exists env(OPENROAD_TIMING_GRADPASS_SATURATION_MINL)] } {
    set timing_gradpass_saturation_minl $env(OPENROAD_TIMING_GRADPASS_SATURATION_MINL)
}

set timing_gradpass_precond_count_weight 0.1
if { [info exists env(OPENROAD_TIMING_GRADPASS_PRECOND_COUNT_WEIGHT)] } {
    set timing_gradpass_precond_count_weight $env(OPENROAD_TIMING_GRADPASS_PRECOND_COUNT_WEIGHT)
}

set timing_gradpass_blend 0.3
if { [info exists env(OPENROAD_TIMING_GRADPASS_BLEND)] } {
    set timing_gradpass_blend $env(OPENROAD_TIMING_GRADPASS_BLEND)
}

# Routability Gradpass Variables Setup
set routability_gradpass_enable 1
if { [info exists env(OPENROAD_ROUTABILITY_GRADPASS_ENABLE)] } {
    set routability_gradpass_enable $env(OPENROAD_ROUTABILITY_GRADPASS_ENABLE)
}

set routability_gradpass_sharpness 1.0
if { [info exists env(OPENROAD_ROUTABILITY_GRADPASS_SHARPNESS)] } {
    set routability_gradpass_sharpness $env(OPENROAD_ROUTABILITY_GRADPASS_SHARPNESS)
}

set routability_gradpass_slope 1.0
if { [info exists env(OPENROAD_ROUTABILITY_GRADPASS_SLOPE)] } {
    set routability_gradpass_slope $env(OPENROAD_ROUTABILITY_GRADPASS_SLOPE)
}

set routability_gradpass_clamp 10.0
if { [info exists env(OPENROAD_ROUTABILITY_GRADPASS_CLAMP)] } {
    set routability_gradpass_clamp $env(OPENROAD_ROUTABILITY_GRADPASS_CLAMP)
}

set routability_gradpass_offset 0.3
if { [info exists env(OPENROAD_ROUTABILITY_GRADPASS_OFFSET)] } {
    set routability_gradpass_offset $env(OPENROAD_ROUTABILITY_GRADPASS_OFFSET)
}

set routability_gradpass_precond_weight 0.1
if { [info exists env(OPENROAD_ROUTABILITY_GRADPASS_PRECOND_WEIGHT)] } {
    set routability_gradpass_precond_weight $env(OPENROAD_ROUTABILITY_GRADPASS_PRECOND_WEIGHT)
}

set routability_gradpass_range 100000
if { [info exists env(OPENROAD_ROUTABILITY_GRADPASS_RANGE)] } {
    set routability_gradpass_range $env(OPENROAD_ROUTABILITY_GRADPASS_RANGE)
}

set routability_gradpass_first_iter 0
if { [info exists env(OPENROAD_ROUTABILITY_GRADPASS_FIRST_ITER)] } {
    set routability_gradpass_first_iter $env(OPENROAD_ROUTABILITY_GRADPASS_FIRST_ITER)
}

set routability_gradpass_run_interval 10
if { [info exists env(OPENROAD_ROUTABILITY_GRADPASS_RUN_INTERVAL)] } {
    set routability_gradpass_run_interval $env(OPENROAD_ROUTABILITY_GRADPASS_RUN_INTERVAL)
}

utl::report "Global Placement (2)"

utl::set_db_log_global_max_mem [expr 1 * 1024 * 1024]
# utl::start_log_db "reports/placement.sqlite"

set gpl_args [list -density $placement_density -overflow $placement_overflow]

if { $timing_gradpass_enable } {
    lappend gpl_args -timing_driven
    lappend gpl_args -timing_gradpass_top_n $timing_gradpass_top_n \
                     -timing_gradpass_n_paths_per_endpoint $timing_gradpass_n_paths_per_endpoint \
                     -timing_gradpass_proj_weight $timing_gradpass_proj_weight \
                     -timing_gradpass_end_to_end_weight $timing_gradpass_end_to_end_weight \
                     -timing_gradpass_slack_sharpness $timing_gradpass_slack_sharpness \
                     -timing_gradpass_slack_offset $timing_gradpass_slack_offset \
                     -timing_gradpass_slack_upper $timing_gradpass_slack_upper \
                     -timing_gradpass_slack_clamp $timing_gradpass_slack_clamp \
                     -timing_gradpass_slack_slope $timing_gradpass_slack_slope \
                     -timing_gradpass_sta_run_interval $timing_gradpass_sta_run_interval \
                     -timing_gradpass_first_iter $timing_gradpass_first_iter \
                     -timing_gradpass_saturation_kl $timing_gradpass_saturation_kl \
                     -timing_gradpass_saturation_minl $timing_gradpass_saturation_minl \
                     -timing_gradpass_precond_count_weight $timing_gradpass_precond_count_weight \
                     -timing_gradpass_blend $timing_gradpass_blend
}

if { $routability_gradpass_enable } {
    lappend gpl_args -routability_driven \
                     -routability_gradpass_sharpness $routability_gradpass_sharpness \
                     -routability_gradpass_slope $routability_gradpass_slope \
                     -routability_gradpass_clamp $routability_gradpass_clamp \
                     -routability_gradpass_offset $routability_gradpass_offset \
                     -routability_gradpass_precond_weight $routability_gradpass_precond_weight \
                     -routability_gradpass_range $routability_gradpass_range \
                     -routability_gradpass_first_iter $routability_gradpass_first_iter \
                     -routability_gradpass_run_interval $routability_gradpass_run_interval
}

if { [info exists env(OPENROAD_ROUTABILITY_GRADPASS_USE_GRT)] && $env(OPENROAD_ROUTABILITY_GRADPASS_USE_GRT) == 1 } {
    lappend gpl_args -routability_gradpass_use_grt
}

puts "DEBUG: gpl_args is $gpl_args"

global_placement {*}$gpl_args

utl::stop_log_db


utl::report "###############################################################################"
utl::report "# 02-03: Detailed Placement"
utl::report "###############################################################################"

# Legalize overlapping cells
utl::report "Detailed placement"
detailed_placement

utl::report "Optimize mirroring"
optimize_mirroring

utl::report "Estimate parasitics"
estimate_parasitics -placement

report_metrics "02_${proj_name}.placed"
save_checkpoint 02_${proj_name}.placed
report_image "02_${proj_name}.placed" true true

utl::report "###############################################################################"
utl::report "# Stage 02 complete: Checkpoint saved to ${save_dir}/02_${proj_name}.placed.zip"
utl::report "###############################################################################"
