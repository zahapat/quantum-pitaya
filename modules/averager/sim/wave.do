onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TB: averager_tb ALL signals}
add wave -noupdate /averager_tb/clk
add wave -noupdate /averager_tb/rst
add wave -noupdate /averager_tb/i_valid
add wave -noupdate /averager_tb/i_data
add wave -noupdate /averager_tb/i_avg_cmd_valid
add wave -noupdate /averager_tb/i_avg_cmd_data
add wave -noupdate /averager_tb/o_valid_integrated
add wave -noupdate /averager_tb/o_valid_averaged
add wave -noupdate /averager_tb/o_data_integrated
add wave -noupdate /averager_tb/o_data_averaged_guotient
add wave -noupdate /averager_tb/o_data_averaged_remainder
add wave -noupdate /averager_tb/i
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {14620000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 350
configure wave -valuecolwidth 306
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
WaveRestoreZoom {111549561 ps} {116507918 ps}
