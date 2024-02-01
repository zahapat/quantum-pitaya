# -------------------------------------------------------------
#                     MAKEFILE VARIABLES
# -------------------------------------------------------------
#  Mandatory variables
PROJ_NAME = $(shell basename $(CURDIR))
PROJ_DIR = $(dir $(abspath $(firstword $(MAKEFILE_LIST))))



# -------------------------------------------------------------
#                     MAKEFILE TARGETS
# -------------------------------------------------------------
.ONESHELL:


FIR_PARALLEL_PATH = $(PROJ_DIR)modules/fir_parallel/hdl
gen_fir_coeff:
	$(info ----- GENERATE FIR PARALLEL COEFFICIENTS -----)
	py -3 ./scripts/fir_parallel_coeff_gen/fir_parallel_coeff_main.py \
		--verbose \
		--proj_name=$(PROJ_NAME) \
	    --proj_dir=$(PROJ_DIR) \
		--output_dir=$(FIR_PARALLEL_PATH) \
	    --int_coeff_width=$(INT_COEF_WIDTH) \
		--int_num_of_filter_taps=$(INT_NUMBER_OF_TAPS) \
		--float_sampling_frequency_MHz=$(FLOAT_SAMPLING_FREQUENCY_MHZ) \
		--float_cutoff_frequency_MHz=$(FLOAT_CUTOFF_FREQUENCY_MHZ)