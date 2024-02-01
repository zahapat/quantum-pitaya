onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TB: rom_oscillator_sin_tb ALL signals}
add wave -noupdate /rom_oscillator_sin_tb/clk
add wave -noupdate /rom_oscillator_sin_tb/i_valid
add wave -noupdate /rom_oscillator_sin_tb/o_valid
add wave -noupdate -format Analog-Step -height 74 -max 2042380000.0 -min -2042380000.0 -radix sfixed /rom_oscillator_sin_tb/o_sin
add wave -noupdate /rom_oscillator_sin_tb/inst_rom_oscillator_sin_dut/pointer
add wave -noupdate /rom_oscillator_sin_tb/i
add wave -noupdate /rom_oscillator_sin_tb/sin_hw
add wave -noupdate /rom_oscillator_sin_tb/sin_sw
add wave -noupdate /rom_oscillator_sin_tb/sin_diff
add wave -noupdate /rom_oscillator_sin_tb/inst_rom_oscillator_sin_dut/ANGLE_INCREMENTS
add wave -noupdate /rom_oscillator_sin_tb/inst_rom_oscillator_sin_dut/ROM_VALUES
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {160000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 403
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
WaveRestoreZoom {901100 ps} {1017900 ps}
