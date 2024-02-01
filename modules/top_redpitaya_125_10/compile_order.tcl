set this_file_name "[file tail [info script]]"
set relpath_to_module ".[string range [file normalize [file dirname [info script]]] [string length [file normalize ${origin_dir}]] end]"
set simulator_comporder_path "${origin_dir}/simulator/modules.tcl"
set vivado_added_hdl_report_path "${origin_dir}/vivado/0_report_added_modules.rpt"
set vivado_added_scripts_report_path "${origin_dir}/vivado/0_report_added_xdc.rpt"
close [open $simulator_comporder_path a]
close [open $vivado_added_hdl_report_path a]
close [open $vivado_added_scripts_report_path a]

set this_module_compiled 0
set file_content [read [set FH [open ${vivado_added_hdl_report_path} r]]]
close $FH
foreach line_file $file_content {
    if { [string first $relpath_to_module $line_file] != -1} {
        set this_module_compiled 1
        break
    }
}


if {$this_module_compiled eq 0} {
    puts "TCL: Adding sources of: $relpath_to_module"
    set simulator_comporder [open ${simulator_comporder_path} "a"]
    set vivado_added_hdl_report [open $vivado_added_hdl_report_path "a"]
    set vivado_added_scripts_report [open $vivado_added_scripts_report_path "a"]



    # -------------------------------------------------------
    # 2.0) Add TB Package Files
    # -------------------------------------------------------
    #    * ModelSim


    # -------------------------------------------------------
    # 2.1) Add TB Files
    # -------------------------------------------------------
    #    * ModelSim
    puts -nonewline $simulator_comporder "\
        ./modules/top_redpitaya_125_10/sim/top_redpitaya_125_10_tb.sv\n"



    # -------------------------------------------------------
    # 1.1) Add SRC HDL Files
    # -------------------------------------------------------
    #    * Vivado
    add_files -fileset "sources_1" -norecurse {\
        ./modules/top_redpitaya_125_10/hdl/top_redpitaya_125_10_wrapper.vhd\
        ./modules/axi4lite_fifo_readout/hdl/axi4lite_fifo_readout.vhd\
        ./modules/top_redpitaya_125_10/hdl/generics.vhd\
        ./modules/top_redpitaya_125_10/hdl/top_redpitaya_125_10.sv\
    }
    # set_property library "lib_src" [get_files {\
    #     ./modules/top_redpitaya_125_10/hdl/top_redpitaya_125_10.sv\
    #     ./modules/top_redpitaya_125_10/hdl/top_redpitaya_125_10_wrapper.vhd\
    # }]
    puts -nonewline $vivado_added_hdl_report "\
        ./modules/top_redpitaya_125_10/hdl/top_redpitaya_125_10_wrapper.vhd\n
        ./modules/axi4lite_fifo_readout/hdl/axi4lite_fifo_readout.vhd\n
        ./modules/top_redpitaya_125_10/hdl/generics.vhd\n
        ./modules/top_redpitaya_125_10/hdl/top_redpitaya_125_10.sv\n"
    update_compile_order -fileset sources_1

    #    * ModelSim
    puts -nonewline $simulator_comporder "\
        ./modules/top_redpitaya_125_10/hdl/top_redpitaya_125_10_wrapper.vhd\n
        ./modules/axi4lite_fifo_readout/hdl/axi4lite_fifo_readout.vhd\n
        ./modules/top_redpitaya_125_10/hdl/generics.vhd\n
        ./modules/top_redpitaya_125_10/hdl/top_redpitaya_125_10.sv\n"




    # -------------------------------------------------------
    # 1.0) Add SRC Package Files
    # -------------------------------------------------------
    # add_files -fileset "sources_1" -norecurse {\
    #     ./modules/top_redpitaya_125_10/hdl/generics.vhd
    # }
    # puts -nonewline $vivado_added_hdl_report "\
    #     ./modules/top_redpitaya_125_10/hdl/generics.vhd\n"
    # update_compile_order -fileset sources_1

    #    * ModelSim
    # puts -nonewline $simulator_comporder "\
        # ./modules/top_redpitaya_125_10/hdl/generics.vhd\n"



    # -------------------------------------------------------
    # 3.0) Add XDC/TCL Files
    # -------------------------------------------------------
    # DO NOT TOUCH
    # Search for xdc/tcl foles up to 2 levels of hierarchy
    # Search for all .xdc sources associated with this module
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


    close $simulator_comporder
    close $vivado_added_hdl_report
    close $vivado_added_scripts_report
}