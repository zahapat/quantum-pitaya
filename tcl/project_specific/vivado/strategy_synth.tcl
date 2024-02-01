# Uncomment if in trouble
set_property STEPS.SYNTH_DESIGN.ARGS.RETIMING true [get_runs synth_1]

# set_property STEPS.SYNTH_DESIGN.ARGS.NO_SRLEXTRACT true [get_runs synth_1]

# set_property strategy {Vivado Synthesis Defaults} [get_runs synth_1]
# set_property strategy Flow_AreaOptimized_high [get_runs synth_1]
# set_property strategy Flow_AreaOptimized_medium [get_runs synth_1]
# set_property strategy Flow_AreaMultThresholdDSP [get_runs synth_1]
set_property strategy Flow_AlternateRoutability [get_runs synth_1]

# Uncomment if in trouble
# set_property strategy Flow_PerfOptimized_high [get_runs synth_1]

# set_property strategy Flow_PerfThresholdCarry [get_runs synth_1]
# set_property strategy Flow_RuntimeOptimized [get_runs synth_1]