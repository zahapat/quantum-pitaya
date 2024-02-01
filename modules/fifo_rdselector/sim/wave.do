onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TB: fifo_rdselector_tb ALL signals}
add wave -noupdate /fifo_rdselector_tb/dut/channel_rd_select_onehot
add wave -noupdate /fifo_rdselector_tb/i_rst_accum
add wave -noupdate /fifo_rdselector_tb/i_acc_trigger_accum
add wave -noupdate /fifo_rdselector_tb/i_data_valid_accum
add wave -noupdate -radix unsigned /fifo_rdselector_tb/i_data_accum
add wave -noupdate /fifo_rdselector_tb/rst
add wave -noupdate /fifo_rdselector_tb/o_rd_en_channels
add wave -noupdate -radix ufixed /fifo_rdselector_tb/i_channel_rd_select
add wave -noupdate -radix ufixed /fifo_rdselector_tb/dut/channel_rd_select_current
add wave -noupdate -radix ufixed /fifo_rdselector_tb/o_channel_rd_select
add wave -noupdate -radix ufixed /fifo_rdselector_tb/o_rd_data
add wave -noupdate /fifo_rdselector_tb/o_rd_valid
add wave -noupdate /fifo_rdselector_tb/clk
add wave -noupdate /fifo_rdselector_tb/i_rd_en
add wave -noupdate /fifo_rdselector_tb/o_fill_count
add wave -noupdate -radix ufixed /fifo_rdselector_tb/i_rd_data_channels
add wave -noupdate /fifo_rdselector_tb/i_rd_valid_channels
add wave -noupdate /fifo_rdselector_tb/i_ready_channels
add wave -noupdate /fifo_rdselector_tb/i_empty_channels
add wave -noupdate /fifo_rdselector_tb/i_empty_next_channels
add wave -noupdate /fifo_rdselector_tb/i_full_channels
add wave -noupdate /fifo_rdselector_tb/i_full_next_channels
add wave -noupdate /fifo_rdselector_tb/inst_fifo_accumulator/i_rd_en_channels
add wave -noupdate /fifo_rdselector_tb/inst_fifo_accumulator/rd_en_channels
add wave -noupdate /fifo_rdselector_tb/inst_fifo_accumulator/i_data_valid
add wave -noupdate /fifo_rdselector_tb/inst_fifo_accumulator/i_acc_trigger
add wave -noupdate /fifo_rdselector_tb/inst_fifo_accumulator/acc_state
add wave -noupdate /fifo_rdselector_tb/inst_fifo_accumulator/wr_channel_select
add wave -noupdate -radix ufixed -childformat {{{/fifo_rdselector_tb/i_fill_count_channels[4]} -radix ufixed} {{/fifo_rdselector_tb/i_fill_count_channels[3]} -radix ufixed} {{/fifo_rdselector_tb/i_fill_count_channels[2]} -radix ufixed} {{/fifo_rdselector_tb/i_fill_count_channels[1]} -radix ufixed} {{/fifo_rdselector_tb/i_fill_count_channels[0]} -radix ufixed}} -subitemconfig {{/fifo_rdselector_tb/i_fill_count_channels[4]} {-height 15 -radix ufixed} {/fifo_rdselector_tb/i_fill_count_channels[3]} {-height 15 -radix ufixed} {/fifo_rdselector_tb/i_fill_count_channels[2]} {-height 15 -radix ufixed} {/fifo_rdselector_tb/i_fill_count_channels[1]} {-height 15 -radix ufixed} {/fifo_rdselector_tb/i_fill_count_channels[0]} {-height 15 -radix ufixed}} /fifo_rdselector_tb/i_fill_count_channels
add wave -noupdate /fifo_rdselector_tb/o_ready_channels
add wave -noupdate /fifo_rdselector_tb/o_empty_channels
add wave -noupdate /fifo_rdselector_tb/o_empty_next_channels
add wave -noupdate /fifo_rdselector_tb/o_full_channels
add wave -noupdate /fifo_rdselector_tb/o_full_next_channels
add wave -noupdate /fifo_rdselector_tb/o_fill_count_channels
add wave -noupdate /fifo_rdselector_tb/o_rd_valid_channels
add wave -noupdate -divider {DUT: 'fifo_rdselector' IN ports}
add wave -noupdate /fifo_rdselector_tb/dut/i_ready_channels
add wave -noupdate /fifo_rdselector_tb/dut/o_fill_count_channels
add wave -noupdate /fifo_rdselector_tb/dut/clk
add wave -noupdate /fifo_rdselector_tb/dut/i_rd_data_channels
add wave -noupdate /fifo_rdselector_tb/dut/i_channel_rd_select
add wave -noupdate /fifo_rdselector_tb/dut/i_rd_valid_channels
add wave -noupdate /fifo_rdselector_tb/dut/i_empty_next_channels
add wave -noupdate /fifo_rdselector_tb/dut/rst
add wave -noupdate /fifo_rdselector_tb/dut/i_empty_channels
add wave -noupdate /fifo_rdselector_tb/dut/i_fill_count_channels
add wave -noupdate /fifo_rdselector_tb/dut/i_full_next_channels
add wave -noupdate /fifo_rdselector_tb/dut/i_full_channels
add wave -noupdate -divider {DUT: 'fifo_rdselector' OUT ports}
add wave -noupdate /fifo_rdselector_tb/dut/o_rd_valid
add wave -noupdate /fifo_rdselector_tb/dut/o_channel_rd_select
add wave -noupdate /fifo_rdselector_tb/dut/o_full_channels
add wave -noupdate /fifo_rdselector_tb/dut/o_empty_channels
add wave -noupdate /fifo_rdselector_tb/dut/o_rd_en_channels
add wave -noupdate /fifo_rdselector_tb/dut/o_fill_count
add wave -noupdate /fifo_rdselector_tb/dut/o_rd_data
add wave -noupdate /fifo_rdselector_tb/dut/o_full_next_channels
add wave -noupdate /fifo_rdselector_tb/dut/o_empty_next_channels
add wave -noupdate /fifo_rdselector_tb/dut/o_ready_channels
add wave -noupdate /fifo_rdselector_tb/dut/o_rd_valid_channels
add wave -noupdate -divider {DUT: 'fifo_rdselector' INTERNAL signals}
add wave -noupdate /fifo_rdselector_tb/dut/ready_channels
add wave -noupdate /fifo_rdselector_tb/dut/base_or_higher
add wave -noupdate /fifo_rdselector_tb/dut/empty_next_channels
add wave -noupdate /fifo_rdselector_tb/dut/bound_or_lower
add wave -noupdate /fifo_rdselector_tb/dut/channel_rd_select_onehot
add wave -noupdate /fifo_rdselector_tb/dut/empty_channels
add wave -noupdate /fifo_rdselector_tb/dut/full_next_channels
add wave -noupdate /fifo_rdselector_tb/dut/full_channels
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4541340300 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 286
configure wave -valuecolwidth 107
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
WaveRestoreZoom {0 ps} {24299636 ps}
