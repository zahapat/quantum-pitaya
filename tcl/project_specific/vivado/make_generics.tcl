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


    # Open the project
    close_project -quiet
    open_project "${origin_dir}/vivado/${_xil_proj_name_}.xpr"

    # 1) Set the following generic parameters

    # Template:
    #     By default, a generic is passed to synthesis as "___"
    #     A) When passing a string value:
    #         set_property generic { GENERIC_NAME={\"STRING_VALUE\"} } [current_fileset]
    #     B) When passing a numeric value:
    #         set_property generic { GENERIC_NAME={NUMERIC_VALUE} } [current_fileset]


    set_property generic {\
        INT_BYPASS_DSP=0\
        INT_WHOLE_DDC_LOCOSC_OUT_FREQ_MHZ=25\
        INT_DECIMAL_DDC_LOCOSC_OUT_FREQ_MHZ=0\
        INT_DDC_NUMBER_OF_TAPS=15\
        INT_DDC_COEF_WIDTH=15\
        INT_DDC_OUT_DATA_WIDTH=20\
        INT_DDC_DECIMATION=5\
        INT_AVG_AVERAGE_BY=5\
    } [current_fileset]


    # Close project
    puts "TCL: Running $script_file for project $_xil_proj_name_ COMPLETED SUCCESSFULLY. "
    close_project
