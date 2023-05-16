# set_property CFGBVS VCCO [current_design]
# set_property CONFIG_VOLTAGE 3.3 [current_design]

############################################################################
## System Clock
############################################################################

# ADC Clock
# set_property IOSTANDARD LVCMOS18 [get_ports in_adc_clk_p]
# set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports in_adc_clk_n]
# set_property PACKAGE_PIN U18 [get_ports in_adc_clk_p]
# set_property PACKAGE_PIN U19 [get_ports in_adc_clk_n]

set_property IOSTANDARD LVCMOS18 [get_ports in_adc_clk_0]
set_property PACKAGE_PIN U18 [get_ports in_adc_clk_0]

# create_clock -name in_adc_clk_0 -period 8.000 [get_ports in_adc_clk_p]
# create_clock -name in_adc_clk_0 -period 8.000 [get_ports in_adc_clk_0]



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
set_property IOSTANDARD LVCMOS33 [get_ports {dac_o_data_0[*]}]
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
set_property IOSTANDARD LVCMOS33 [get_ports dac_o_iqwrt_0]
set_property SLEW FAST [get_ports dac_o_iqwrt_0]
set_property DRIVE 8 [get_ports dac_o_iqwrt_0]
set_property IOB TRUE [get_ports {dac_o_iqwrt_0}]
set_property PACKAGE_PIN M17 [get_ports dac_o_iqwrt_0]

set_property IOSTANDARD LVCMOS33 [get_ports dac_o_iqsel_0]
set_property SLEW FAST [get_ports dac_o_iqsel_0]
set_property DRIVE 8 [get_ports dac_o_iqsel_0]
set_property IOB TRUE [get_ports {dac_o_iqsel_0}]
set_property PACKAGE_PIN N16 [get_ports dac_o_iqsel_0]

set_property IOSTANDARD LVCMOS33 [get_ports dac_o_iqclk_0]
set_property SLEW FAST [get_ports dac_o_iqclk_0]
set_property DRIVE 8 [get_ports dac_o_iqclk_0]
set_property IOB TRUE [get_ports {dac_o_iqclk_0}]
set_property PACKAGE_PIN M18 [get_ports dac_o_iqclk_0]

set_property IOSTANDARD LVCMOS33 [get_ports dac_o_iqrst_0]
set_property SLEW FAST [get_ports dac_o_iqrst_0]
set_property DRIVE 8 [get_ports dac_o_iqrst_0]
set_property IOB TRUE [get_ports {dac_o_iqrst_0}]
set_property PACKAGE_PIN N15 [get_ports dac_o_iqrst_0]


############################################################################
## LED
############################################################################

set_property IOSTANDARD LVCMOS33 [get_ports {leds_0[*]}]
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