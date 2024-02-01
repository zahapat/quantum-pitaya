# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
    set origin_dir $::origin_dir_loc
}


# Set the project name
set _xil_proj_name_ [file tail [file dirname "[file normalize ./Makefile]"]]

# Use project name variable, if specified in the tcl shell
if { [info exists ::user_project_name] } {
    set _xil_proj_name_ $::user_project_name
}

variable script_file
set script_file "[file tail [info script]]"
puts "TCL: Running $script_file for project $_xil_proj_name_."

# Set the directory path for the original project from where this script was exported
set orig_proj_dir "[file normalize "$origin_dir/"]"

# Open the project
close_project -quiet
open_project "${origin_dir}/vivado/${_xil_proj_name_}.xpr"

# Run Generate Bitstream
set constrs [get_files -of_objects [get_filesets constrs_1]]
puts "TCL: constrs = $constrs"
if {$constrs eq ""} {
    puts "TCL: ERROR: Unable to run bitstream. There are no constraint files present in the project."
    quit
} else {
    # Run Generate Bitstream
    open_run impl_1
    set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
    write_bitstream -verbose    -force "${origin_dir}/vivado/3_bitstream_$_xil_proj_name_.bit"

    if {[catch {\
        write_hw_platform -fixed -include_bit -force -file "${origin_dir}/vivado/3_hw_platform_$_xil_proj_name_.xsa"\
    } error_msg]} {
        puts "TCL: Unable to generate Hardware Platform for Vitis. The project does not contain modules for Vitis project."
    } else {
        puts "TCL: Generating Hardware Platform for Vitis."
    }
}

# Get verbose reports about config affecting timing analysis
# report_config_timing -all -file "${origin_dir}/vivado/report_config_timing.rpt"

# Close project and print success
puts "TCL: Running $script_file for project $_xil_proj_name_ COMPLETED SUCCESSFULLY. "
close_project