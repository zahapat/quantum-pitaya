# SQDLab FPGA Environment for Quantum Computing

Welcome to the FPGA Environment for Quantum Computing template repository.

This repository is primarily designed for use with the [Xilinx Vivado Design Suite (HLx Edition build 2020.2)](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/archive.html) on Windows platforms.

This repository contains VLSI hardware components, PCB layouts for Red Pitaya boards, and Vivado board files for high-speed data acquisition, clock synthesis, and other purposes within a quantum laboratory.



## Prerequisites

1. [Vivado Design Suite (HLx Edition build 2020.2)](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/archive.html)
2. [ModelSim-Intel® FPGA Standard Edition, Version 20.1std](https://www.intel.com/content/www/us/en/software-kit/750637/modelsim-intel-fpgas-standard-edition-software-version-20-1.html?)
3. [Cygwin](https://www.cygwin.com/install.html) (GNU and Open Source tools for Linux-like functionality on Windows)
4. [App Installer (Winget)](https://apps.microsoft.com/store/detail/app-installer/9NBLGGH4NNS1) available on Microsoft Store.
5. Run all scripts in the directory `'./scripts/installers/win11/'` as an administrator to configure environment variables, install chocolate, Microsoft PowerShell, PuTTY, GitHub CLI (gh), and Make.
6. If you wish to install Python as well, uncomment the fourth line in the `'RunAsAdmin2-InstallEssentialAppsWin11.bat'` file using your text editor or run the following command in your favorite terminal:

    ```shell
    choco install -yes python
    ```
7. After installing all the required software, go to the directory of this environment. Open this directory in your favourite terminal and run:
    ```shell
    make sim_init
    ```
    This will create a modelsim.ini file in the environment's root directory, necessary to launch simulations.


## Description

The tools provided with this repository serve to offer tools and VLSI source files for facilitating the development of FPGA-based projects to build optimal and resource-efficient hardware.

One can find the following subdirectories:

1. Tcl

    `./tcl` contains Tcl scripts that interact with software supporting a Tcl (Tickle) console. They are designed for automating project building and running simulations using CLI (command-line interface).

2. Scripts

    The `'./scripts'` directory consists of the following tools:

   - Python-Notebook-Based FQEnv wrapper and control tool
   - The search for optimal MMCM (Mixed Mode Clock Manager) primitives analyzer for optimal clock synthesis
   - FIR Coefficients Generator
   - Generic parameters generator
   - Data Visualizer after successful readout

3. Modules

    The `./modules` directory serves as a repository of HDL modules created throughout the development. These modules consist of hardware description and Tcl scripts for adding files to Vivado Design Suite and Modelsim in correct compile order.

4. Boards

    This directory serves as a repository of Tcl-based generators of Vivado board `'*.bd'` files necessary to integrate the project cores with various AXI-based components. It is possible to inspect such bd file in Vivado IDE.

5. PCB

    The `'./pcb'` directory contains PCB design source files and gerber files to view, review, modify, or adapt PCB designs to new designs using KiCad. Gerber files can be directly sent to a PCB manufacturer.

6. Do

    The `'./do'` directory contains do scripts that enable launching and compiling source files within ModelSim.

7. Simulator

    The `'./simulator'` directory accompanies scripts in the `./do` directory. This is the output directory of the ModelSim simualtor. Also, it contains other basic do scripts to control simulation via the ModelSim Tcl command-line. Do scripts can be programmed using Tcl.

8. Vivado

    This folder contains the Vivado project. While building the project, report files are being generated to inspect the properties of the hardware being generated, its resource utilization, timing, and more. These properties can also be inspected after launching the `FQEnv.xpr` Vivado project file located in this directory.


## Getting Started

The core unit of the FPGA Environment is the central Makefile located in the root direcotry of this repository. When opened in a text editor, it consists variables in upprecase and make targets which are named based on what one intends to do. For example, the `'make src'` target will add sources to Vivado; and `'make board'` will create and add the bd file to vivado. 

The following example reflects the main implementation flow. Run the following commands in your terminal after navigating to the root directory.

- Reset the environment:
    ```shell
    make reset
    ```

- Add all HDL sources under the given the relative Top file located in modules directory. In this case, the TOP variable defined in the Makefile will be explicitly updated by the desired source:
    ```shell
    make src TOP=top_redpitaya_125_14.sv
    ```

- Generate the Systemcerilog header file with FIR filter coefficients. All command-line arguments (e.g. INT_NUMBER_OF_TAPS, INT_COEF_WIDTH, ...) are be specified the following way:
    ```shell
    make gen_fir_coeff INT_NUMBER_OF_TAPS=13 INT_COEF_WIDTH=15 FLOAT_SAMPLING_FREQUENCY_MHZ=125.0 FLOAT_CUTOFF_FREQUENCY_MHZ=25.0
    ```

- Generate a Systemverilog header file with generic variables for the target Top file located in modules directory. The Top file is specified by updating the 'TOP' variable located in the Makefile, as shown below.
    ```shell
    make generics TOP=top_redpitaya_125_14.sv
    ```

- Run a Tcl script to generate and add the target board file, which includes the schematic system design. The target board file is specified by updating the `'BOARD'` variable declared in the Makefile, as shown below:
    ```shell
    make board BOARD=sqdlab_redpitaya_125_14_extclk
    ```


- Run all stages of implementation: synthesis, implementation, bitstream generation, hw platform generatoin (if applicable)
    ```shell
    make all
    ```


- After successful bitstream generation, the following command will copy the output bitfile together with all report available files to the `./output` directory. The output folder will be created if it does not exist.
    ```shell
    make distribute_outputs
    ```



All the abovementioned steps can be executed at once by running the following make target. This will force re-generate the desired build. You can also specify other parameters, such as GEN1_NAME declared in Makefile:
```shell
make build TOP=top_redpitaya_125_14.sv BOARD=sqdlab_redpitaya_125_14_extclk INT_NUMBER_OF_TAPS=13 INT_COEF_WIDTH=15 FLOAT_SAMPLING_FREQUENCY_MHZ=125.0 FLOAT_CUTOFF_FREQUENCY_MHZ=25.0
```


## Programming the RedPitaya board

A specific daughter Makefile is available with make commands dedicated to control the desired RedPitaya board.

To program the 10-bit RedPitaya board, run the following make command:
```shell
make rp_prog1
```

To program the 14-bit RedPitaya board:
```shell
make rp_prog2
```

To program both:
```shell
make rp_prog12
```

To run linux terminal on the 10-bit RedPitaya board:
```shell
make rp_terminal BOARD_LOCALHOST_URL=rp-f07244.local
```

To run linux terminal on the 14-bit RedPitaya board with external clock capability:
```shell
make rp_terminal BOARD_LOCALHOST_URL=rp-f0afdf.local
```


## Accessing the custom hardware of the RedPitaya board

Reading from and writing to the custom-made hardware modules is performed via AXI-Lite interface. Both `'top_redpitaya_125_10.sv'` and `'top_redpitaya_125_14.sv'` are available at the address offset 0x40600000 of the AXI-Lite address space. The `'axi4lite_fifo_readout.vhd'` as part of both of the abovementioned top modules allows for accessing two read channels and two write channels:

1. Read channel 1: address: `0x40600000` (FPGA->PC CDCC buffer FIFO channel 1)
2. Read channel 2: address: `0x40600004` (FPGA->PC CDCC buffer FIFO channel 2)
3. Write Channel 1 address: `0x40600008` (PC->FPGA CDCC buffer FIFO channel 1)
4. Write channel 2 address: `0x40600009` (PC->FPGA CDCC buffer FIFO channel 2)

Communication between the remote PC and the Red Pitaya board is performed via plink CLI commands (Putty). Read (`rp_read`) and write (`rp_write`) make targets are defined in the `'redpitaya.mk'` file.

To read 1024 values from the CDCC buffer FIFO channel 1, and save the output read_ch1.txt to the outputs directory:
```shell
make rp_read ADDRESS=0x40600000 VALUES_CNT=1024 COUT_OUTPUT_DIR=./outputs/ COUT_FILENAME=read_ch1.txt
```

To read 1024 values from the CDCC buffer FIFO channel 2, and save the output `'read_ch2.txt'` to the outputs directory:
```shell
make rp_read ADDRESS=0x40600004 VALUES_CNT=1024 COUT_OUTPUT_DIR=./outputs/ COUT_FILENAME=read_ch2.txt
```

Writing to the specific modules of the FPGA fabric uses a simple protocol. The write channel 1 uses several bits for command specification, module destination identifier, and one bit serves for concatenating the entire 32-bit wide write channel 2 packet to the write channel 1 packet.

The write channel 1 packet contains the following sections:
- *command* bits: 

    [INT_CMD_OUTPUT_WIDTH+INT_MODULE_SELECT_WIDTH : INT_MODULE_SELECT_WIDTH+1]
- module *destination* bits

    [INT_MODULE_SELECT_WIDTH : 1]
- wait for channel 2 data: 

    [0] must be true (0x1) or false (0x0)

The 32-bit wide channel 2 serves as a data channel. Data will be delivered to the destination specified by the write channel 1. The LSB must be set high to concatenate the channel write 1 with the data in the channel write 2, if needed.

If you do not wish to wait for the channel 2 and only want to send one control command throughout the write channel 1, it is possible to specify the command, module destination, and leave the LSB low. However, the required module must support this. Currently, all modules use the write channel 1 and 2 combination approach.

This example illustrates how to update the time integration value to 5. First, specify the module to be controlled:

- *cmd* = 0x0 (no need to set any of these bits high as data will be  TODO)
- *destination* = 0x3 (module  destination of the averager)
- *wait* = 0x1 (wait for channel 2 data is true)

After concatenating *cmd*, *destination*, and *wait* sections of the packet: [0x0, 0x3, 0x1] = 32'b000...0111 = 0x00000007
```shell
make rp_write ADDRESS=0x40600008 RP_CMD=0x00000007
```

Second, the following command will use the write channel 2 to update the new time integration accumulator value:
```shell
make rp_write ADDRESS=0x40600009 RP_CMD=0x00000005
```

It is possible to use up all 32 bits for it, however, the specified module may extract only a lesser number of bits depending on its input and output width specifications. More specifically, the maximum width of the `averager.sv` module to update the averaging(time integration) value is `ceil log2(INT_AVG_MAX_AVERAGE_BY)`. The `INT_AVG_MAX_AVERAGE_BY` can be updated in the main Makefile, and hardware must be re-created by running `make build` command after having this parameter updated, in case this hardware has not been created yet.

The module address map is the following. Note that module destination = 0 is invalid.
1. module destination = 1: `fifo_multichrdctrl.sv` control (both in-phase and quadrature). Select the channel and the number of reads from the `fifo_accumulator.sv` to the CDCC fifo buffer. 

Example: 
`cmd = 0 (select channel 0)` & `module destination = 1 (averager)` & `wait for channel 2 data = 1 (True)` = 0x00000003
```shell
make rp_write ADDRESS=0x40600008 RP_CMD=0x00000003
```

Use the write channel 2 to set the number of reads from the channel 0 FIFO channel. Let's read all items from the single `fifo_accumulator.sv` channel specified by INT_MULTIACC_FIFO_DEPTH in the Makefile = 1024 (0x00000400):
```shell
make rp_write ADDRESS=0x40600009 RP_CMD=0x00000400
```

2. module destination = 2: `fir_parallel.sv` control (in-phase and quadrature). Update the FIR coefficients by selecting the tap ID and its new value.

Example: 
`cmd = 0 (select tap 0)` & `module destination = 2 (FIR)` & `wait for channel 2 data = 1 (True)` = 0x00000005
```shell
make rp_write ADDRESS=0x40600008 RP_CMD=0x00000005
```

Use the write channel 2 to set the FIR coefficient 0 to a new value, e.g. 0xdeadbeef:
```shell
make rp_write ADDRESS=0x40600009 RP_CMD=0xdeadbeef
```

3. module destination = 3: `averager.sv` control (in-phase and quadrature). An example to control this module has been provided in this section above.

4. TODO: module destination = 4: `fifo_multichannel.sv`to vary the number of accumulation repetitions and multichannel FIFO dimensions instead of having it fixed by INT_MULTIACC_REPETITIONS, INT_MULTIACC_FIFO_DEPTH, and INT_MULTIACC_CHANNELS parameters.



## Usuing the FQEnv Python Notebook Makefile Build and Control Tool

*This area is currently under development and new updates are coming soon.*

This repository also contains the `fqenv.ipynb` file that serves as Python-based control tool instead of using a CLI. Also, such tool can be used as a starting point to integrating this FPGA environment into a higher-level Python ecosystem.

Methods declared in the within the `fqenv.py` allow one to perform each step of the process to build the hardware with defined parameters, program the Red Pitaya FPGA board, and control it remotely via Ethernet.


## Git: Create a New Repository

Update the `GIT_EMAIL` variable in `git.mk`. Use your email address to link Git with your Git account.
Run the following command to create a new private repo:

```shell
$ make git_new_private_repo
```

Run the following command to create a new public repository:

```shell
$ make git_new_public_repo
```

Run the following command to make the repository as a template:

```shell
$ make git_make_this_repo_template
```