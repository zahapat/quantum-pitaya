# -------------------------------------------------------------
#                     MAKEFILE VARIABLES
# -------------------------------------------------------------
#  Mandatory variables
PROJ_NAME = $(shell basename $(CURDIR))
PROJ_DIR = $(dir $(abspath $(firstword $(MAKEFILE_LIST))))


# Vivado parameters
VIVADO_VERSION = 2020.2
VIVADO_INSTALLPATH = C:/Xilinx/Vivado
VIVADO_BINPATH = $(VIVADO_INSTALLPATH)/$(VIVADO_VERSION)/bin


# [make new]: FPGA part number
PART = xc7z010clg400-1


# [make core/ip]: Name for the new IP package
NAME_IP_PACK ?= $(PROJ_NAME)_ip


# Libraries for HDL sources and testbenches
LIB_SRC ?= work
LIB_SIM ?= work


# [make new_module]: Architecture type, generate extra files
ARCH ?= rtl
EXTRA ?= none


# [make src] Actual top module you are working with
TOP ?= top.vhd
BOARD ?= top

# -------------------------------------------------------------
#                     MAKEFILE TARGETS
# -------------------------------------------------------------
.ONESHELL:


# Generic Vivado/Simulator Targets
reset :
	make new
	make sim_clean


# make new: to create/recreate a project, set up settings
new :
	$(info ----- RE/CREATE THE VIVADO PROJECT: $(PROJ_NAME) -----)
	rm *.str
	rm -r ./.Xil
	rm -r ./vivado
	mkdir ./vivado
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/recreate_vivado_proj.tcl -notrace -tclargs $(PART)


# make src TOP=<module>: Set a file graph for synthesis or/and implementation under the given TOP module
src : ./vivado/$(PROJ_NAME).xpr
	$(info ----- SEARCH FOR TOP MODULE AND ALL ITS SUBMODULES -----)
	rm -r ./vivado/0_report_added_modules.rpt
	rm -r ./vivado/0_report_added_xdc.rpt
	rm -r ./do/modules.tcl
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_src.tcl -notrace -tclargs $(TOP) $(LIB_SRC) $(LIB_SIM)


# make board
board : ./vivado/$(PROJ_NAME).xpr
	$(info ----- RE/ADD ALL BOARD FILES -----)
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_board.tcl -notrace -tclargs $(BOARD)


# make ooc TOP=<module>: Run Synthesis in Out-of-context mode
ooc : ./vivado/$(PROJ_NAME).xpr ./vivado/0_report_added_modules.rpt
	$(info ----- RUN SYNTHESIS IN OUT-OF-CONTEXT MODE -----)
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_ooc.tcl -notrace -tclargs $(TOP)


# make synth: Run Synthesis only, use current fileset
synth : ./vivado/$(PROJ_NAME).xpr
	$(info ----- RUN SYNTHESIS -----)
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/synth_design.tcl -notrace


# make impl: Run Implementation only, use current fileset
impl : ./vivado/1_checkpoint_post_synth.dcp ./vivado/$(PROJ_NAME).xpr
	$(info ----- RUN IMPLEMENTATION -----)
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/impl_design.tcl -notrace


# make bit: Run synthesis or/and implementation if out-of-date
bit : ./vivado/2_checkpoint_post_route.dcp ./vivado/1_checkpoint_post_synth.dcp ./vivado/$(PROJ_NAME).xpr
	$(info ----- RUN GENERATE BITSTREAM -----)
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/run_bitstream.tcl  -notrace


# make xsa: Run synthesis, implementation, generate bitstream -> generate HW Platform .xsa file form .bit file
xsa : ./vivado/$(PROJ_NAME).xpr
	$(info ----- RUN ALL THE WAY THROUGH BIT GEN AND GENERATE HW PLATFORM -----)
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_run_hw_platform.tcl  -notrace


# make prog: Use 3_bitstream_<PROJ_NAME> to program the target FPGA
prog : ./vivado/2_checkpoint_post_route.dcp ./vivado/1_checkpoint_post_synth.dcp ./vivado/$(PROJ_NAME).xpr ./vivado/3_bitstream_$(PROJ_NAME).bit
	$(info ----- PROGRAM FPGA -----)
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_prog.tcl  -notrace


# make all: Run Synthesis, Implementation, Generate Bitstream
all : ./vivado/$(PROJ_NAME).xpr
	$(info ----- RUN ALL STAGES: SYNTH, IMPL + BIT -----)
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/run_all.tcl -notrace


# make clean: Clean Vivado project files and Simulator project folder content
clean : ./vivado/$(PROJ_NAME).xpr
	$(info ----- CLEAN VIVADO & QUESTA PROJECT JUNK FILES, CLEAN ENVIRONMENT -----)
	rm -r ./.Xil
	rm *.str
	rm *.tmp
	rm *.log
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode batch -source ./tcl/generic/vivado/make_clean.tcl -notrace -tclargs $(LIB_SRC) $(LIB_SIM)


# make gui: Run Vivado in mode GUI and open project in the vivado folder
gui : ./vivado/$(PROJ_NAME).xpr
	$(info ----- RUN VIVADO IN MODE GUI -----)
	$(VIVADO_BINPATH)/vivado.bat -nolog -nojou -mode gui -notrace ./vivado/$(PROJ_NAME).xpr