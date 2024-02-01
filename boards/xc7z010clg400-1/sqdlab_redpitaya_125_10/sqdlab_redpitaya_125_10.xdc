
set_property CFGBVS VCCO [current_design]
# set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CONFIG_VOLTAGE 2.5 [current_design]


############################################################################
## ADC System Clock
############################################################################

# Clock Input from ADC
set_property IOSTANDARD LVCMOS18 [get_ports in_adc_clk_p_0]
set_property PACKAGE_PIN U18 [get_ports in_adc_clk_p_0]

create_clock -name in_adc_clk_p_0 -period 8.000 [get_ports in_adc_clk_p_0]


############################################################################
## ADC
############################################################################

# Data: Channel 1
set_property IOSTANDARD LVCMOS18 [get_ports {in_data_ch1_0[*]}]
set_property IOB TRUE [get_ports {in_data_ch1_0[*]}]

set_property PACKAGE_PIN W14 [get_ports {in_data_ch1_0[0]}]
set_property PACKAGE_PIN Y14 [get_ports {in_data_ch1_0[1]}]
set_property PACKAGE_PIN W13 [get_ports {in_data_ch1_0[2]}]
set_property PACKAGE_PIN V12 [get_ports {in_data_ch1_0[3]}]
set_property PACKAGE_PIN V13 [get_ports {in_data_ch1_0[4]}]
set_property PACKAGE_PIN T14 [get_ports {in_data_ch1_0[5]}]
set_property PACKAGE_PIN T15 [get_ports {in_data_ch1_0[6]}]
set_property PACKAGE_PIN V15 [get_ports {in_data_ch1_0[7]}]
set_property PACKAGE_PIN T16 [get_ports {in_data_ch1_0[8]}]
set_property PACKAGE_PIN V16 [get_ports {in_data_ch1_0[9]}]

# Data: Channel 2
set_property IOSTANDARD LVCMOS18 [get_ports {in_data_ch2_0[*]}]
set_property IOB TRUE [get_ports {in_data_ch2_0[*]}]

set_property PACKAGE_PIN R19 [get_ports {in_data_ch2_0[0]}]
set_property PACKAGE_PIN T20 [get_ports {in_data_ch2_0[1]}]
set_property PACKAGE_PIN T19 [get_ports {in_data_ch2_0[2]}]
set_property PACKAGE_PIN U20 [get_ports {in_data_ch2_0[3]}]
set_property PACKAGE_PIN V20 [get_ports {in_data_ch2_0[4]}]
set_property PACKAGE_PIN W20 [get_ports {in_data_ch2_0[5]}]
set_property PACKAGE_PIN W19 [get_ports {in_data_ch2_0[6]}]
set_property PACKAGE_PIN Y19 [get_ports {in_data_ch2_0[7]}]
set_property PACKAGE_PIN W18 [get_ports {in_data_ch2_0[8]}]
set_property PACKAGE_PIN Y18 [get_ports {in_data_ch2_0[9]}]

# Duty Cycle Clock Stabilizer
set_property IOSTANDARD LVCMOS18 [get_ports adc_i_clkstb_0]
set_property PACKAGE_PIN V18 [get_ports adc_i_clkstb_0]
set_property SLEW FAST [get_ports adc_i_clkstb_0]
set_property DRIVE 8 [get_ports adc_i_clkstb_0]


############################################################################
## DAC
############################################################################

# DAC Data Signals
# set_property IOSTANDARD LVCMOS33 [get_ports {dac_o_data_0[*]}]
set_property IOSTANDARD LVCMOS25 [get_ports {dac_o_data_0[*]}]
set_property SLEW SLOW [get_ports {dac_o_data_0[*]}]
set_property DRIVE 4 [get_ports {dac_o_data_0[*]}]
# set_property IOB TRUE [get_ports {dac_o_data_0[*]}]


set_property PACKAGE_PIN K19 [get_ports {dac_o_data_0[0]}]
set_property PACKAGE_PIN J19 [get_ports {dac_o_data_0[1]}]
set_property PACKAGE_PIN J20 [get_ports {dac_o_data_0[2]}]
set_property PACKAGE_PIN H20 [get_ports {dac_o_data_0[3]}]
set_property PACKAGE_PIN G19 [get_ports {dac_o_data_0[4]}]
set_property PACKAGE_PIN G20 [get_ports {dac_o_data_0[5]}]
set_property PACKAGE_PIN F19 [get_ports {dac_o_data_0[6]}]
set_property PACKAGE_PIN F20 [get_ports {dac_o_data_0[7]}]
set_property PACKAGE_PIN D20 [get_ports {dac_o_data_0[8]}]
set_property PACKAGE_PIN D19 [get_ports {dac_o_data_0[9]}]

# DAC IQ Control Signals
# set_property IOSTANDARD LVCMOS33 [get_ports dac_o_iqwrt_0]
set_property IOSTANDARD LVCMOS25 [get_ports dac_o_iqwrt_0]
set_property SLEW FAST [get_ports dac_o_iqwrt_0]
set_property DRIVE 8 [get_ports dac_o_iqwrt_0]
set_property IOB TRUE [get_ports {dac_o_iqwrt_0}]
set_property PACKAGE_PIN M17 [get_ports dac_o_iqwrt_0]

# set_property IOSTANDARD LVCMOS33 [get_ports dac_o_iqsel_0]
set_property IOSTANDARD LVCMOS25 [get_ports dac_o_iqsel_0]
set_property SLEW FAST [get_ports dac_o_iqsel_0]
set_property DRIVE 8 [get_ports dac_o_iqsel_0]
set_property IOB TRUE [get_ports {dac_o_iqsel_0}]
set_property PACKAGE_PIN N16 [get_ports dac_o_iqsel_0]

# set_property IOSTANDARD LVCMOS33 [get_ports dac_o_iqclk_0]
set_property IOSTANDARD LVCMOS25 [get_ports dac_o_iqclk_0]
set_property SLEW FAST [get_ports dac_o_iqclk_0]
set_property DRIVE 8 [get_ports dac_o_iqclk_0]
set_property IOB TRUE [get_ports {dac_o_iqclk_0}]
set_property PACKAGE_PIN M18 [get_ports dac_o_iqclk_0]

# set_property IOSTANDARD LVCMOS33 [get_ports dac_o_iqrst_0]
set_property IOSTANDARD LVCMOS25 [get_ports dac_o_iqrst_0]
set_property SLEW FAST [get_ports dac_o_iqrst_0]
set_property DRIVE 8 [get_ports dac_o_iqrst_0]
set_property IOB TRUE [get_ports {dac_o_iqrst_0}]
set_property PACKAGE_PIN N15 [get_ports dac_o_iqrst_0]


############################################################################
## LEDS
############################################################################

# set_property IOSTANDARD LVCMOS33 [get_ports {leds_0[*]}]
set_property IOSTANDARD LVCMOS25 [get_ports {leds_0[*]}]
set_property SLEW SLOW [get_ports {leds_0[*]}]
set_property DRIVE 8 [get_ports {leds_0[*]}]

set_property PACKAGE_PIN F16 [get_ports {leds_0[0]}]
set_property PACKAGE_PIN F17 [get_ports {leds_0[1]}]
set_property PACKAGE_PIN G15 [get_ports {leds_0[2]}]
set_property PACKAGE_PIN H15 [get_ports {leds_0[3]}]
set_property PACKAGE_PIN K14 [get_ports {leds_0[4]}]
set_property PACKAGE_PIN G14 [get_ports {leds_0[5]}]
set_property PACKAGE_PIN J15 [get_ports {leds_0[6]}]
set_property PACKAGE_PIN J14 [get_ports {leds_0[7]}]



############################################################################
## EXPANSION CONNECTOR 1
############################################################################

# NOTE:
# [Place 30-574] Poor placement for routing between an IO pin and BUFG. If this sub optimal condition is acceptable for this design, you may use the CLOCK_DEDICATED_ROUTE constraint in the .xdc file to demote this message to a WARNING. However, the use of this override is highly discouraged. These examples can be used directly in the .xdc file to override this clock rule.
# < set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets i_ext_clk_0_IBUF] >

# i_ext_clk_0_IBUF_inst (IBUF.O) is locked to IOB_X0Y51
#  and sqdlab_redpitaya_125_10_i/top_redpitaya_125_10_0/inst/inst_top_redpitaya_125_10/inst_adc_clk_bufg2 (BUFG.I) 
#  is provisionally placed by clockplacer on BUFGCTRL_X0Y19

# Reasons for the following step:
# The 10 MHz clock input is lower than the allowed frequency range of a PLL (19 MHz)
# MMCM does support 10 MHz input signal, however, due to the location mismatch
# of the MMCM and the CC pin, placer cannot find a solution for routing the
# CC pin to the clock tree without significant time delays. This may result in
# timing violations.
# However, the output of the MMCM goes straight to the output of the device,
# thus no logic will be driven by this signal. Hence, the following command can
# be used to allow routing the CC and MMCM not only via via CLOCK_DEDICATED_ROUTE, 
# but also via routes in the programmable fabric:
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets i_ext_clk_0_IBUF]


# DIO1_N (on PCB brk board: sclk)
set_property IOSTANDARD LVCMOS25 [get_ports {i_ext_clk_0}]
set_property IOB TRUE [get_ports {i_ext_clk_0}]
set_property SLEW FAST [get_ports {i_ext_clk_0}]
# set_property DRIVE 8 [get_ports {i_ext_clk_0}]
set_property PACKAGE_PIN H16 [get_ports {i_ext_clk_0}]

create_clock -name i_ext_clk_0 -period 100.000 [get_ports i_ext_clk_0]

# DIO0_P (on PCB brk board: mosi)
# set_property IOSTANDARD LVDS_25 [get_ports {o_clk_lvds_p_0}]
set_property IOSTANDARD LVCMOS25 [get_ports {o_clk_lvds_p_0}]
# set_property IOB TRUE [get_ports {o_clk_lvds_p_0}]
# set_property SLEW FAST [get_ports {o_clk_lvds_p_0}]
# set_property DRIVE 8 [get_ports {o_clk_lvds_p_0}]
set_property PACKAGE_PIN G17 [get_ports {o_clk_lvds_p_0}]

# DIO0_N (on PCB brk board: miso)
# set_property IOSTANDARD LVDS_25 [get_ports {o_clk_lvds_n_0}]
set_property IOSTANDARD LVCMOS25 [get_ports {o_clk_lvds_n_0}]
# set_property IOB TRUE [get_ports {o_clk_lvds_n_0}]
# set_property SLEW FAST [get_ports {o_clk_lvds_n_0}]
# set_property DRIVE 8 [get_ports {o_clk_lvds_n_0}]
set_property PACKAGE_PIN G18 [get_ports {o_clk_lvds_n_0}]


# DIO1_N (on PCB brk board: analog_input_3)
set_property IOSTANDARD LVCMOS25 [get_ports {i_acc_trigger_1_0}]
set_property IOB TRUE [get_ports {i_acc_trigger_1_0}]
set_property SLEW FAST [get_ports {i_acc_trigger_1_0}]
# set_property DRIVE 8 [get_ports {i_ext_clk_0}]
set_property PACKAGE_PIN J16 [get_ports {i_acc_trigger_1_0}]



############################################################################
## EXPANSION CONNECTOR 2
############################################################################

# Analog Input Ports *NOT USED*
# set_property IOSTANDARD LVCMOS33 [get_ports {analog_in_p_0[*]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {analog_in_n_0[*]}]
# set_property SLEW FAST [get_ports {analog_in_p_0[*]}]
# set_property SLEW FAST [get_ports {analog_in_n_0[*]}]
# set_property DRIVE 8 [get_ports {analog_in_p_0[*]}]
# set_property DRIVE 8 [get_ports {analog_in_n_0[*]}]

# set_property PACKAGE_PIN B19 [get_ports {analog_in_p_0[0]}] # AIFP0
# set_property PACKAGE_PIN A20 [get_ports {analog_in_n_0[0]}] # AIFN0
# set_property PACKAGE_PIN C20 [get_ports {analog_in_p_0[1]}] # AIFP1
# set_property PACKAGE_PIN B20 [get_ports {analog_in_n_0[1]}] # AIFN1
# set_property PACKAGE_PIN E17 [get_ports {analog_in_p_0[2]}] # AIFP2
# set_property PACKAGE_PIN D18 [get_ports {analog_in_n_0[2]}] # AIFN2
# set_property PACKAGE_PIN E18 [get_ports {analog_in_p_0[3]}] # AIFP3
# set_property PACKAGE_PIN E19 [get_ports {analog_in_n_0[3]}] # AIFN3