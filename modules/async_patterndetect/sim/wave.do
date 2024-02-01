onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TB: async_patterndetect_tb ALL signals}
add wave -noupdate /async_patterndetect_tb/clk
add wave -noupdate /async_patterndetect_tb/in_async_sig
add wave -noupdate /async_patterndetect_tb/out_sync_pattern_present
add wave -noupdate /async_patterndetect_tb/out_sync_pattern_posedge
add wave -noupdate /async_patterndetect_tb/out_sync_pattern_negedge
add wave -noupdate /async_patterndetect_tb/out_sync_pattern_posedge_delayed
add wave -noupdate /async_patterndetect_tb/out_sync_event_posedge
add wave -noupdate /async_patterndetect_tb/out_sync_event_negedge
add wave -noupdate /async_patterndetect_tb/out_sync_pattern_posedge_delayed_latched
add wave -noupdate /async_patterndetect_tb/in_sync_pattern_posedge_delayed_latched_pulldown
add wave -noupdate /async_patterndetect_tb/in_update_variable_delay_cycles_1_valid
add wave -noupdate /async_patterndetect_tb/in_update_variable_delay_cycles_1_data
add wave -noupdate /async_patterndetect_tb/in_update_variable_delay_cycles_2_valid
add wave -noupdate /async_patterndetect_tb/in_update_variable_delay_cycles_2_data
add wave -noupdate -divider {DUT: 'async_patterndetect' IN ports}
add wave -noupdate /async_patterndetect_tb/dut/in_update_variable_delay_cycles_1_valid
add wave -noupdate /async_patterndetect_tb/dut/in_sync_pattern_posedge_delayed_latched_pulldown
add wave -noupdate /async_patterndetect_tb/dut/in_update_variable_delay_cycles_2_valid
add wave -noupdate /async_patterndetect_tb/dut/in_async_sig
add wave -noupdate /async_patterndetect_tb/dut/clk
add wave -noupdate /async_patterndetect_tb/dut/in_update_variable_delay_cycles_1_data
add wave -noupdate /async_patterndetect_tb/dut/in_update_variable_delay_cycles_2_data
add wave -noupdate -divider {DUT: 'async_patterndetect' OUT ports}
add wave -noupdate /async_patterndetect_tb/dut/out_sync_pattern_present
add wave -noupdate /async_patterndetect_tb/dut/out_sync_pattern_posedge_delayed_latched
add wave -noupdate /async_patterndetect_tb/dut/out_sync_pattern_posedge_delayed
add wave -noupdate /async_patterndetect_tb/dut/out_sync_event_negedge
add wave -noupdate /async_patterndetect_tb/dut/out_sync_event_posedge
add wave -noupdate /async_patterndetect_tb/dut/out_sync_pattern_negedge
add wave -noupdate /async_patterndetect_tb/dut/out_sync_pattern_posedge
add wave -noupdate -divider {DUT: 'async_patterndetect' INTERNAL signals}
add wave -noupdate /async_patterndetect_tb/dut/int_delay_trig_counter
add wave -noupdate /async_patterndetect_tb/dut/slv_shiftreg_delayed_posedge
add wave -noupdate /async_patterndetect_tb/dut/int_clkdiv_counter
add wave -noupdate /async_patterndetect_tb/dut/sl_async_sig_flop1
add wave -noupdate /async_patterndetect_tb/dut/sl_async_sig_inv_or_notinv
add wave -noupdate /async_patterndetect_tb/dut/slv_capture_delay_cycles_1
add wave -noupdate /async_patterndetect_tb/dut/sl_async_sig_flop2
add wave -noupdate /async_patterndetect_tb/dut/slv_capture_delay_cycles_2
add wave -noupdate /async_patterndetect_tb/dut/sync_pattern_posedge_delayed_latched
add wave -noupdate /async_patterndetect_tb/dut/sync_pulse_negedge
add wave -noupdate /async_patterndetect_tb/dut/sl_pattern_present
add wave -noupdate /async_patterndetect_tb/dut/sync_event_posedge
add wave -noupdate /async_patterndetect_tb/dut/sl_sample_enable
add wave -noupdate /async_patterndetect_tb/dut/sl_shiftreg_pattern
add wave -noupdate /async_patterndetect_tb/dut/slv_capture_total_delay_cycles_added_onehot
add wave -noupdate /async_patterndetect_tb/dut/slv_capture_delay_cycles_12_added
add wave -noupdate /async_patterndetect_tb/dut/sync_event_posedge_delayed
add wave -noupdate /async_patterndetect_tb/dut/sl_delay_trig_counter_en
add wave -noupdate /async_patterndetect_tb/dut/sync_pulse_posedge
add wave -noupdate /async_patterndetect_tb/dut/slv_capture_total_delay_cycles_added
add wave -noupdate /async_patterndetect_tb/dut/sl_pattern_present_p1
add wave -noupdate /async_patterndetect_tb/dut/sync_event_negedge
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
WaveRestoreZoom {0 ps} {52382400 ps}
