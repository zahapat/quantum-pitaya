
# set_property CFGBVS VCCO [current_design]
# set_property CONFIG_VOLTAGE 3.3 [current_design]


############################################################################
## ADC System Clock
############################################################################

# Clock Input from ADC
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports in_adc_clk_p_0]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports in_adc_clk_n_0]
set_property PACKAGE_PIN U18 [get_ports in_adc_clk_p_0]
set_property PACKAGE_PIN U19 [get_ports in_adc_clk_n_0]

# Clock Output
# set_property IOSTANDARD LVCMOS18 [get_ports adc_enc_p_o]
# set_property IOSTANDARD LVCMOS18 [get_ports adc_enc_n_o]
# set_property SLEW FAST [get_ports adc_enc_p_o]
# set_property SLEW FAST [get_ports adc_enc_n_o]
# set_property DRIVE 8 [get_ports adc_enc_p_o]
# set_property DRIVE 8 [get_ports adc_enc_n_o]
# set_property PACKAGE_PIN N20 [get_ports adc_enc_p_o]
# set_property PACKAGE_PIN P20 [get_ports adc_enc_n_o]


############################################################################
## ADC
############################################################################

# ADC Data Signals
set_property IOSTANDARD LVCMOS18 [get_ports {in_data_ch*_0[*]}]
set_property IOB TRUE [get_ports {in_data_ch*_0[*]}]

set_property PACKAGE_PIN Y17 [get_ports {in_data_ch1_0[0]}]
set_property PACKAGE_PIN W16 [get_ports {in_data_ch1_0[1]}]
set_property PACKAGE_PIN Y16 [get_ports {in_data_ch1_0[2]}]
set_property PACKAGE_PIN W15 [get_ports {in_data_ch1_0[3]}]
set_property PACKAGE_PIN W14 [get_ports {in_data_ch1_0[4]}]
set_property PACKAGE_PIN Y14 [get_ports {in_data_ch1_0[5]}]
set_property PACKAGE_PIN W13 [get_ports {in_data_ch1_0[6]}]
set_property PACKAGE_PIN V12 [get_ports {in_data_ch1_0[7]}]
set_property PACKAGE_PIN V13 [get_ports {in_data_ch1_0[8]}]
set_property PACKAGE_PIN T14 [get_ports {in_data_ch1_0[9]}]
set_property PACKAGE_PIN T15 [get_ports {in_data_ch1_0[10]}]
set_property PACKAGE_PIN V15 [get_ports {in_data_ch1_0[11]}]
set_property PACKAGE_PIN T16 [get_ports {in_data_ch1_0[12]}]
set_property PACKAGE_PIN V16 [get_ports {in_data_ch1_0[13]}]

set_property PACKAGE_PIN R18 [get_ports {in_data_ch2_0[0]}]
set_property PACKAGE_PIN P16 [get_ports {in_data_ch2_0[1]}]
set_property PACKAGE_PIN P18 [get_ports {in_data_ch2_0[2]}]
set_property PACKAGE_PIN N17 [get_ports {in_data_ch2_0[3]}]
set_property PACKAGE_PIN R19 [get_ports {in_data_ch2_0[4]}]
set_property PACKAGE_PIN T20 [get_ports {in_data_ch2_0[5]}]
set_property PACKAGE_PIN T19 [get_ports {in_data_ch2_0[6]}]
set_property PACKAGE_PIN U20 [get_ports {in_data_ch2_0[7]}]
set_property PACKAGE_PIN V20 [get_ports {in_data_ch2_0[8]}]
set_property PACKAGE_PIN W20 [get_ports {in_data_ch2_0[9]}]
set_property PACKAGE_PIN W19 [get_ports {in_data_ch2_0[10]}]
set_property PACKAGE_PIN Y19 [get_ports {in_data_ch2_0[11]}]
set_property PACKAGE_PIN W18 [get_ports {in_data_ch2_0[12]}]
set_property PACKAGE_PIN Y18 [get_ports {in_data_ch2_0[13]}]

# ADC Clock Duty Cycle Stabilizer (CSn)
set_property IOSTANDARD LVCMOS18 [get_ports adc_i_clkstb_0]
set_property PACKAGE_PIN V18 [get_ports adc_i_clkstb_0]
set_property SLEW FAST [get_ports adc_i_clkstb_0]
set_property DRIVE 8 [get_ports adc_i_clkstb_0]


############################################################################
## DAC
############################################################################

# DAC Data Signals
# set_property IOB TRUE [get_ports {dac_dat_o[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dac_o_data_0[*]}]
set_property SLEW SLOW [get_ports {dac_o_data_0[*]}]
set_property DRIVE 4 [get_ports {dac_o_data_0[*]}]

set_property PACKAGE_PIN M19 [get_ports {dac_o_data_0[0]}]
set_property PACKAGE_PIN M20 [get_ports {dac_o_data_0[1]}]
set_property PACKAGE_PIN L19 [get_ports {dac_o_data_0[2]}]
set_property PACKAGE_PIN L20 [get_ports {dac_o_data_0[3]}]
set_property PACKAGE_PIN K19 [get_ports {dac_o_data_0[4]}]
set_property PACKAGE_PIN J19 [get_ports {dac_o_data_0[5]}]
set_property PACKAGE_PIN J20 [get_ports {dac_o_data_0[6]}]
set_property PACKAGE_PIN H20 [get_ports {dac_o_data_0[7]}]
set_property PACKAGE_PIN G19 [get_ports {dac_o_data_0[8]}]
set_property PACKAGE_PIN G20 [get_ports {dac_o_data_0[9]}]
set_property PACKAGE_PIN F19 [get_ports {dac_o_data_0[10]}]
set_property PACKAGE_PIN F20 [get_ports {dac_o_data_0[11]}]
set_property PACKAGE_PIN D20 [get_ports {dac_o_data_0[12]}]
set_property PACKAGE_PIN D19 [get_ports {dac_o_data_0[13]}]

# DAC IQ Control Signals
# set_property IOB TRUE [get_ports {dac_o_iq*_o}]
set_property IOSTANDARD LVCMOS33 [get_ports dac_o_iq*_0]
set_property SLEW FAST [get_ports dac_o_iq*_0]
set_property DRIVE 8 [get_ports dac_o_iq*_0]

set_property PACKAGE_PIN M17 [get_ports dac_o_iqwrt_0]
set_property PACKAGE_PIN N16 [get_ports dac_o_iqsel_0]
set_property PACKAGE_PIN M18 [get_ports dac_o_iqclk_0]
set_property PACKAGE_PIN N15 [get_ports dac_o_iqrst_0]


############################################################################
## PWM
############################################################################

# set_property IOSTANDARD LVCMOS18 [get_ports {dac_pwm_o[*]}]
# set_property SLEW FAST [get_ports {dac_pwm_o[*]}]
# set_property DRIVE 12 [get_ports {dac_pwm_o[*]}]
# set_property IOB TRUE [get_ports {dac_pwm_o[*]}]
# set_property PACKAGE_PIN T10 [get_ports {dac_pwm_o[0]}]
# set_property PACKAGE_PIN T11 [get_ports {dac_pwm_o[1]}]
# set_property PACKAGE_PIN P15 [get_ports {dac_pwm_o[2]}]
# set_property PACKAGE_PIN U13 [get_ports {dac_pwm_o[3]}]


############################################################################
## XADC
############################################################################

# set_property IOSTANDARD LVCMOS33 [get_ports Vp_Vn_v_p]
# set_property IOSTANDARD LVCMOS33 [get_ports Vp_Vn_v_n]
# set_property IOSTANDARD LVCMOS33 [get_ports Vaux0_v_p]
# set_property IOSTANDARD LVCMOS33 [get_ports Vaux0_v_n]
# set_property IOSTANDARD LVCMOS33 [get_ports Vaux1_v_p]
# set_property IOSTANDARD LVCMOS33 [get_ports Vaux1_v_n]
# set_property IOSTANDARD LVCMOS33 [get_ports Vaux8_v_p]
# set_property IOSTANDARD LVCMOS33 [get_ports Vaux8_v_n]
# set_property IOSTANDARD LVCMOS33 [get_ports Vaux9_v_p]
# set_property IOSTANDARD LVCMOS33 [get_ports Vaux9_v_n]
# set_property PACKAGE_PIN K9  [get_ports Vp_Vn_v_p]
# set_property PACKAGE_PIN L10 [get_ports Vp_Vn_v_n]
# set_property PACKAGE_PIN C20 [get_ports Vaux0_v_p]
# set_property PACKAGE_PIN B20 [get_ports Vaux0_v_n]
# set_property PACKAGE_PIN E17 [get_ports Vaux1_v_p]
# set_property PACKAGE_PIN D18 [get_ports Vaux1_v_n]
# set_property PACKAGE_PIN B19 [get_ports Vaux8_v_p]
# set_property PACKAGE_PIN A20 [get_ports Vaux8_v_n]
# set_property PACKAGE_PIN E18 [get_ports Vaux9_v_p]
# set_property PACKAGE_PIN E19 [get_ports Vaux9_v_n]


############################################################################
## EXPANSION CONNECTOR 1
############################################################################

# DIO6_N (on PCB brk board: analog_in_3)
set_property IOSTANDARD LVCMOS33 [get_ports {i_acc_trigger_1_0}]
set_property IOB TRUE [get_ports {i_acc_trigger_1_0}]
# set_property SLEW FAST [get_ports {i_acc_trigger_1_0}]
# set_property DRIVE 8 [get_ports {i_acc_trigger_1_0}]
set_property PACKAGE_PIN J16 [get_ports {i_acc_trigger_1_0}]

# DIO5_P (on PCB brk board: analog_in_0)
set_property IOSTANDARD LVCMOS33 [get_ports {i_acc_trigger_2_0}]
set_property IOB TRUE [get_ports {i_acc_trigger_2_0}]
# set_property SLEW FAST [get_ports {i_acc_trigger_2_0}]
# set_property DRIVE 8 [get_ports {i_acc_trigger_2_0}]
set_property PACKAGE_PIN L16 [get_ports {i_acc_trigger_2_0}]


# set_property IOSTANDARD LVCMOS33 [get_ports {exp_p_tri_io[*]}]
# set_property PULLTYPE PULLUP [get_ports {exp_p_tri_io[*]}]
# set_property SLEW FAST [get_ports {exp_p_tri_io[*]}]
# set_property DRIVE 8 [get_ports {exp_p_tri_io[*]}]
# set_property PACKAGE_PIN G17 [get_ports {exp_p_tri_io[0]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {exp_p_tri_io[*]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {exp_n_tri_io[*]}]
# set_property SLEW FAST [get_ports {exp_p_tri_io[*]}]
# set_property SLEW FAST [get_ports {exp_n_tri_io[*]}]
# set_property DRIVE 8 [get_ports {exp_p_tri_io[*]}]
# set_property DRIVE 8 [get_ports {exp_n_tri_io[*]}]
# set_property PULLTYPE PULLUP [get_ports {exp_p_tri_io[*]}]
# set_property PULLTYPE PULLUP [get_ports {exp_n_tri_io[*]}]
# set_property PACKAGE_PIN G17 [get_ports {exp_p_tri_io[0]}]
# set_property PACKAGE_PIN G18 [get_ports {exp_n_tri_io[0]}]
# set_property PACKAGE_PIN H16 [get_ports {exp_p_tri_io[1]}]
# set_property PACKAGE_PIN H17 [get_ports {exp_n_tri_io[1]}]
# set_property PACKAGE_PIN J18 [get_ports {exp_p_tri_io[2]}]
# set_property PACKAGE_PIN H18 [get_ports {exp_n_tri_io[2]}]
# set_property PACKAGE_PIN K17 [get_ports {exp_p_tri_io[3]}]
# set_property PACKAGE_PIN K18 [get_ports {exp_n_tri_io[3]}]
# set_property PACKAGE_PIN L14 [get_ports {exp_p_tri_io[4]}]
# set_property PACKAGE_PIN L15 [get_ports {exp_n_tri_io[4]}]
# set_property PACKAGE_PIN L16 [get_ports {exp_p_tri_io[5]}]
# set_property PACKAGE_PIN L17 [get_ports {exp_n_tri_io[5]}]
# set_property PACKAGE_PIN K16 [get_ports {exp_p_tri_io[6]}]
# set_property PACKAGE_PIN J16 [get_ports {exp_n_tri_io[6]}]
# set_property PACKAGE_PIN M14 [get_ports {exp_p_tri_io[7]}]
# set_property PACKAGE_PIN M15 [get_ports {exp_n_tri_io[7]}]


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


# # Analog Output Ports
# set_property IOSTANDARD LVCMOS33 [get_ports {analog_out_0[*]}]
# set_property SLEW FAST [get_ports {analog_out_0[*]}]
# set_property DRIVE 8 [get_ports {analog_out_0[*]}]
# set_property PACKAGE_PIN T10 [get_ports {analog_out_0[0]}] # AOF0
# set_property PACKAGE_PIN T11 [get_ports {analog_out_0[1]}] # AOF1
# set_property PACKAGE_PIN P15 [get_ports {analog_out_0[2]}] # AOF2
# set_property PACKAGE_PIN U13 [get_ports {analog_out_0[3]}] # AOF3


############################################################################
## SATA CONNECTOR
############################################################################

# set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports daisy_p_o[*]]
# set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports daisy_n_o[*]]
# set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports daisy_p_i[*]]
# set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports daisy_n_i[*]]
# set_property PACKAGE_PIN T12 [get_ports {daisy_p_o[0]}]
# set_property PACKAGE_PIN U12 [get_ports {daisy_n_o[0]}]
# set_property PACKAGE_PIN U14 [get_ports {daisy_p_o[1]}]
# set_property PACKAGE_PIN U15 [get_ports {daisy_n_o[1]}]
# set_property PACKAGE_PIN P14 [get_ports {daisy_p_i[0]}]
# set_property PACKAGE_PIN R14 [get_ports {daisy_n_i[0]}]
# set_property PACKAGE_PIN N18 [get_ports {daisy_p_i[1]}]
# set_property PACKAGE_PIN P19 [get_ports {daisy_n_i[1]}]


############################################################################
## LEDS
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