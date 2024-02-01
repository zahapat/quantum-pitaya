proc string_delimiters_to_list {str delimiter} {
    set cnt 0
    set list_append {}
    set str_i [string range [lindex [split $str "$delimiter"] $cnt] 0 end]
    while {$str_i ne ""} {
        lappend list_append $str_i
        incr cnt
        set str_i [string range [lindex [split $str "$delimiter"] $cnt] 0 end]
    }
    return $list_append
}

# Filter all irrelevant keywords from the commandline and leave only arguments
# DO NOT TOUCH
puts "TCL: Get TCL Command-line argument/s"
set correct_arg_num 1
if [batch_mode] {
    set correct_arg_num 2
}
set argline [string trim [lindex $::argv $correct_arg_num] ]
set argline [string range [lindex [split $argline " "] 2] 0 end]
puts "TCL: argline = $argline"

# Get all TCL Command-line arguments
set delimiter ","
set list_all_args [string_delimiters_to_list $argline $delimiter]
set arg_count [llength $list_all_args]

set arguments_cnt 3
if { $arg_count == $arguments_cnt } {

    # Library for VHDL src files
    set lib_src_vhdl [string trim [lindex $list_all_args 0] ]
    set lib_src_vhdl [string tolower $lib_src_vhdl]
    puts "TCL: Argument 1 lib_src_vhdl: '$lib_src_vhdl'"

    # Library for VHDL sim files
    set lib_sim_vhdl [string trim [lindex $list_all_args 1] ]
    set lib_sim_vhdl [string tolower $lib_sim_vhdl]
    puts "TCL: Argument 2 lib_sim_vhdl: '$lib_sim_vhdl'"

    # Project root directory
    set proj_root_dir [string trim [lindex $list_all_args 2] ]
    puts "TCL: Argument 2 lib_sim_vhdl: '$lib_sim_vhdl'"
    puts "TCL: proj_root_dir = $proj_root_dir"

} else {
    puts "TCL: ERROR: There must be $arguments_cnt Command-line argument/s passed to the TCL script. Total arguments found:  $::argc"
    return 1
}


# Remove all the following libraries and mappings
if {[file exist "$proj_root_dir/simulator/work"]} {
    # vmap -del work
    vdel -all -lib $proj_root_dir/simulator/work
    puts "TCL: Library 'work' deleted."
}
if {[file exist "$proj_root_dir/simulator/$lib_src_vhdl"]} {
    # vmap -del $lib_src_vhdl
    vdel -all -lib $proj_root_dir/simulator/$lib_src_vhdl
    puts "TCL: Library '$lib_src_vhdl' deleted."
}
if {[file exist "$proj_root_dir/simulator/$lib_sim_vhdl"]} {
    # vmap -del $lib_sim_vhdl
    vdel -all -lib $proj_root_dir/simulator/$lib_sim_vhdl
    puts "TCL: Library '$lib_sim_vhdl' deleted."
}

# Remove simulator project files, preserve simulator.ini and transctipt
set files_simulator [glob -nocomplain -type f [file normalize ${proj_root_dir}]/simulator/*]
set required_rundo_file "[file normalize ${proj_root_dir}]/simulator/run.do"
set required_newdo_file "[file normalize ${proj_root_dir}]/simulator/new.do"
set required_functions_directory "[file normalize ${proj_root_dir}]/simulator/do"
if {[llength $files_simulator] == 0} {
    puts "TCL: CRITICAL WARNING: Folder ./simulator is empty -> files run.do and new.do are not present in the dir ${proj_root_dir}/simulator/ . Copy these files into this directory for the correct operation of the project environment."
}
if {[llength $files_simulator] != 0} {
    foreach del_file $files_simulator {
        if {$del_file ne "$required_rundo_file"} {
            if {$del_file ne "$required_newdo_file"} {
                if {$del_file ne "$required_functions_directory"} {
                    puts "TCL: Deleting file from the 'simulator' folder: $del_file"
                    if {[ catch {
                        file delete $del_file
                    } errorstring]} {
                        puts "TCL: The following error was generated: $errorstring - Skip."
                    }
                }
            }
        }
    }
}


# Close project
puts "TCL: Running make_sim_clean.tcl COMPLETED SUCCESSFULLY. "
quit