onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TB: oscillator_iq_tb ALL signals}
add wave -noupdate /oscillator_iq_tb/clk
add wave -noupdate /oscillator_iq_tb/i_valid
add wave -noupdate /oscillator_iq_tb/o_valid
add wave -noupdate -format Analog-Step -height 74 -max 20864.0 -min -16880.0 /oscillator_iq_tb/o_cos
add wave -noupdate -format Analog-Step -height 74 -max 19840.999999999996 -min -19842.0 /oscillator_iq_tb/o_sin
add wave -noupdate /oscillator_iq_tb/i
add wave -noupdate /oscillator_iq_tb/cos_hw
add wave -noupdate /oscillator_iq_tb/sin_hw
add wave -noupdate /oscillator_iq_tb/cos_sw
add wave -noupdate /oscillator_iq_tb/sin_sw
add wave -noupdate /oscillator_iq_tb/cos_diff
add wave -noupdate /oscillator_iq_tb/sin_diff
add wave -noupdate /oscillator_iq_tb/inst_oscillator_iq_dut/clk
add wave -noupdate /oscillator_iq_tb/inst_oscillator_iq_dut/i_valid
add wave -noupdate /oscillator_iq_tb/inst_oscillator_iq_dut/o_valid
add wave -noupdate /oscillator_iq_tb/inst_oscillator_iq_dut/o_cos
add wave -noupdate /oscillator_iq_tb/inst_oscillator_iq_dut/o_sin
add wave -noupdate -radix binary /oscillator_iq_tb/inst_oscillator_iq_dut/target_angle
add wave -noupdate /oscillator_iq_tb/inst_oscillator_iq_dut/valid
add wave -noupdate /oscillator_iq_tb/inst_oscillator_iq_dut/INCREMENT_COUNTER_BY
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {272000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 442
configure wave -valuecolwidth 265
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
WaveRestoreZoom {789500 ps} {1023800 ps}
