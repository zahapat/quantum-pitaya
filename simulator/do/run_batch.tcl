# Set variables for the simulation project
variable run_time "-all"

# Open project
set required_proj_file "$proj_root_dir/simulator/project.mpf"
if {![file exist "$required_file"]} {
    puts "TCL: Opening existing project: ./project.mpf"
    exit
} else {
    puts "TCL: Simulation is running in non-project mode."
}

# Find wave.do file in the top tb module dir
set tb_top_abspath [string range [lindex $all_modules 0] 0 end]
set tb_top_dir_abspath [file dirname "[file normalize $tb_top_abspath]"]

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

# List all instances in the tb file
set all_instances_tb [find instances sim:/${file_name}_tb/*]
puts "TCL: all_instances_tb = $all_instances_tb"

run $run_time
quit