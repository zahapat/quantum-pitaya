onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TB: rom_oscillator_cos_tb ALL signals}
add wave -noupdate /rom_oscillator_cos_tb/clk
add wave -noupdate /rom_oscillator_cos_tb/i_valid
add wave -noupdate /rom_oscillator_cos_tb/o_valid
add wave -noupdate -format Analog-Step -height 74 -max 663608999.99999988 -min -2147480000.0 -radix sfixed /rom_oscillator_cos_tb/o_cos
add wave -noupdate -radix unsigned -childformat {{{/rom_oscillator_cos_tb/inst_rom_oscillator_cos_dut/pointer[2]} -radix unsigned} {{/rom_oscillator_cos_tb/inst_rom_oscillator_cos_dut/pointer[1]} -radix unsigned} {{/rom_oscillator_cos_tb/inst_rom_oscillator_cos_dut/pointer[0]} -radix unsigned}} -subitemconfig {{/rom_oscillator_cos_tb/inst_rom_oscillator_cos_dut/pointer[2]} {-height 15 -radix unsigned} {/rom_oscillator_cos_tb/inst_rom_oscillator_cos_dut/pointer[1]} {-height 15 -radix unsigned} {/rom_oscillator_cos_tb/inst_rom_oscillator_cos_dut/pointer[0]} {-height 15 -radix unsigned}} /rom_oscillator_cos_tb/inst_rom_oscillator_cos_dut/pointer
add wave -noupdate /rom_oscillator_cos_tb/i
add wave -noupdate /rom_oscillator_cos_tb/cos_hw
add wave -noupdate /rom_oscillator_cos_tb/cos_sw
add wave -noupdate /rom_oscillator_cos_tb/cos_diff
add wave -noupdate /rom_oscillator_cos_tb/inst_rom_oscillator_cos_dut/NUMBER_OF_SAMPLES
add wave -noupdate /rom_oscillator_cos_tb/inst_rom_oscillator_cos_dut/INT_NUMBER_OF_SAMPLES
add wave -noupdate /rom_oscillator_cos_tb/inst_rom_oscillator_cos_dut/ANGLE_INCREMENTS
add wave -noupdate -radix binary -childformat {{{/rom_oscillator_cos_tb/inst_rom_oscillator_cos_dut/ROM_VALUES[4]} -radix binary} {{/rom_oscillator_cos_tb/inst_rom_oscillator_cos_dut/ROM_VALUES[3]} -radix binary} {{/rom_oscillator_cos_tb/inst_rom_oscillator_cos_dut/ROM_VALUES[2]} -radix binary} {{/rom_oscillator_cos_tb/inst_rom_oscillator_cos_dut/ROM_VALUES[1]} -radix binary} {{/rom_oscillator_cos_tb/inst_rom_oscillator_cos_dut/ROM_VALUES[0]} -radix binary}} -radixshowbase 0 -expand -subitemconfig {{/rom_oscillator_cos_tb/inst_rom_oscillator_cos_dut/ROM_VALUES[4]} {-height 15 -radix binary} {/rom_oscillator_cos_tb/inst_rom_oscillator_cos_dut/ROM_VALUES[3]} {-height 15 -radix binary} {/rom_oscillator_cos_tb/inst_rom_oscillator_cos_dut/ROM_VALUES[2]} {-height 15 -radix binary} {/rom_oscillator_cos_tb/inst_rom_oscillator_cos_dut/ROM_VALUES[1]} {-height 15 -radix binary} {/rom_oscillator_cos_tb/inst_rom_oscillator_cos_dut/ROM_VALUES[0]} {-height 15 -radix binary}} /rom_oscillator_cos_tb/inst_rom_oscillator_cos_dut/ROM_VALUES
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {34700 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 385
configure wave -valuecolwidth 222
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
WaveRestoreZoom {853700 ps} {1020400 ps}
