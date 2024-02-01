onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TB: cordic_sin_cos_tb ALL signals}
add wave -noupdate /cordic_sin_cos_tb/clk
add wave -noupdate /cordic_sin_cos_tb/i_valid
add wave -noupdate /cordic_sin_cos_tb/i_target_angle
add wave -noupdate /cordic_sin_cos_tb/o_valid
add wave -noupdate /cordic_sin_cos_tb/o_cos
add wave -noupdate /cordic_sin_cos_tb/o_sin
add wave -noupdate /cordic_sin_cos_tb/o_z_next
add wave -noupdate /cordic_sin_cos_tb/i
add wave -noupdate /cordic_sin_cos_tb/cos_hw
add wave -noupdate /cordic_sin_cos_tb/sin_hw
add wave -noupdate /cordic_sin_cos_tb/cos_sw
add wave -noupdate /cordic_sin_cos_tb/sin_sw
add wave -noupdate /cordic_sin_cos_tb/cos_diff
add wave -noupdate /cordic_sin_cos_tb/sin_diff
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {159616000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 392
configure wave -valuecolwidth 262
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
WaveRestoreZoom {0 ps} {237501200 ps}
