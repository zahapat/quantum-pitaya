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

# Set variables for the simulation project
variable run_time "-all"


if {[ catch {
    source ${proj_root_dir}/simulator/do/compile_all.tcl
} errorstring]} {
    puts "TCL: The following error was generated while compiling sources: $errorstring - Stop."
    return 0
}
write format wave $tb_top_dir_abspath/wave.do


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

do $tb_top_dir_abspath/wave.do

# Log, run
run $run_time

# Some commands do not work in batch mode, then consider using this:
write format wave $tb_top_dir_abspath/wave.do

# Save output data of the simulation into a list and wave formats
file mkdir "$tb_top_dir_abspath/sim_reports"

write report $tb_top_dir_abspath/sim_reports/sim_report.txt