# Usage Examples:
# make gacp MSG="fix: Enable commit msg from cli"  <--- YOU  MUST enter the commit message in quotation marks

# Requires Github CLI + git installed


# -------------------------------------------------------------
#                     MAKEFILE VARIABLES
# -------------------------------------------------------------
# Mandatory variables
PROJ_NAME = $(shell basename $(CURDIR))
PROJ_DIR = $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
# PROJ_CYGDIR = $(abspath $(lastword $(MAKEFILE_LIST)))
PROJ_CYGDIR = $(shell pwd)
TIMESTAMP = $$(date -u +%FT%T%Z)
TIMER_START  := $(shell date "+%s")
TIMER_END     = $(shell date "+%s")
TIMER_SECONDS = $(shell expr $(TIMER_END) - $(TIMER_START))
TIMER_FORMAT  = $(shell date --utc --date="@$(TIMER_SECONDS)" "+%H:%M:%S")


# Links to related Makefiles
PROJECT_SPECIFIC_MAKEFILE = project_specific.mk
GENERIC_MAKEFILE = generic.mk
VIVADO_MAKEFILE = vivado.mk
SIM_MAKEFILE = sim.mk
VITIS_MAKEFILE = vitis.mk
GIT_MAKEFILE = git.mk
PACKAGES_MAKEFILE = packages.mk
REDPITAYA_MAKEFILE = redpitaya.mk


# Libraries for HDL sources and testbenches
LIB_SRC ?= work
LIB_SIM ?= work


# [make reset]: Configure the Vivado project for a specific FPGA/board
PART = xc7z010clg400-1


# [make new_module]: Architecture type, generate extra files
ARCH ?= rtl
EXTRA ?= none


# [make src] Actual top module you are working with
TOP = top_redpitaya_125_14.sv
BOARD = sqdlab_redpitaya_125_14_extclk



# Board IP Address (Formerly for Red Pitaya board)
# RP 125-10
# BOARD_LOCALHOST_URL ?= rp-f07244.local
# RP 125-14 extclk
BOARD_LOCALHOST_URL ?= rp-f0afdf.local


# [make generics] Set names and values for generic variables
#     [Natural Number] Bypass the DSP block (read only data from ADC)
GEN1_NAME = INT_BYPASS_DSP
GEN1_VAL = 0
#     [Natural Number] Sampling/Clock frequency the local oscillator is running on
GEN2_NAME = INT_WHOLE_DDC_LOCOSC_OUT_FREQ_MHZ
GEN2_VAL = 25
GEN3_NAME = INT_DECIMAL_DDC_LOCOSC_OUT_FREQ_MHZ
GEN3_VAL = 0
#     [Natural Number] Number of FIR Taps
GEN4_NAME = INT_DDC_NUMBER_OF_TAPS
GEN4_VAL = 25
#     [Natural Number] Width of each FIR coefficient
GEN5_NAME = INT_DDC_COEF_WIDTH
GEN5_VAL = 15
# 	  [Natural Number] Output data width of the digital downconversion module
GEN6_NAME = INT_DDC_OUT_DATA_WIDTH
GEN6_VAL = 20
# 	  [Natural Number] The sampling decimation value
GEN7_NAME = INT_DDC_MAX_DECIMATION
GEN7_VAL = 20
# 	  [Natural Number] How many data points are to be accumulated/averaged
GEN8_NAME = INT_AVG_MAX_AVERAGE_BY
GEN8_VAL = 20
# 	  [Positive Number] How many items are to be stored in the multichannel fifo/accumulator
GEN9_NAME = INT_MULTIACC_FIFO_DEPTH
GEN9_VAL = 1024
# 	  [Positive Number] Set the number of channels of the multichannel fifo/accumulator
GEN10_NAME = INT_MULTIACC_CHANNELS
GEN10_VAL = 30
# 	  [Positive Number] Set the number of accumulation repetitions per channel
GEN11_NAME = INT_MULTIACC_REPETITIONS
GEN11_VAL = 15
# 	  [Positive Number] Set the number of bits for a command (Channel write 1)
GEN12_NAME = INT_CMD_OUTPUT_WIDTH
GEN12_VAL = 5
# 	  [Positive Number] Set the number of bits for module select in a single 32b transaction
GEN13_NAME = INT_MODULE_SELECT_WIDTH
GEN13_VAL = 5
# 	  [Positive Number] Configure the message to the Command Parser: Set the number bits for the module select to define max number of controllable modules in the design
GEN14_NAME = INT_MODULES_CMD_CNT
GEN14_VAL = 13
# 	  [Positive Number] Set the number of bits for module select in a single 32b transaction
GEN15_NAME = INT_OUT_FIFO_BUFFERS_DEPTH
GEN15_VAL = 1024



# -------------------------------------------------------------
#                     MAKEFILE TARGETS
# -------------------------------------------------------------
.ONESHELL:



# -------------------------------------------------------------
#  Default target
# -------------------------------------------------------------
TARGET_GENERICS := $(GEN1_VAL)_$(GEN2_VAL)_$(GEN3_VAL)_$(GEN4_VAL)_$(GEN5_VAL)_$(GEN6_VAL)_$(GEN7_VAL)_$(GEN8_VAL)_$(GEN9_VAL)_$(GEN10_VAL)_$(GEN11_VAL)_$(GEN12_VAL)_$(GEN13_VAL)_$(GEN14_VAL)_$(GEN15_VAL)
TARGET_MD5_HASH := build_$(shell echo $(TARGET_GENERICS) | md5sum | awk '{print $$1}')

# Modify TARGET_NAME to change target's bitfile & directory name here (TARGET_GENERICS or ):
TARGET_NAME := $(TARGET_GENERICS)
# TARGET_NAME := $(TARGET_MD5_HASH)

TARGET_OUTPUT_DIR := $(PROJ_DIR)outputs/$(basename $(TOP))/$(TARGET_NAME)

# Default Target: Reset -> Add SRCs -> Compile -> Generate Bitstream
$(TARGET_OUTPUT_DIR)/$(TARGET_NAME).bit:
	@make build timer \
		TOP=$(TOP) \
		BOARD=$(BOARD) \
		GEN1_NAME=$(GEN1_NAME)   GEN1_VAL=$(GEN1_VAL) \
		GEN2_NAME=$(GEN2_NAME)   GEN2_VAL=$(GEN2_VAL) \
		GEN3_NAME=$(GEN3_NAME)   GEN3_VAL=$(GEN3_VAL) \
		GEN4_NAME=$(GEN4_NAME)   GEN4_VAL=$(GEN4_VAL) \
		GEN5_NAME=$(GEN5_NAME)   GEN5_VAL=$(GEN5_VAL) \
		GEN6_NAME=$(GEN6_NAME)   GEN6_VAL=$(GEN6_VAL) \
		GEN7_NAME=$(GEN7_NAME)   GEN7_VAL=$(GEN7_VAL) \
		GEN8_NAME=$(GEN8_NAME)   GEN8_VAL=$(GEN8_VAL) \
		GEN9_NAME=$(GEN9_NAME)   GEN9_VAL=$(GEN9_VAL) \
		GEN10_NAME=$(GEN10_NAME) GEN10_VAL=$(GEN10_VAL) \
		GEN11_NAME=$(GEN11_NAME) GEN11_VAL=$(GEN11_VAL) \
		GEN12_NAME=$(GEN12_NAME) GEN12_VAL=$(GEN12_VAL) \
		GEN13_NAME=$(GEN13_NAME) GEN13_VAL=$(GEN13_VAL) \
		GEN14_NAME=$(GEN14_NAME) GEN14_VAL=$(GEN14_VAL) \
		GEN15_NAME=$(GEN15_NAME) GEN15_VAL=$(GEN15_VAL)


# -------------------------------------------------------------
#  Auxiliary targets
# -------------------------------------------------------------
timer:
	@echo "-------------------------------------------"
	@echo "make timer: Build Duration: $(TIMER_FORMAT)"
	@echo "-------------------------------------------"

# -------------------------------------------------------------
#  "project_specific.mk" targets
# -------------------------------------------------------------
init:
	@$(MAKE) -f $(PROJECT_SPECIFIC_MAKEFILE) $@

generics :
	@$(MAKE) -f $(PROJECT_SPECIFIC_MAKEFILE) $@ \
		GEN1_NAME=$(GEN1_NAME)   GEN1_VAL=$(GEN1_VAL) \
		GEN2_NAME=$(GEN2_NAME)   GEN2_VAL=$(GEN2_VAL) \
		GEN3_NAME=$(GEN3_NAME)   GEN3_VAL=$(GEN3_VAL) \
		GEN4_NAME=$(GEN4_NAME)   GEN4_VAL=$(GEN4_VAL) \
		GEN5_NAME=$(GEN5_NAME)   GEN5_VAL=$(GEN5_VAL) \
		GEN6_NAME=$(GEN6_NAME)   GEN6_VAL=$(GEN6_VAL) \
		GEN7_NAME=$(GEN7_NAME)   GEN7_VAL=$(GEN7_VAL) \
		GEN8_NAME=$(GEN8_NAME)   GEN8_VAL=$(GEN8_VAL) \
		GEN9_NAME=$(GEN9_NAME)   GEN9_VAL=$(GEN9_VAL) \
		GEN10_NAME=$(GEN10_NAME) GEN10_VAL=$(GEN10_VAL) \
		GEN11_NAME=$(GEN11_NAME) GEN11_VAL=$(GEN11_VAL) \
		GEN12_NAME=$(GEN12_NAME) GEN12_VAL=$(GEN12_VAL) \
		GEN13_NAME=$(GEN13_NAME) GEN13_VAL=$(GEN13_VAL) \
		GEN14_NAME=$(GEN14_NAME) GEN14_VAL=$(GEN14_VAL) \
		GEN15_NAME=$(GEN15_NAME) GEN15_VAL=$(GEN15_VAL) \
		TOPFILE_DIR=$(PROJ_DIR)modules/$(basename $(TOP))/hdl

# make src TOP=axi4lite_fifo_readout.vhd
build:
	@make reset
	@make src TOP=$(TOP)
	@make gen_fir_coeff \
		INT_NUMBER_OF_TAPS=$(GEN4_VAL) \
		INT_COEF_WIDTH=$(GEN5_VAL) \
		FLOAT_SAMPLING_FREQUENCY_MHZ=125.0 \
		FLOAT_CUTOFF_FREQUENCY_MHZ=$(GEN2_VAL).$(GEN3_VAL)
	@make generics TOP=$(TOP)
	@make board BOARD=$(BOARD)
	@make all
	@make distribute_outputs

distribute_bitfiles:
	@$(MAKE) -f $(PROJECT_SPECIFIC_MAKEFILE) $@
cmd_timeout:
	@$(MAKE) -f $(PROJECT_SPECIFIC_MAKEFILE) $@

read_ch1:
	@make rp_read \
		ADDRESS=0x40600000 \
		VALUES_CNT=1024 \
		COUT_OUTPUT_DIR=$(TARGET_OUTPUT_DIR) \
		COUT_FILENAME=read_ch1.txt

read_ch2:
	@make rp_read \
		ADDRESS=0x40600004 \
		VALUES_CNT=1024 \
		COUT_OUTPUT_DIR=$(TARGET_OUTPUT_DIR) \
		COUT_FILENAME=read_ch2.txt

distribute_outputs: ./vivado/3_bitstream_$(PROJ_NAME).bit
	@echo $(PROJ_DIR)
	@mkdir -p $(TARGET_OUTPUT_DIR)
	@cp -r $(PROJ_DIR)vivado/3_bitstream_$(PROJ_NAME).bit $(TARGET_OUTPUT_DIR)/$(TARGET_NAME).bit
	@cp -r $(PROJ_DIR)vivado/*.rpt $(TARGET_OUTPUT_DIR)


# Create 1 run: Program -> Read Ch1,Ch2
run:
	@make rp_prog
	@make read_ch1
	@make read_ch2


# Loop Over and Parametrize Buids: Insert $$i instead of $(GENX_VAL)
LOOP_VALUES1 = 17 19 21 23 25 27    # INT_DDC_NUMBER_OF_TAPS = GEN4_VAL
# LOOP_VALUES1 = 30 31 32 33 34     # INT_MULTIACC_CHANNELS = GEN10_VAL
LOOP1 = for i in $(LOOP_VALUES1); do
builds:
#            INT_BYPASS_DSP        INT_WHOLE_DDC_LOCOSC_OUT_FREQ_MHZ  INT_DECIMAL_DDC_LOCOSC_OUT_FREQ_MHZ  INT_DDC_NUMBER_OF_TAPS  INT_DDC_COEF_WIDTH     INT_DDC_OUT_DATA_WIDTH  INT_DDC_MAX_DECIMATION    INT_AVG_MAX_AVERAGE_BY  INT_MULTIACC_FIFO_DEPTH  INT_MULTIACC_CHANNELS   INT_MULTIACC_REPETITIONS  INT_CMD_OUTPUT_WIDTH    INT_MODULE_SELECT_WIDTH  INT_MODULES_CMD_CNT     INT_OUT_FIFO_BUFFERS_DEPTH
	@$(LOOP1) \
		make GEN1_VAL=$(GEN1_VAL)  GEN2_VAL=$(GEN2_VAL)               GEN3_VAL=$(GEN3_VAL)                 GEN4_VAL=$(GEN4_VAL)    GEN5_VAL=$(GEN5_VAL)   GEN6_VAL=$(GEN6_VAL)    GEN7_VAL=$(GEN7_VAL)  GEN8_VAL=$(GEN8_VAL)    GEN9_VAL=$(GEN9_VAL)     GEN10_VAL=$$i           GEN11_VAL=$(GEN11_VAL)    GEN12_VAL=$(GEN12_VAL)  GEN13_VAL=$(GEN13_VAL)   GEN14_VAL=$(GEN14_VAL)  GEN15_VAL=$(GEN15_VAL); \
	done



rp_prog1:
	@make rp_prog TOP=top_redpitaya_125_10 BOARD_LOCALHOST_URL=rp-f07244.local

rp_prog2:
	@make rp_prog TOP=top_redpitaya_125_14 BOARD_LOCALHOST_URL=rp-f0afdf.local

rp_prog12:
	@make rp_prog TOP=top_redpitaya_125_10 BOARD_LOCALHOST_URL=rp-f07244.local
	@make rp_prog TOP=top_redpitaya_125_14 BOARD_LOCALHOST_URL=rp-f0afdf.local


# -------------------------------------------------------------
#  "vivado.mk" targets
# -------------------------------------------------------------
reset:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@ PART=$(PART)
new:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
new_module:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
src:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@ TOP=$(TOP)
board:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@ BOARD=$(BOARD)
declare :
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
ooc:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
synth:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
impl:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
outd:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
bit:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
xsa:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
prog:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
probes:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
ila:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
all:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
old:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
clean:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
gui:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
core:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@
ip:
	@$(MAKE) -f $(VIVADO_MAKEFILE) $@



# -------------------------------------------------------------
#  "sim.mk" targets
# -------------------------------------------------------------
./simualtor/modelsim.ini:
	@$(MAKE) -f $(SIM_MAKEFILE) $@
sim_clean:
	@$(MAKE) -f $(SIM_MAKEFILE) $@ LIB_SRC=$(LIB_SRC) LIB_SIM=$(LIB_SIM)
sim:
	@$(MAKE) -f $(SIM_MAKEFILE) $@ LIB_SRC=$(LIB_SRC) LIB_SIM=$(LIB_SIM)
sim_gui:
	@$(MAKE) -f $(SIM_MAKEFILE) $@ LIB_SRC=$(LIB_SRC) LIB_SIM=$(LIB_SIM)



# -------------------------------------------------------------
#  "generic.mk" targets
# -------------------------------------------------------------
# FIR Coefficients Generator
INT_NUMBER_OF_TAPS = 15
INT_COEF_WIDTH = 15
FLOAT_SAMPLING_FREQUENCY_MHZ = 125.0
FLOAT_CUTOFF_FREQUENCY_MHZ = 25.0
gen_fir_coeff:
	@$(MAKE) -f $(GENERIC_MAKEFILE) $@ \
		INT_COEF_WIDTH=$(INT_COEF_WIDTH) \
		INT_NUMBER_OF_TAPS=$(INT_NUMBER_OF_TAPS) \
		FLOAT_SAMPLING_FREQUENCY_MHZ=$(FLOAT_SAMPLING_FREQUENCY_MHZ) \
		FLOAT_CUTOFF_FREQUENCY_MHZ=$(FLOAT_CUTOFF_FREQUENCY_MHZ)



# -------------------------------------------------------------
#  git.mk targets
# -------------------------------------------------------------
gp:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
gac:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
gacp: 
	@$(MAKE) -f $(GIT_MAKEFILE) $@
gacpt:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
glive:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_login_thisdir:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_login:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_cli_auth:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_config:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_init:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_branch:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_add_all:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_commit_all:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_commit:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_change_commit_after_push:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_change_last_commit_before_push:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_undo_last_commit_before_push:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_undo_last_commit_after_push:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_new_remote_origin_https:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_new_remote_origin_template_https:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_history:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_goto_commit:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_new_private_repo:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_new_public_repo:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_new_private_repo_from_template:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_new_public_repo_from_template:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_make_this_repo_template:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_clone_repo_https:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_connected_repos:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_list_branches:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_new_branch:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_switch_branch:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_compare_with_main_branch:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_merge_to_main_branch:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_update_changes_thisbranch_projrepo:
	@$(MAKE) -f $(GIT_MAKEFILE) $@
git_update_changes_mainbranch_templrepo:
	@$(MAKE) -f $(GIT_MAKEFILE) $@



# -------------------------------------------------------------
#  "redpitaya.mk" targets
# -------------------------------------------------------------
winget_install_putty:
	@$(MAKE) -f $(REDPITAYA_MAKEFILE) $@ \
		BOARD_LOCALHOST_URL=$(BOARD_LOCALHOST_URL)
rp_inspect_bitfile:
	@$(MAKE) -f $(REDPITAYA_MAKEFILE) $@ \
		BOARD_LOCALHOST_URL=$(BOARD_LOCALHOST_URL)
rp_terminal:
	@$(MAKE) -f $(REDPITAYA_MAKEFILE) $@ \
		BOARD_LOCALHOST_URL=$(BOARD_LOCALHOST_URL)
rp_load_bitfile:
	@$(MAKE) -f $(REDPITAYA_MAKEFILE) $@ \
		BOARD_LOCALHOST_URL=$(BOARD_LOCALHOST_URL)
rp_program:
	@$(MAKE) -f $(REDPITAYA_MAKEFILE) $@ \
		BOARD_LOCALHOST_URL=$(BOARD_LOCALHOST_URL)
rp_clean_bitfile:
	@$(MAKE) -f $(REDPITAYA_MAKEFILE) $@ \
		BOARD_LOCALHOST_URL=$(BOARD_LOCALHOST_URL)
rp_prog: $(TARGET_OUTPUT_DIR)/$(TARGET_NAME).bit
	@$(MAKE) -f $(REDPITAYA_MAKEFILE) $@ \
		BOARD_LOCALHOST_URL=$(BOARD_LOCALHOST_URL) \
		PATH_TO_BITFILEDIR=$(TARGET_OUTPUT_DIR) \
		BITFILE_NAME=$(TARGET_NAME).bit
rp_read:
	@$(MAKE) -f $(REDPITAYA_MAKEFILE) $@ \
		ADDRESS=$(ADDRESS) \
		VALUES_CNT=$(VALUES_CNT) \
		COUT_OUTPUT_DIR=$(COUT_OUTPUT_DIR) \
		COUT_FILENAME=$(COUT_FILENAME)
rp_write:
	@$(MAKE) -f $(REDPITAYA_MAKEFILE) $@ \
		ADDRESS=$(ADDRESS) \
		RP_CMD=$(RP_CMD)
rp_stream:
	@$(MAKE) -f $(REDPITAYA_MAKEFILE) $@ \
		BOARD_LOCALHOST_URL=$(BOARD_LOCALHOST_URL)