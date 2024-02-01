# -------------------------------------------------------------
#                     MAKEFILE VARIABLES
# -------------------------------------------------------------
# Mandatory variables
PROJ_NAME = $(shell basename $(CURDIR))
PROJ_DIR = $(dir $(abspath $(firstword $(MAKEFILE_LIST))))



# -------------------------------------------------------------
#                     MAKEFILE TARGETS
# -------------------------------------------------------------
.ONESHELL:

init:
	make reset
	make src TOP=top_gflow_tb.vhd

build:
	make init
	make generics
	make all
	make distribute_bitfiles

distribute_bitfiles: ./vivado/3_bitstream_$(PROJ_NAME).bit
	rm ./scripts/gui/redis/bitfile.bit
	cp ./vivado/3_bitstream_$(PROJ_NAME).bit ./scripts/gui/redis/bitfile.bit


generics :
	$(info ----- SET GENERICS BEFORE SYNTHESIS -----)
	py -3 ./scripts/generics/genTclGenericsMain.py \
		--generic1_name=$(GEN1_NAME)   --generic1_val=$(GEN1_VAL)\
		--generic2_name=$(GEN2_NAME)   --generic2_val=$(GEN2_VAL)\
		--generic3_name=$(GEN3_NAME)   --generic3_val=$(GEN3_VAL)\
		--generic4_name=$(GEN4_NAME)   --generic4_val=$(GEN4_VAL)\
		--generic5_name=$(GEN5_NAME)   --generic5_val=$(GEN5_VAL)\
		--generic6_name=$(GEN6_NAME)   --generic6_val=$(GEN6_VAL)\
		--generic7_name=$(GEN7_NAME)   --generic7_val=$(GEN7_VAL)\
		--generic8_name=$(GEN8_NAME)   --generic8_val=$(GEN8_VAL)\
		--generic9_name=$(GEN9_NAME)   --generic9_val=$(GEN9_VAL)\
		--generic10_name=$(GEN10_NAME) --generic10_val=$(GEN10_VAL)\
		--generic11_name=$(GEN11_NAME) --generic11_val=$(GEN11_VAL)\
		--generic12_name=$(GEN12_NAME) --generic12_val=$(GEN12_VAL)\
		--generic13_name=$(GEN13_NAME) --generic13_val=$(GEN13_VAL)\
		--generic14_name=$(GEN14_NAME) --generic14_val=$(GEN14_VAL)\
		--generic15_name=$(GEN15_NAME) --generic15_val=$(GEN15_VAL)\
		--proj_name=$(PROJ_NAME) \
		--proj_dir=$(PROJ_DIR) \
		--output_dir=$(TOPFILE_DIR)


cmd_timeout:
	timeout /t 15