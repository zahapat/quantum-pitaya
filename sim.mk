# -------------------------------------------------------------
#                     MAKEFILE VARIABLES
# -------------------------------------------------------------
# Mandatory variables
PROJ_NAME = $(shell basename $(CURDIR))
PROJ_DIR = $(dir $(abspath $(firstword $(MAKEFILE_LIST))))

# Libraries for HDL sources and testbenches
LIB_SRC ?= work
LIB_SIM ?= work

# -------------------------------------------------------------
#                     MAKEFILE TARGETS
# -------------------------------------------------------------
.ONESHELL:


# Modelsim

# Initialize Simulator (Questa)
./simualtor/modelsim.ini :
	$(info ----- INITIALIZE SIMULATOR -----)
	rm -r $(PROJ_DIR)simualtor/modelsim.ini
	cd $(PROJ_DIR)simulator; vmap -c
	set MODELSIM=$(PROJ_DIR)simulator/modelsim.ini

# make sim LIB_SRC=libname LIB_SIM=libname: re/create respective libraries for the project in ModelSim, run all
sim_clean : ./simualtor/modelsim.ini
	$(info ----- RESET SIM ENVIRONMENT, RUN ALL IN BATCH -----)
	rm -r $(PROJ_DIR)simualtor/modelsim.ini
	cd $(PROJ_DIR)simulator; vsim -c -do "do ./do/make_sim_clean.tcl $(LIB_SRC),$(LIB_SIM),$(PROJ_DIR)"
	rm -r $(PROJ_DIR)simulator/transcript

# make sim LIB_SRC=libname LIB_SIM=libname: re/create respective libraries for the project in ModelSim, run all
sim : ./simualtor/modelsim.ini
	$(info ----- RESET SIM ENVIRONMENT, RUN ALL IN BATCH -----)
	cd $(PROJ_DIR)simulator; vsim -c -do "do ./do/make_sim.tcl $(LIB_SRC),$(LIB_SIM),$(PROJ_DIR)"

# make sim_gui LIB_SRC=libname LIB_SIM=libname: re/create Questa project, create libraries, add files, compile all, run all
sim_gui : ./simualtor/modelsim.ini ./simulator/run.do ./simulator/new.do
	$(info ----- RESET SIM ENVIRONMENT, RUN ALL IN GUI -----)
	cd $(PROJ_DIR)simulator; vsim -do "do ./do/make_sim.tcl $(LIB_SRC),$(LIB_SIM),$(PROJ_DIR)"