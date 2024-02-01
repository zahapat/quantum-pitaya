proc remove_string_sequence {str sequence} {
    set result [string map {$sequence ""} $str]
    return $result
}

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
    puts "TCL: ERROR: There must be $arguments_cnt Command-line argument/s passed to the TCL script. Total arguments found:  $::argc . Quit."
    quit
}


# Prerequisite for simulation: file ./dimulator/modules.tcl is present
# Remove modules.tcl temp file
set required_file "$proj_root_dir/simulator/modules.tcl"
if {![file exist "$required_file"]} {
    puts "TCL: ERROR: Missing required file: ./simulator/modules.tcl. Solution: Run \"\$ make src\" to generate it. Quit."
    quit
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


# Load all modules into a list
list all_modules {}
set slurp_file [open "$proj_root_dir/simulator/modules.tcl" r]
while {-1 != [gets $slurp_file line]} {
    set filepath [string map {" " ""} ${line}]
    if {$filepath eq ""} {
        puts "TCL: Ignoring invalid line."
    } else {
        lappend all_modules "$filepath"
    }
}
close $slurp_file
puts "TCL: all_modules = $all_modules"


# Compile Xilinx UNISIM libraries and VCOMPONENTS package
source "$proj_root_dir/simulator/do/compile_unisim.tcl"


# Sort the files to repsective libraries based on the compile order in the file modules.tcl
set pass_to_launch_sim 1

if {[batch_mode]} {
    puts "TCL: Launching simulation in Batch"

    # Compile and proceed to launch sim if no errors occurred
    if {[ catch {
        source ${proj_root_dir}/simulator/do/compile_all.tcl
    } errorstring]} {
        set pass_to_launch_sim 0
        puts "TCL: The following error was generated while compiling sources: $errorstring . Quit."
        quit
    }
} else {
    puts "TCL: Launching simulation in GUI"

    # Compile and proceed to launch sim if no errors occurred
    if {[ catch {
        source ${proj_root_dir}/simulator/do/compile_all.tcl
    } errorstring]} {
        set pass_to_launch_sim 0
        puts "TCL: The following error was generated while compiling sources: $errorstring . Quit."
        return 0
    }
}


# Launch simulation
if {$pass_to_launch_sim == 1} {
    if {[batch_mode]} {
        source "$proj_root_dir/simulator/do/run_batch.tcl"
        quit
    } else {
        source "$proj_root_dir/simulator/do/run_gui.tcl"
    }
}