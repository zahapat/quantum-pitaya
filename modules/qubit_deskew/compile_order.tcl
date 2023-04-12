set this_file_name "[file tail [info script]]"
set relpath_to_module ".[string range [file normalize [file dirname [info script]]] [string length [file normalize ${origin_dir}]] end]"
puts "TCL: Adding sources of: $relpath_to_module"
set simulator_comporder_path "${origin_dir}/do/modules.tcl"
set simulator_comporder [open ${simulator_comporder_path} "a"]
set vivado_added_hdl_report_path "${origin_dir}/vivado/0_report_added_modules.rpt"
set vivado_added_hdl_report [open $vivado_added_hdl_report_path "a"]
set vivado_added_scripts_report_path "${origin_dir}/vivado/0_report_added_xdc.rpt"
set vivado_added_scripts_report [open $vivado_added_scripts_report_path "a"]

# -------------------------------------------------------
# 1.0) Add SRC Package Files
# -------------------------------------------------------
#    * Vivado
#    * ModelSim


# -------------------------------------------------------
# 1.1) Add SRC HDL Files
# -------------------------------------------------------
#    * Vivado
set srcfile_added_or_not [add_files -fileset "sources_1" -norecurse {\
    ./modules/qubit_deskew/hdl/qubit_deskew.vhd\
}]

if {$srcfile_added_or_not ne ""} {
    set_property library lib_src [get_files {\
        ./modules/qubit_deskew/hdl/qubit_deskew.vhd\
    }]
    puts -nonewline $vivado_added_hdl_report "\
        ./modules/qubit_deskew/hdl/qubit_deskew.vhd\n"
    update_compile_order -fileset sources_1

    #    * ModelSim
    puts -nonewline $simulator_comporder "\
        ./modules/qubit_deskew/hdl/qubit_deskew.vhd\n"
}


# -------------------------------------------------------
# 2.0) Add TB Package Files
# -------------------------------------------------------
#    * ModelSim


# -------------------------------------------------------
# 2.1) Add TB Files
# -------------------------------------------------------
#    * ModelSim
if {$srcfile_added_or_not ne ""} {
    puts -nonewline $simulator_comporder "\
        ./modules/qubit_deskew/sim/qubit_deskew_tb.vhd\n"
}



# -------------------------------------------------------
# 3.0) Add XDC/TCL Files
# -------------------------------------------------------
# DO NOT TOUCH
# Search for xdc/tcl foles up to 2 levels of hierarchy
# Search for all .xdc sources associated with this module
if {$srcfile_added_or_not ne ""} {
    set foundFiles [glob -nocomplain -type f \
        ${relpath_to_module}/*{.xdc} \
        ${relpath_to_module}/*/*{.xdc} \
    ]
    if {[llength $foundFiles] > 0} {
        foreach file_path $foundFiles {
            add_files -norecurse -fileset "constrs_1" "$file_path"
            puts -nonewline $vivado_added_scripts_report "$file_path\n"
        }
    }

    # Search for all .tcl sources associated with this module
    set foundFiles [glob -nocomplain -type f \
        ${relpath_to_module}/*{.tcl} \
        ${relpath_to_module}/*/*{.tcl} \
    ]
    if {[llength $foundFiles] > 0} {
        foreach file_path $foundFiles {
            if { [string first $this_file_name $file_path] == -1} {
                source $file_path
                puts -nonewline $vivado_added_scripts_report "$file_path\n"
            }
        }
    }
}


close $simulator_comporder
close $vivado_added_hdl_report
close $vivado_added_scripts_report