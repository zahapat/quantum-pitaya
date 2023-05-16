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

# set_property IOSTANDARD LVCMOS18 [get_ports in_adc_clk]
# set_property PACKAGE_PIN U18 [get_ports in_adc_clk]

# create_clock -name in_adc_clk -period 8.000 [get_ports in_adc_clk_p]
# create_clock -name in_adc_clk -period 8.000 [get_ports in_adc_clk]



############################################################################
## ADC
############################################################################

# Data: Channel 1
# set_property IOSTANDARD LVCMOS18 [get_ports {in_data_ch1[*]}]
# set_property IOB TRUE [get_ports {in_data_ch1[*]}]

# set_property PACKAGE_PIN W14 [get_ports {in_data_ch1[0]}]
# set_property PACKAGE_PIN Y14 [get_ports {in_data_ch1[1]}]
# set_property PACKAGE_PIN W13 [get_ports {in_data_ch1[2]}]
# set_property PACKAGE_PIN V12 [get_ports {in_data_ch1[3]}]
# set_property PACKAGE_PIN V13 [get_ports {in_data_ch1[4]}]
# set_property PACKAGE_PIN T14 [get_ports {in_data_ch1[5]}]
# set_property PACKAGE_PIN T15 [get_ports {in_data_ch1[6]}]
# set_property PACKAGE_PIN V15 [get_ports {in_data_ch1[7]}]
# set_property PACKAGE_PIN T16 [get_ports {in_data_ch1[8]}]
# set_property PACKAGE_PIN V16 [get_ports {in_data_ch1[9]}]

# Data: Channel 2
# set_property IOSTANDARD LVCMOS18 [get_ports {in_data_ch2[*]}]
# set_property IOB TRUE [get_ports {in_data_ch2[*]}]

# set_property PACKAGE_PIN R19 [get_ports {in_data_ch2[0]}]
# set_property PACKAGE_PIN T20 [get_ports {in_data_ch2[1]}]
# set_property PACKAGE_PIN T19 [get_ports {in_data_ch2[2]}]
# set_property PACKAGE_PIN U20 [get_ports {in_data_ch2[3]}]
# set_property PACKAGE_PIN V20 [get_ports {in_data_ch2[4]}]
# set_property PACKAGE_PIN W20 [get_ports {in_data_ch2[5]}]
# set_property PACKAGE_PIN W19 [get_ports {in_data_ch2[6]}]
# set_property PACKAGE_PIN Y19 [get_ports {in_data_ch2[7]}]
# set_property PACKAGE_PIN W18 [get_ports {in_data_ch2[8]}]
# set_property PACKAGE_PIN Y18 [get_ports {in_data_ch2[9]}]

# Duty Cycle Clock Stabilizer
# set_property IOSTANDARD LVCMOS18 [get_ports adc_i_clkstb]
# set_property PACKAGE_PIN V18 [get_ports adc_i_clkstb]
# set_property SLEW FAST [get_ports adc_i_clkstb]
# set_property DRIVE 8 [get_ports adc_i_clkstb]


############################################################################
## DAC
############################################################################

# DAC Data Signals
# set_property IOSTANDARD LVCMOS33 [get_ports {dac_o_data[*]}]
# set_property SLEW SLOW [get_ports {dac_o_data[*]}]
# set_property DRIVE 4 [get_ports {dac_o_data[*]}]
# set_property IOB TRUE [get_ports {dac_o_data[*]}]


# set_property PACKAGE_PIN K19 [get_ports {dac_o_data[0]}]
# set_property PACKAGE_PIN J19 [get_ports {dac_o_data[1]}]
# set_property PACKAGE_PIN J20 [get_ports {dac_o_data[2]}]
# set_property PACKAGE_PIN H20 [get_ports {dac_o_data[3]}]
# set_property PACKAGE_PIN G19 [get_ports {dac_o_data[4]}]
# set_property PACKAGE_PIN G20 [get_ports {dac_o_data[5]}]
# set_property PACKAGE_PIN F19 [get_ports {dac_o_data[6]}]
# set_property PACKAGE_PIN F20 [get_ports {dac_o_data[7]}]
# set_property PACKAGE_PIN D20 [get_ports {dac_o_data[8]}]
# set_property PACKAGE_PIN D19 [get_ports {dac_o_data[9]}]

# DAC IQ Control Signals
# set_property IOSTANDARD LVCMOS33 [get_ports dac_o_iqwrt]
# set_property SLEW FAST [get_ports dac_o_iqwrt]
# set_property DRIVE 8 [get_ports dac_o_iqwrt]
# set_property IOB TRUE [get_ports {dac_o_iqwrt}]
# set_property PACKAGE_PIN M17 [get_ports dac_o_iqwrt]

# set_property IOSTANDARD LVCMOS33 [get_ports dac_o_iqsel]
# set_property SLEW FAST [get_ports dac_o_iqsel]
# set_property DRIVE 8 [get_ports dac_o_iqsel]
# set_property IOB TRUE [get_ports {dac_o_iqsel}]
# set_property PACKAGE_PIN N16 [get_ports dac_o_iqsel]

# set_property IOSTANDARD LVCMOS33 [get_ports dac_o_iqclk]
# set_property SLEW FAST [get_ports dac_o_iqclk]
# set_property DRIVE 8 [get_ports dac_o_iqclk]
# set_property IOB TRUE [get_ports {dac_o_iqclk}]
# set_property PACKAGE_PIN M18 [get_ports dac_o_iqclk]

# set_property IOSTANDARD LVCMOS33 [get_ports dac_o_iqrst]
# set_property SLEW FAST [get_ports dac_o_iqrst]
# set_property DRIVE 8 [get_ports dac_o_iqrst]
# set_property IOB TRUE [get_ports {dac_o_iqrst}]
# set_property PACKAGE_PIN N15 [get_ports dac_o_iqrst]


############################################################################
## LED
############################################################################

# set_property IOSTANDARD LVCMOS33 [get_ports {leds[*]}]
# set_property SLEW SLOW [get_ports {leds[*]}]
# set_property DRIVE 8 [get_ports {leds[*]}]

# set_property PACKAGE_PIN F16 [get_ports {leds[0]}]
# set_property PACKAGE_PIN F17 [get_ports {leds[1]}]
# set_property PACKAGE_PIN G15 [get_ports {leds[2]}]
# set_property PACKAGE_PIN H15 [get_ports {leds[3]}]
# set_property PACKAGE_PIN K14 [get_ports {leds[4]}]
# set_property PACKAGE_PIN G14 [get_ports {leds[5]}]
# set_property PACKAGE_PIN J15 [get_ports {leds[6]}]
# set_property PACKAGE_PIN J14 [get_ports {leds[7]}]