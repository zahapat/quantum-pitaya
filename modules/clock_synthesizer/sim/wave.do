onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TB: clock_synthesizer_tb ALL signals}
add wave -noupdate /clock_synthesizer_tb/in_clk0
add wave -noupdate /clock_synthesizer_tb/in_fineps_clk
add wave -noupdate /clock_synthesizer_tb/in_fineps_incr
add wave -noupdate /clock_synthesizer_tb/in_fineps_decr
add wave -noupdate /clock_synthesizer_tb/in_fineps_valid
add wave -noupdate /clock_synthesizer_tb/out_fineps_dready
add wave -noupdate /clock_synthesizer_tb/out_clk0
add wave -noupdate /clock_synthesizer_tb/out_clk1
add wave -noupdate /clock_synthesizer_tb/out_clk2
add wave -noupdate /clock_synthesizer_tb/out_clk3
add wave -noupdate /clock_synthesizer_tb/out_clk4
add wave -noupdate /clock_synthesizer_tb/out_clk5
add wave -noupdate /clock_synthesizer_tb/out_clk6
add wave -noupdate /clock_synthesizer_tb/locked
add wave -noupdate -divider {DUT: 'clock_synthesizer' IN ports}
add wave -noupdate /clock_synthesizer_tb/dut/in_fineps_valid
add wave -noupdate /clock_synthesizer_tb/dut/in_fineps_incr
add wave -noupdate /clock_synthesizer_tb/dut/in_fineps_decr
add wave -noupdate /clock_synthesizer_tb/dut/in_fineps_clk
add wave -noupdate /clock_synthesizer_tb/dut/in_clk0
add wave -noupdate -divider {DUT: 'clock_synthesizer' OUT ports}
add wave -noupdate /clock_synthesizer_tb/dut/locked
add wave -noupdate /clock_synthesizer_tb/dut/out_clk0
add wave -noupdate /clock_synthesizer_tb/dut/out_clk1
add wave -noupdate /clock_synthesizer_tb/dut/out_clk2
add wave -noupdate /clock_synthesizer_tb/dut/out_clk3
add wave -noupdate /clock_synthesizer_tb/dut/out_clk4
add wave -noupdate /clock_synthesizer_tb/dut/out_clk5
add wave -noupdate /clock_synthesizer_tb/dut/out_clk6
add wave -noupdate /clock_synthesizer_tb/dut/out_fineps_dready
add wave -noupdate -divider {DUT: 'clock_synthesizer' INTERNAL signals}
add wave -noupdate /clock_synthesizer_tb/dut/fineps_dready
add wave -noupdate /clock_synthesizer_tb/dut/fineps_incdec
add wave -noupdate /clock_synthesizer_tb/dut/mmcm_out_clk
add wave -noupdate /clock_synthesizer_tb/dut/fineps_en
add wave -noupdate /clock_synthesizer_tb/dut/fineps_valid
add wave -noupdate /clock_synthesizer_tb/dut/ps_done
add wave -noupdate /clock_synthesizer_tb/dut/mmcm_out_feedback_bufg
add wave -noupdate /clock_synthesizer_tb/dut/mmcm_out_clk_bufg
add wave -noupdate /clock_synthesizer_tb/dut/mmcm_out_feedback
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 344
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
WaveRestoreZoom {41796633 ps} {41833862 ps}
