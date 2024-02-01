onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TB: fifo_multichannel_tb ALL signals}
add wave -noupdate /fifo_multichannel_tb/clk
add wave -noupdate /fifo_multichannel_tb/rst_all
add wave -noupdate /fifo_multichannel_tb/i_rst_channels
add wave -noupdate /fifo_multichannel_tb/i_wr_valid_channels
add wave -noupdate /fifo_multichannel_tb/i_wr_data_channels
add wave -noupdate /fifo_multichannel_tb/i_rd_en_channels
add wave -noupdate /fifo_multichannel_tb/o_rd_valid_channels
add wave -noupdate /fifo_multichannel_tb/o_rd_data_channels
add wave -noupdate /fifo_multichannel_tb/o_ready_channels
add wave -noupdate /fifo_multichannel_tb/o_empty_channels
add wave -noupdate /fifo_multichannel_tb/o_empty_next_channels
add wave -noupdate /fifo_multichannel_tb/o_full_channels
add wave -noupdate /fifo_multichannel_tb/o_full_next_channels
add wave -noupdate -radix ufixed -childformat {{{/fifo_multichannel_tb/o_fill_count_channels[49]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[48]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[47]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[46]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[45]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[44]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[43]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[42]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[41]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[40]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[39]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[38]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[37]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[36]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[35]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[34]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[33]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[32]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[31]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[30]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[29]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[28]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[27]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[26]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[25]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[24]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[23]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[22]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[21]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[20]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[19]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[18]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[17]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[16]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[15]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[14]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[13]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[12]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[11]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[10]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[9]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[8]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[7]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[6]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[5]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[4]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[3]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[2]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[1]} -radix ufixed} {{/fifo_multichannel_tb/o_fill_count_channels[0]} -radix ufixed}} -expand -subitemconfig {{/fifo_multichannel_tb/o_fill_count_channels[49]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[48]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[47]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[46]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[45]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[44]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[43]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[42]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[41]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[40]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[39]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[38]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[37]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[36]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[35]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[34]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[33]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[32]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[31]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[30]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[29]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[28]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[27]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[26]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[25]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[24]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[23]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[22]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[21]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[20]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[19]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[18]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[17]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[16]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[15]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[14]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[13]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[12]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[11]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[10]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[9]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[8]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[7]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[6]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[5]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[4]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[3]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[2]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[1]} {-height 15 -radix ufixed} {/fifo_multichannel_tb/o_fill_count_channels[0]} {-height 15 -radix ufixed}} /fifo_multichannel_tb/o_fill_count_channels
add wave -noupdate /fifo_multichannel_tb/aux_rd_data_channels
add wave -noupdate -divider {DUT: 'fifo_multichannel' IN ports}
add wave -noupdate /fifo_multichannel_tb/dut/clk
add wave -noupdate /fifo_multichannel_tb/dut/i_rd_en_channels
add wave -noupdate /fifo_multichannel_tb/dut/i_wr_valid_channels
add wave -noupdate /fifo_multichannel_tb/dut/i_rst_channels
add wave -noupdate /fifo_multichannel_tb/dut/i_wr_data_channels
add wave -noupdate /fifo_multichannel_tb/dut/rst_all
add wave -noupdate -divider {DUT: 'fifo_multichannel' OUT ports}
add wave -noupdate /fifo_multichannel_tb/dut/o_full_next_channels
add wave -noupdate /fifo_multichannel_tb/dut/o_empty_next_channels
add wave -noupdate /fifo_multichannel_tb/dut/o_ready_channels
add wave -noupdate /fifo_multichannel_tb/dut/o_rd_valid_channels
add wave -noupdate /fifo_multichannel_tb/dut/o_fill_count_channels
add wave -noupdate /fifo_multichannel_tb/dut/o_full_channels
add wave -noupdate /fifo_multichannel_tb/dut/o_empty_channels
add wave -noupdate /fifo_multichannel_tb/dut/o_rd_data_channels
add wave -noupdate -divider {DUT: 'fifo_multichannel' INTERNAL signals}
add wave -noupdate /fifo_multichannel_tb/dut/fill_count_channels
add wave -noupdate /fifo_multichannel_tb/dut/full_channels
add wave -noupdate /fifo_multichannel_tb/dut/empty_channels
add wave -noupdate /fifo_multichannel_tb/dut/rd_en_channels
add wave -noupdate /fifo_multichannel_tb/dut/wr_valid_channels
add wave -noupdate /fifo_multichannel_tb/dut/full_next_channels
add wave -noupdate /fifo_multichannel_tb/dut/empty_next_channels
add wave -noupdate /fifo_multichannel_tb/dut/ready_channels
add wave -noupdate /fifo_multichannel_tb/dut/rd_valid_channels
add wave -noupdate /fifo_multichannel_tb/dut/rst_channels
add wave -noupdate {/fifo_multichannel_tb/dut/genblk1[0]/inst_fifo_ring/ram}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4175000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 375
configure wave -valuecolwidth 206
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
WaveRestoreZoom {76016356 ps} {76509666 ps}
