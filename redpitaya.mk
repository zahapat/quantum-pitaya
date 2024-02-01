# -------------------------------------------------------------
#                     MAKEFILE VARIABLES
# -------------------------------------------------------------
# Mandatory variables
PROJ_NAME = $(shell basename $(CURDIR))
PROJ_DIR = $(dir $(abspath $(firstword $(MAKEFILE_LIST))))


# Type the URL that is written or RP Ethernet connector
BOARD_LOCALHOST_URL ?= rp-f07244.local
BOARD_LOCALHOST_USERNAME ?= root
BOARD_LOCALHOST_PASSWORD ?= root

PATH_TO_BITFILEDIR ?= $(PROJ_DIR)/vivado
BITFILE_NAME ?= 3_bitstream_$(PROJ_NAME).bit

COUT_OUTPUT_DIR ?= $(PROJ_DIR)outputs/
COUT_FILENAME ?= redpitaya_ssh_cout.txt

VALUES_CNT = 100
ADDRESS = 0x40600000


# -------------------------------------------------------------
#                     MAKEFILE TARGETS
# -------------------------------------------------------------
.ONESHELL:

# Input 1: ./ssh/redpitaya
winget_install_putty:
	winget install --id=PuTTY.PuTTY  -e

# Check whether the bitfile is present in the tmp dir
rp_inspect_bitfile:
	plink -ssh $(BOARD_LOCALHOST_USERNAME)@$(BOARD_LOCALHOST_URL) -pw $(BOARD_LOCALHOST_PASSWORD) -batch \
		"pwd; cd /tmp/; pwd; ls; exit"

# Start a new ssl session
rp_terminal:
	putty -ssh $(BOARD_LOCALHOST_USERNAME)@$(BOARD_LOCALHOST_URL) -pw $(BOARD_LOCALHOST_PASSWORD)

# Load generated Bitfile to temp dir after running "make all" or "make bit"
rp_load_bitfile:
	pscp -l $(BOARD_LOCALHOST_USERNAME) -pw $(BOARD_LOCALHOST_PASSWORD) $(PATH_TO_BITFILEDIR)/$(BITFILE_NAME) root@$(BOARD_LOCALHOST_URL):/tmp

# Program the device with the bitfile in the temp dir
rp_program:
	plink -ssh $(BOARD_LOCALHOST_USERNAME)@$(BOARD_LOCALHOST_URL) -pw $(BOARD_LOCALHOST_PASSWORD) -batch \
		"cat /tmp/$(BITFILE_NAME) > /dev/xdevcfg"

# Clean the loaded bitfile from the directory
rp_clean_bitfile:
	plink -ssh $(BOARD_LOCALHOST_USERNAME)@$(BOARD_LOCALHOST_URL) -pw $(BOARD_LOCALHOST_PASSWORD) -batch \
		"pwd; cd /tmp/; pwd; rm $(BITFILE_NAME); exit"

# Program the device with one make target
rp_prog: $(PATH_TO_BITFILEDIR)/$(BITFILE_NAME) 
	make rp_load_bitfile \
		PATH_TO_BITFILEDIR=$(PATH_TO_BITFILEDIR) \
		BITFILE_NAME=$(BITFILE_NAME)
	make rp_program \
		BITFILE_NAME=$(BITFILE_NAME)
	make rp_clean_bitfile \
		BITFILE_NAME=$(BITFILE_NAME)

# Read data from a module at the specified AXI memory address
rp_read:
	plink -ssh $(BOARD_LOCALHOST_USERNAME)@$(BOARD_LOCALHOST_URL) -pw $(BOARD_LOCALHOST_PASSWORD) -batch \
		"for ((i = 1; i <= $(VALUES_CNT); i++)); do /opt/redpitaya/bin/monitor $(ADDRESS); done" > $(COUT_OUTPUT_DIR)/$(COUT_FILENAME)

# Write data to a module at the specified AXI memory address
rp_write:
	plink -ssh $(BOARD_LOCALHOST_USERNAME)@$(BOARD_LOCALHOST_URL) -pw $(BOARD_LOCALHOST_PASSWORD) -batch \
		"/opt/redpitaya/bin/monitor $(ADDRESS) $(RP_CMD)"

# Read/monitor real time data until CTRL+C (infinite loop interrupt)
rp_stream:
	plink -ssh $(BOARD_LOCALHOST_USERNAME)@$(BOARD_LOCALHOST_URL) -pw $(BOARD_LOCALHOST_PASSWORD) -batch \
		"for ((;;)); do /opt/redpitaya/bin/monitor $(ADDRESS); done"


