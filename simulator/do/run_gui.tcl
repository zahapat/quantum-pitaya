# Set variables for the simulation project
variable run_time "-all"

# NEW
set tb_top_abspath [string range [lindex $all_modules 0] 0 end]
set filepath_correction [concat ${proj_root_dir} ${tb_top_abspath}]
set filepath_correction [string map {" " ""} $filepath_correction]
set tb_top_dir_abspath [string map {"./" "/"} $filepath_correction]
set tb_top_dir_abspath [file dirname "[file normalize $tb_top_dir_abspath]"]


# Check if harness module is used
set if_harness_present 0
set slurp_file [open "$proj_root_dir/simulator/modules.tcl" r]
while {-1 != [gets $slurp_file line]} {
    set filepath [string range $line 0 end]
    if { [string first "harness" $filepath] != -1} {
        set if_harness_present 1
    }
}
close $slurp_file

# Run Testbench
puts "TCL: RUN TESTBENCH: Top = ${file_name}.${file_lang}"
if {($file_lang eq "sv") || ($file_lang eq "svh")} {
    if { [string first "_tb." ${file_name}] != -1} {

        if {[ catch {
            vsim -lib $proj_root_dir/simulator/work -onfinish stop -L unisim_verilog work.glbl work.${file_name}_tb
        } errorstring]} {
            puts "TCL: The following error was generated: $errorstring - Attempting to refresh the library image."
            # Refresh the library image & launch sim
            vlog -work $proj_root_dir/simulator/work -refresh
            vcom -work $proj_root_dir/simulator/$lib_src_vhdl -refresh
            vcom -work $proj_root_dir/simulator/$lib_sim_vhdl -refresh
            vsim -lib $proj_root_dir/simulator/work -onfinish stop -L unisim_verilog work.glbl work.${file_name}_tb
        }

    } else {

        if {[ catch {
            vsim -lib $proj_root_dir/simulator/work -onfinish stop -L unisim_verilog work.glbl work.${file_name}
        } errorstring]} {
            puts "TCL: The following error was generated: $errorstring - Attempting to refresh the library image."
            # Refresh the library image & launch sim
            vlog -work $proj_root_dir/simulator/work -refresh
            vcom -work $proj_root_dir/simulator/$lib_src_vhdl -refresh
            vcom -work $proj_root_dir/simulator/$lib_sim_vhdl -refresh
            vsim -lib $proj_root_dir/simulator/work -onfinish stop -L unisim_verilog work.glbl work.${file_name}
        }
    }
} elseif {($file_lang eq "v") || ($file_lang eq "vh")} {
    if { [string first "_tb." ${file_name}] != -1} {
        if {[ catch {
            vsim -lib $proj_root_dir/simulator/work -onfinish stop -L unisim_verilog work.glbl work.${file_name}_tb
        } errorstring]} {
            puts "TCL: The following error was generated: $errorstring - Attempting to refresh the library image."
            # Refresh the library image & launch sim
            vlog -work $proj_root_dir/simulator/work -refresh
            vcom -work $proj_root_dir/simulator/$lib_src_vhdl -refresh
            vcom -work $proj_root_dir/simulator/$lib_sim_vhdl -refresh
            vsim -lib $proj_root_dir/simulator/work -onfinish stop -L unisim_verilog work.glbl work.${file_name}_tb
        }
    } else {
        if {[ catch {
            vsim -lib $proj_root_dir/simulator/work -onfinish stop -L unisim_verilog work.glbl work.${file_name}
        } errorstring]} {
            puts "TCL: The following error was generated: $errorstring - Attempting to refresh the library image."
            # Refresh the library image & launch sim
            vlog -work $proj_root_dir/simulator/work -refresh
            vcom -work $proj_root_dir/simulator/$lib_src_vhdl -refresh
            vcom -work $proj_root_dir/simulator/$lib_sim_vhdl -refresh
            vsim -lib $proj_root_dir/simulator/work -onfinish stop -L unisim_verilog work.glbl work.${file_name}
        }
    }
} elseif {$file_lang eq "vhd"} {
    if { [string first "_tb." ${file_name}] != -1} {
        if {[ catch {
            vsim -lib $lib_sim_vhdl -onfinish stop $lib_sim_vhdl.${file_name}_tb
        } errorstring]} {
            puts "TCL: The following error was generated: $errorstring - Attempting to refresh the library image."
            # Refresh the library image & launch sim
            vlog -work $proj_root_dir/simulator/work -refresh
            vcom -work $proj_root_dir/simulator/$lib_src_vhdl -refresh
            vcom -work $proj_root_dir/simulator/$lib_sim_vhdl -refresh
            vsim -lib $proj_root_dir/simulator/$lib_sim_vhdl -onfinish stop $lib_sim_vhdl.${file_name}_tb
        }
    } else {
        if {[ catch {
            vsim -lib $proj_root_dir/simulator/$lib_src_vhdl -onfinish stop $lib_src_vhdl.${file_name}
        } errorstring]} {
            puts "TCL: The following error was generated: $errorstring - Attempting to refresh the library image."
            # Refresh the library image & launch sim
            vlog -work $proj_root_dir/simulator/work -refresh
            vcom -work $proj_root_dir/simulator/$lib_src_vhdl -refresh
            vcom -work $proj_root_dir/simulator/$lib_sim_vhdl -refresh
            vsim -lib $proj_root_dir/simulator/$lib_src_vhdl -onfinish stop $lib_src_vhdl.${file_name}
        }
    }
} else {
    puts "TCL: ERROR: File type $file_lang is not supported."
    return 0
}

# Find wave.do file in the top tb module dir
puts "TCL: DEBUG: tb_top_dir_abspath = $tb_top_dir_abspath"
if {[file exists "$tb_top_dir_abspath/wave.do"]} {
    puts "TCL: DEBUG: Loading module-specific 'wave.do' file: $tb_top_dir_abspath/wave.do"
    do $tb_top_dir_abspath/wave.do
} else {
    puts "TCL: DEBUG: 'wave.do' couldn't be loaded as the module path does not exist: $tb_top_dir_abspath/wave.do"
    # List all instances in the tb file
    if {$if_harness_present == 0} {
        set all_instances_tb [find instances sim:/${file_name}/*]
        puts "TCL: all_instances_tb = $all_instances_tb"
    } else {
        set all_instances_tb [find instances sim:/${file_name}/inst_harness_tb/*]
        puts "TCL: find instances sim:/${file_name}/inst_harness_tb/*"
        puts "TCL: all_instances_tb = $all_instances_tb"
    }

    # Load default view for waveforms
    source "$proj_root_dir/simulator/do/default_wave.tcl"
}

run $run_time

# Zoom Fit the waveform
wave zoom full

# Some commands do not work in batch mode, then consider using this:
write format wave $tb_top_dir_abspath/wave.do

# Save output data of the simulation into a list and wave formats
file mkdir "$tb_top_dir_abspath/sim_reports"

write report $tb_top_dir_abspath/sim_reports/sim_report.txt