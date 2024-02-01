onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TB: dsp_path_tb ALL signals}
add wave -noupdate /dsp_path_tb/clk
add wave -noupdate /dsp_path_tb/rst
add wave -noupdate /dsp_path_tb/i_valid
add wave -noupdate /dsp_path_tb/o_valid
add wave -noupdate /dsp_path_tb/o_data_i
add wave -noupdate /dsp_path_tb/o_data_q
add wave -noupdate /dsp_path_tb/clk_iq
add wave -noupdate /dsp_path_tb/cos_value
add wave -noupdate /dsp_path_tb/sin_value
add wave -noupdate /dsp_path_tb/iq_increment
add wave -noupdate -format Analog-Step -height 74 -max 361.0 -min -361.0 /dsp_path_tb/iq_value
add wave -noupdate -format Analog-Step -height 74 -max 361.0 -min -361.0 /dsp_path_tb/i_data
add wave -noupdate -format Analog-Step -height 74 -max 175446.0 -min -175446.0 -radix ufixed /dsp_path_tb/inst_dsp_path_dut/inst_ddc/sin_value_multiplied
add wave -noupdate -format Analog-Step -height 74 -max 211906.00000000003 -min -211662.0 -radix ufixed /dsp_path_tb/inst_dsp_path_dut/conn_data_i_ddc_averager
add wave -noupdate -format Analog-Step -height 74 -max 346799.0 -min -323601.0 -radix ufixed /dsp_path_tb/inst_dsp_path_dut/o_data_i
add wave -noupdate -format Analog-Step -height 74 -max 184471.0 -min -184471.0 -radix ufixed /dsp_path_tb/inst_dsp_path_dut/inst_ddc/cos_value_multiplied
add wave -noupdate -format Analog-Step -height 74 -max 220861.99999999997 -min -219626.0 -radix ufixed /dsp_path_tb/inst_dsp_path_dut/conn_data_q_ddc_averager
add wave -noupdate -format Analog-Step -height 74 -max 329305.00000000006 -min -322813.0 -radix ufixed /dsp_path_tb/inst_dsp_path_dut/o_data_q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {308000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 357
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {8006876 ps} {8214375 ps}
