# ----- Libraries -----
import os
import sys
import getopt
import pathlib as lib_path

# ----- Import generator of the TCL file -----
import fir_parallel_coeff_gen

# ----- Functions -----
def usage():
    print('PY: Correct usage:')
    print('PY: Example #1: python3 guiMain.py -h')
    print('PY: Example #2: python3 guiMain.py --help')


# ----- Main Function -----
def main(argv):

    # Trim first argument (0) from the list of commandline arguments (which is the file name)
    argumentsList = argv[1:]
    print("PY: Command-line arguments list before parsing: ", argumentsList)
    print("PY: Number of command-line arguments: ", len(argumentsList))

    # Set of options (h: means that option '-h' can also be a long option '--help')
    options = "h:v:"

    # List of long options
    longOptions = [
        "help",
        "verbose",

        "proj_name=",
        "proj_dir=",

        "int_coeff_width=",
        "int_num_of_filter_taps=",
        "float_sampling_frequency_MHz=",
        "float_cutoff_frequency_MHz=",

        "output_dir="
    ]

    # Default values of arguments needed to be passed to this script
    verbose = False

    proj_name = ""
    proj_dir = ""

    int_coeff_width = None
    int_num_of_filter_taps = None
    float_sampling_frequency_MHz = None
    float_cutoff_frequency_MHz = None

    output_dir = "./scripts/fir_parallel_coeff_gen"

    # Parsing arguments
    try:
        allArgs, allArgValues = getopt.getopt(argumentsList, options, longOptions)

        for currentArg, currentArgValue in allArgs:

            # ---- Help and Verbose Switches -----
            # Get help
            if currentArg in ('-h', "--help"):
                usage()
                sys.exit()

            # Get verbose
            elif currentArg in ("-v", "--verbose"):
                verbose = True
                print('PY: Verbose flag is enabled.')


            # ----- Project name, Working and Output Directories -----
            # Get project name
            elif currentArg in ("--proj_name"):
                proj_name = str(currentArgValue)
                print('PY: proj_name: ', proj_name)

            # Get current root directory
            elif currentArg in ("--proj_dir"):
                proj_dir = str(currentArgValue)
                print('PY: Project root directory: ', proj_dir)

            # Get desired output directory
            elif currentArg in ("--output_dir"):
                output_dir = str(currentArgValue)
                print('PY: Output directory: ', output_dir)

            # ----- Parameters for the FIR_parallel filter generator -----
            elif currentArg in ("--int_coeff_width"):
                int_coeff_width = str(currentArgValue)
                print('PY: int_coeff_width: ', int_coeff_width)

            elif currentArg in ("--int_num_of_filter_taps"):
                int_num_of_filter_taps = str(currentArgValue)
                print('PY: int_num_of_filter_taps: ', int_num_of_filter_taps)
            
            elif currentArg in ("--float_sampling_frequency_MHz"):
                float_sampling_frequency_MHz = str(currentArgValue)
                print('PY: float_sampling_frequency_MHz: ', float_sampling_frequency_MHz)
            
            elif currentArg in ("--float_cutoff_frequency_MHz"):
                float_cutoff_frequency_MHz = str(currentArgValue)
                print('PY: float_cutoff_frequency_MHz: ', float_cutoff_frequency_MHz)



    # Output error and return with an error code if cmdline arg not recognised
    except getopt.GetoptError as errorMsg:
        print("PY: Command-line argument not recognised. Error code: ", str(errorMsg))
        usage()
        sys.exit(2)



    # Re/create nested directories for output files if they don't exist
    try:
        os.makedirs(output_dir)
    except FileExistsError:
        # Directory already exists
        print("PY: Directory '", output_dir, "' already exist.")
        pass

    # ----- Functions Declaration -----
    def get_dir_delimiter():
        _delimiter_windows = "\\"
        _delimiter_linux = "/"
        # _delimiter = _delimiter_windows

        # Save Current File Directory
        _dir_current_file = str(lib_path.Path(__file__).parent.resolve())
        print("PY: dir_current_file = ", _dir_current_file)
        
        # Compare occurrences of backslashes and forward slashes
        _occurrences_backslash = _dir_current_file.count(_delimiter_windows)
        _occurrences_slash = _dir_current_file.count(_delimiter_linux)
        
        # If invoked from Makefile or not, use different separators
        if _occurrences_slash > _occurrences_backslash:
            return "/"
        else:
            return "\\"
    
    # Get the correct delimiter for correct path generation
    delimiter = get_dir_delimiter()

    # Launch the Generator
    fir_parallel_coeff_gen.fir_parallel_coeffs_gen(
        verbose, delimiter,
        proj_name, proj_dir, output_dir,
        int_coeff_width, int_num_of_filter_taps, float_sampling_frequency_MHz, float_cutoff_frequency_MHz
    )


# ----- Executors -----
if __name__ == "__main__":
    main(sys.argv)