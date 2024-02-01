# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
    set origin_dir $::origin_dir_loc
}


# Get TCL Command-line arguments
puts "TCL: Get TCL Command-line arguments"
set arguments_cnt 2
if { $::argc == $arguments_cnt } {

    # Library src files
    set lib_src_vhdl [string trim [lindex $::argv 0] ]
    set lib_src_vhdl [string tolower $lib_src_vhdl]
    puts "TCL: Argument 1 lowercase: '$lib_src_vhdl'"

    # Library sim files
    set lib_sim_vhdl [string trim [lindex $::argv 1] ]
    set lib_sim_vhdl [string tolower $lib_sim_vhdl]
    puts "TCL: Argument 2 lowercase: '$lib_sim_vhdl'"

} else {
    puts "TCL: ERROR: There must be $arguments_cnt Command-line argument(s) passed to the TCL script. Total arguments found: $::argc"
    return 1
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

# Remove all the following libraries and mappings
if {[file exist "[file normalize ${origin_dir}]/simulator/work"]} {
    exec vdel -all -lib ${origin_dir}/simulator/work
    puts "TCL: Library 'work' deleted."
}
if {[file exist "[file normalize ${origin_dir}]/simulator/$lib_src_vhdl"]} {
    exec vdel -all -lib ${origin_dir}/simulator/$lib_src_vhdl
    puts "TCL: Library '$lib_src_vhdl' deleted."
}
if {[file exist "[file normalize ${origin_dir}]/simulator/$lib_sim_vhdl"]} {
    exec vdel -all -lib ${origin_dir}/simulator/$lib_sim_vhdl
    puts "TCL: Library '$lib_sim_vhdl' deleted."
}

# Remove simulator project files, preserve simulator.ini and transctipt
set files_simulator [glob -nocomplain -type f [file normalize ${origin_dir}]/simulator/*]
set required_rundo_file "[file normalize ${origin_dir}]/simulator/run.do"
set required_newdo_file "[file normalize ${origin_dir}]/simulator/new.do"
set required_functions_directory "[file normalize ${origin_dir}]/simulator/do"
if {[llength $files_simulator] == 0} {
    puts "TCL: CRITICAL WARNING: Folder ./simulator is empty -> file run.do is not present in the dir ${origin_dir}/simulator/ . Copy the file to this directory for correct operation of this project environment."
}
if {[llength $files_simulator] != 0} {
    foreach del_file $files_simulator {
        if {$del_file ne "$required_rundo_file"} {
            if {$del_file ne "$required_newdo_file"} {
                if {$del_file ne "$required_functions_directory"} {
                    puts "TCL: Deleting file from the 'simulator' folder: $del_file"
                    file delete $del_file
                }
            }
        }
    }
}

# Remove everything in the .Xil folder!
set files_xil [glob -nocomplain -type f [file normalize ${origin_dir}]/.Xil/*]
if {[llength $files_xil] != 0} {
    foreach del_file $files_xil {
        puts "TCL: Deleting file from the '.Xil' folder: $del_file"
        file delete $del_file
    }
}

# Remove modules.tcl temp file
set del_file "[file normalize ${origin_dir}]/do/modules.tcl"
if {[file exist "$del_file"]} {
    file delete $del_file
    puts "TCL: Deleting modules.tcl file from the 'do' folder: $del_file"
}

# Remove transcript temp file
set del_file "[file normalize ${origin_dir}]/transcript"
if {[file exist "$del_file"]} {
    file delete $del_file
    puts "TCL: Deleting file from the 'root' folder: $del_file"
}

# Remove dump temp file
set del_file "[file normalize ${origin_dir}]/dump.vcd"
if {[file exist "$del_file"]} {
    file delete $del_file
    puts "TCL: Deleting file from the 'root' folder: $del_file"
}

# Remove vsim.wlf temp file
set del_file "[file normalize ${origin_dir}]/vsim.wlf"
if {[file exist "$del_file"]} {
    file delete $del_file
    puts "TCL: Deleting file from the 'root' folder: $del_file"
}

# Close project
puts "TCL: Running $script_file for project $_xil_proj_name_ COMPLETED SUCCESSFULLY. "
return 0