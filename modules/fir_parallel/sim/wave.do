onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TB: fir_parallel_tb ALL signals}
add wave -noupdate /fir_parallel_tb/clk
add wave -noupdate /fir_parallel_tb/i_valid
add wave -noupdate /fir_parallel_tb/i_data
add wave -noupdate /fir_parallel_tb/i_cmd_valid
add wave -noupdate /fir_parallel_tb/i_cmd
add wave -noupdate /fir_parallel_tb/i_cmd_data
add wave -noupdate /fir_parallel_tb/o_valid
add wave -noupdate /fir_parallel_tb/o_data
add wave -noupdate /fir_parallel_tb/i
add wave -noupdate -expand /fir_parallel_sv_unit::fir_coefficients
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {144781 ps} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {218530 ps} {1281130 ps}
