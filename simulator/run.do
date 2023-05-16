# Check if harness module is used
set if_harness_present 0
set slurp_file [open "$proj_root_dir/do/modules.tcl" r]
while {-1 != [gets $slurp_file line]} {
    set filepath [string range $line 0 end]
    if { [string first "harness" $filepath] != -1} {
        set if_harness_present 1
    }
}
close $slurp_file


# Before runing the test, save current wave.do config
# write format wave $tb_top_dir_abspath/wave.do

# Stop any ongoing simulation
# if {[runStatus] != "nodesign"} {
#   quit -sim
# }

# Set variables for the simulation project
variable run_time "-all"

# Recompile Out of Date
# if {$lib_sim_vhdl eq "work"} {
#     if {$lib_src_vhdl eq "work"} {
#         project compileoutofdate
#     }
# }


source ${proj_root_dir}/do/compile_all.tcl
write format wave $tb_top_dir_abspath/wave.do


# Run Testbench
if {$file_lang eq "sv"} {
    if { [string first "_tb." ${file_name}] != -1} {
        vsim -onfinish stop work.${file_name}_tb
        puts "TCL: Running Testbench ${file_name}_tb.$file_lang"
    } else {
        vsim -onfinish stop work.${file_name}
        puts "TCL: Running Testbench ${file_name}.$file_lang"
    }
} elseif {$file_lang eq "v"} {
    if { [string first "_tb." ${file_name}] != -1} {
        vsim -onfinish stop work.${file_name}_tb
        puts "TCL: Running Testbench ${file_name}_tb.$file_lang"
    } else {
        vsim -onfinish stop work.${file_name}
        puts "TCL: Running Testbench ${file_name}.$file_lang"
    }
} elseif {$file_lang eq "vhd"} {
    if { [string first "_tb." ${file_name}] != -1} {
        vsim -onfinish stop $lib_sim_vhdl.${file_name}_tb
        puts "TCL: Running Testbench ${file_name}_tb.$file_lang"
    } else {
        vsim -onfinish stop $lib_sim_vhdl.${file_name}
        puts "TCL: Running Testbench ${file_name}.$file_lang"
    }
} else {
    puts "TCL: ERROR: File type $file_lang is not supported."
}

do $tb_top_dir_abspath/wave.do

# Log, run
# if {$if_harness_present == 0} {
#     puts "TCL: Harness module is not used."
#     log sim:/*
# } else {
#     puts "TCL: Harness module is used."
#     add wave sim:/signals_${dut_name}_pack_tb/*
#     # log sim:/signals_pack_tb/*
# }
run $run_time

# Some commands do not work in batch mode, then consider using this:
write format wave $tb_top_dir_abspath/wave.do

# Save output data of the simulation into a list and wave formats
file mkdir "$tb_top_dir_abspath/sim_reports"

# if {$if_harness_present == 0} {
#     # If harness module is not used
#     add list sim:/*
# } else {
#     # If harness module is used
#     add wave sim:/signals_${dut_name}_pack_tb/*
#     # add list sim:/signals_pack_tb/*
# }

write report $tb_top_dir_abspath/sim_reports/sim_report.txt
# write list $tb_top_dir_abspath/sim_reports/sim_list.lst