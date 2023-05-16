# -------------------------------------------------------------
#                     MAKEFILE VARIABLES
# -------------------------------------------------------------
# Mandatory variables
PROJ_NAME = $(shell basename $(CURDIR))
PROJ_DIR = $(shell pwd)


# Type the URL that is written or RP Ethernet connector
BOARD_LOCALHOST_URL ?= rp-f07244.local
BOARD_LOCALHOST_USERNAME ?= root
BOARD_LOCALHOST_PASSWORD ?= root

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
	pscp -l $(BOARD_LOCALHOST_USERNAME) -pw $(BOARD_LOCALHOST_PASSWORD) .\vivado\3_bitstream_$(PROJ_NAME).bit root@$(BOARD_LOCALHOST_URL):/tmp

# Program the device with the bitfile in the temp dir
rp_program:
	plink -ssh $(BOARD_LOCALHOST_USERNAME)@$(BOARD_LOCALHOST_URL) -pw $(BOARD_LOCALHOST_PASSWORD) -batch \
		"cat /tmp/3_bitstream_$(PROJ_NAME).bit > /dev/xdevcfg"

# Clean the loaded bitfile from the directory
rp_clean_bitfile:
	plink -ssh $(BOARD_LOCALHOST_USERNAME)@$(BOARD_LOCALHOST_URL) -pw $(BOARD_LOCALHOST_PASSWORD) -batch \
		"pwd; cd /tmp/; pwd; rm 3_bitstream_$(PROJ_NAME).bit; exit"

# Program the device with one target
rp_prog: ./vivado/3_bitstream_$(PROJ_NAME).bit
	make rp_load_bitfile
	make rp_program
	make rp_clean_bitfile

# Read data from a AXI memory address
rp_read:
	plink -ssh $(BOARD_LOCALHOST_USERNAME)@$(BOARD_LOCALHOST_URL) -pw $(BOARD_LOCALHOST_PASSWORD) -batch \
		"for ((i = 1; i <= $(VALUES_CNT); i++)); do /opt/redpitaya/bin/monitor $(ADDRESS); done"

# Read/monitor real time data until CTRL+C (interrupt the infinite loop)
rp_stream:
	plink -ssh $(BOARD_LOCALHOST_USERNAME)@$(BOARD_LOCALHOST_URL) -pw $(BOARD_LOCALHOST_PASSWORD) -batch \
		"for ((;;)); do /opt/redpitaya/bin/monitor $(ADDRESS); done"


