onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TB: ddc_tb ALL signals}
add wave -noupdate /ddc_tb/clk
add wave -noupdate /ddc_tb/rst
add wave -noupdate /ddc_tb/i_valid
add wave -noupdate /ddc_tb/i_data
add wave -noupdate /ddc_tb/o_valid
add wave -noupdate /ddc_tb/o_data_i
add wave -noupdate /ddc_tb/o_data_q
add wave -noupdate /ddc_tb/i
add wave -noupdate /ddc_tb/inst_ddc_dut/clk
add wave -noupdate /ddc_tb/inst_ddc_dut/rst
add wave -noupdate /ddc_tb/inst_ddc_dut/i_valid
add wave -noupdate /ddc_tb/inst_ddc_dut/i_data
add wave -noupdate /ddc_tb/inst_ddc_dut/o_valid
add wave -noupdate /ddc_tb/inst_ddc_dut/o_data_i
add wave -noupdate /ddc_tb/inst_ddc_dut/o_data_q
add wave -noupdate /ddc_tb/inst_ddc_dut/valid_downsampling
add wave -noupdate /ddc_tb/inst_ddc_dut/valid_downsampling_opipe
add wave -noupdate /ddc_tb/inst_ddc_dut/counter_downsampling
add wave -noupdate /ddc_tb/inst_ddc_dut/sin_pointer
add wave -noupdate /ddc_tb/inst_ddc_dut/cos_pointer
add wave -noupdate /ddc_tb/inst_ddc_dut/sin_value_multiplied
add wave -noupdate /ddc_tb/inst_ddc_dut/cos_value_multiplied
add wave -noupdate /ddc_tb/inst_ddc_dut/ROM_VALUES_SIN
add wave -noupdate -childformat {{{/ddc_tb/inst_ddc_dut/ROM_VALUES_COS[3]} -radix binary}} -subitemconfig {{/ddc_tb/inst_ddc_dut/ROM_VALUES_COS[3]} {-height 15 -radix binary}} /ddc_tb/inst_ddc_dut/ROM_VALUES_COS
add wave -noupdate /ddc_tb/inst_ddc_dut/inst_fir_parallel_i/clk
add wave -noupdate /ddc_tb/inst_ddc_dut/inst_fir_parallel_i/i_valid
add wave -noupdate /ddc_tb/inst_ddc_dut/inst_fir_parallel_i/i_data
add wave -noupdate /ddc_tb/inst_ddc_dut/inst_fir_parallel_i/o_valid
add wave -noupdate /ddc_tb/inst_ddc_dut/inst_fir_parallel_i/o_data
add wave -noupdate /ddc_tb/inst_ddc_dut/inst_fir_parallel_i/valid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4132000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 326
configure wave -valuecolwidth 70
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
configure wave -timelineunits ns
update
WaveRestoreZoom {4793289 ps} {5052985 ps}
