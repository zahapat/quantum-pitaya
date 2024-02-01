onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TB: adc_read_tb ALL signals}
add wave -noupdate /adc_read_tb/in_clk
add wave -noupdate /adc_read_tb/i_valid
add wave -noupdate /adc_read_tb/in_dready
add wave -noupdate /adc_read_tb/in_data
add wave -noupdate /adc_read_tb/out_valid
add wave -noupdate /adc_read_tb/out_data
add wave -noupdate /adc_read_tb/i
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {1898400 ps}
