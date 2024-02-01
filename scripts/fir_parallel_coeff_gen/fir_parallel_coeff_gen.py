from scipy import signal

def fir_parallel_coeffs_gen(verbose, delimiter,
                                proj_name, proj_dir, output_dir, 
                                int_coeff_width,                # e.g. 15
                                int_num_of_filter_taps,         # e.g. 20
                                float_sampling_frequency_MHz,   # e.g. 500.0
                                float_cutoff_frequency_MHz):    # e.g. 25.0

    int_coeff_width = int(int_coeff_width)
    int_num_of_filter_taps = int(int_num_of_filter_taps)
    float_sampling_frequency_MHz = float(float_sampling_frequency_MHz)
    float_cutoff_frequency_MHz = float(float_cutoff_frequency_MHz)

    # Generate the FIR coefficients based on the input parameters
    fir_coefficients_array = signal.firwin(int_num_of_filter_taps, float_cutoff_frequency_MHz, fs=float_sampling_frequency_MHz)

    _file_out_gen_name = 'fir_parallel_coeff.svh'
    _file_out_gen_fullpath = ('{0}{1}{2}'.format(output_dir, delimiter, _file_out_gen_name))
    print('new file', _file_out_gen_name,'created: ', _file_out_gen_fullpath)
    _file_out_gen_line = open(_file_out_gen_fullpath, 'w')

    _file_out_gen_line.write('    parameter INT_NUMBER_OF_TAPS = '+'{}'.format(int_num_of_filter_taps)+';\n')
    _file_out_gen_line.write('    parameter INT_COEF_WIDTH = '+'{}'.format(int_coeff_width)+';\n')
    _file_out_gen_line.write('    logic signed[INT_COEF_WIDTH-1:0] fir_coefficients [INT_NUMBER_OF_TAPS-1:0] = \'{'+'\n')
    
    for i in range(len(fir_coefficients_array)):
        if i == (len(fir_coefficients_array)-1):
            if 'e-0' in str(fir_coefficients_array[i]):
                if verbose:
                    print("        INT_COEF_WIDTH'($rtoi((" + str(fir_coefficients_array[i]).replace('e-0','**(-') + str(')') + ") * (2.0**(INT_COEF_WIDTH)/2 - 1.0)))")
                    _file_out_gen_line.write('        INT_COEF_WIDTH\'($rtoi((' + str(fir_coefficients_array[i]).replace('e-0','**(-') + str(')') + ') * (2.0**(INT_COEF_WIDTH)/2 - 1.0)))'+'\n')
                else:
                    _file_out_gen_line.write('        INT_COEF_WIDTH\'($rtoi((' + str(fir_coefficients_array[i]).replace('e-0','**(-') + str(')') + ') * (2.0**(INT_COEF_WIDTH)/2 - 1.0)))'+'\n')
                    

            elif 'e-' in str(fir_coefficients_array[i]):
                if verbose:
                    print("        INT_COEF_WIDTH'((" + str(fir_coefficients_array[i]).replace('e-','**(-') + str(')') + ") * (2.0**(INT_COEF_WIDTH)/2 - 1.0)))")
                    _file_out_gen_line.write('        INT_COEF_WIDTH\'($rtoi((' + str(fir_coefficients_array[i]).replace('e-','**(-') + str(')') + ') * (2.0**(INT_COEF_WIDTH)/2 - 1.0)))'+'\n')
                else:
                    _file_out_gen_line.write('        INT_COEF_WIDTH\'($rtoi((' + str(fir_coefficients_array[i]).replace('e-','**(-') + str(')') + ') * (2.0**(INT_COEF_WIDTH)/2 - 1.0)))'+'\n')


            elif 'e' in str(fir_coefficients_array[i]):
                if verbose:
                    print("        INT_COEF_WIDTH'((" + str(fir_coefficients_array[i]).replace('e','**') + ") * (2.0**(INT_COEF_WIDTH)/2 - 1.0)))")
                    _file_out_gen_line.write('        INT_COEF_WIDTH\'($rtoi((' + str(fir_coefficients_array[i]).replace('e','**') + ') * (2.0**(INT_COEF_WIDTH)/2 - 1.0)))'+'\n')
                else:
                    _file_out_gen_line.write('        INT_COEF_WIDTH\'($rtoi((' + str(fir_coefficients_array[i]).replace('e','**') + ') * (2.0**(INT_COEF_WIDTH)/2 - 1.0)))'+'\n')


            else:
                if verbose:
                    print("        INT_COEF_WIDTH'($rtoi((" + str(fir_coefficients_array[i]) + ") * (2.0**(INT_COEF_WIDTH)/2 - 1.0)))")
                    _file_out_gen_line.write('        INT_COEF_WIDTH\'($rtoi((' + str(fir_coefficients_array[i]) + ') * (2.0**(INT_COEF_WIDTH)/2 - 1.0)))'+'\n')
                else:
                    _file_out_gen_line.write('        INT_COEF_WIDTH\'($rtoi((' + str(fir_coefficients_array[i]) + ') * (2.0**(INT_COEF_WIDTH)/2 - 1.0)))'+'\n')


        else :
            if 'e-0' in str(fir_coefficients_array[i]):
                if verbose:
                    print("        INT_COEF_WIDTH'($rtoi((" + str(fir_coefficients_array[i]).replace('e-0','**(-') + str(')') + ") * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),")
                    _file_out_gen_line.write('        INT_COEF_WIDTH\'($rtoi((' + str(fir_coefficients_array[i]).replace('e-0','**(-') + str(')') + ') * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),'+'\n')
                else:
                    _file_out_gen_line.write('        INT_COEF_WIDTH\'($rtoi((' + str(fir_coefficients_array[i]).replace('e-0','**(-') + str(')') + ') * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),'+'\n')

            elif 'e-' in str(fir_coefficients_array[i]):
                if verbose:
                    print("        INT_COEF_WIDTH'($rtoi((" + str(fir_coefficients_array[i]).replace('e-','**(-') + str(')') + ") * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),")
                    _file_out_gen_line.write('        INT_COEF_WIDTH\'($rtoi((' + str(fir_coefficients_array[i]).replace('e-','**(-') + str(')') + ') * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),'+'\n')
                else:
                    _file_out_gen_line.write('        INT_COEF_WIDTH\'($rtoi((' + str(fir_coefficients_array[i]).replace('e-','**(-') + str(')') + ') * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),'+'\n')

            elif 'e' in str(fir_coefficients_array[i]):
                if verbose:
                    print("        INT_COEF_WIDTH'($rtoi((" + str(fir_coefficients_array[i]).replace('e','**') + ") * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),")
                    _file_out_gen_line.write('        INT_COEF_WIDTH\'($rtoi((' + str(fir_coefficients_array[i]).replace('e','**') + ') * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),'+'\n')
                else:
                    _file_out_gen_line.write('        INT_COEF_WIDTH\'($rtoi((' + str(fir_coefficients_array[i]).replace('e','**') + ') * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),'+'\n')

            else:
                if verbose:
                    print("        INT_COEF_WIDTH'($rtoi((" + str(fir_coefficients_array[i]) + ") * (2.0**(INT_COEF_WIDTH)/2 - 1.0)),")
                    _file_out_gen_line.write('        INT_COEF_WIDTH\'($rtoi((' + str(fir_coefficients_array[i]) + ') * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),'+'\n')
                else:
                    _file_out_gen_line.write('        INT_COEF_WIDTH\'($rtoi((' + str(fir_coefficients_array[i]) + ') * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),'+'\n')

    _file_out_gen_line.write('    };')
    _file_out_gen_line.close()

