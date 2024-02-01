onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TB: fsm_rxcmdparser_tb ALL signals}
add wave -noupdate /fsm_rxcmdparser_tb/clk
add wave -noupdate /fsm_rxcmdparser_tb/rst
add wave -noupdate /fsm_rxcmdparser_tb/i_cmd_valid
add wave -noupdate /fsm_rxcmdparser_tb/o_cmd_rd_en
add wave -noupdate /fsm_rxcmdparser_tb/i_data_valid
add wave -noupdate /fsm_rxcmdparser_tb/o_data_rd_en
add wave -noupdate /fsm_rxcmdparser_tb/o_pipeline_read_valid
add wave -noupdate /fsm_rxcmdparser_tb/o_pipeline_write_valid
add wave -noupdate /fsm_rxcmdparser_tb/o_pipeline_addr
add wave -noupdate /fsm_rxcmdparser_tb/o_pipeline_cmd
add wave -noupdate /fsm_rxcmdparser_tb/o_pipeline_data
add wave -noupdate /fsm_rxcmdparser_tb/clk_wr
add wave -noupdate /fsm_rxcmdparser_tb/wr_rst
add wave -noupdate /fsm_rxcmdparser_tb/rd_rst
add wave -noupdate /fsm_rxcmdparser_tb/i_data_cmd
add wave -noupdate /fsm_rxcmdparser_tb/i_valid_cmd
add wave -noupdate /fsm_rxcmdparser_tb/o_ready_cmd
add wave -noupdate /fsm_rxcmdparser_tb/o_data_cmd
add wave -noupdate /fsm_rxcmdparser_tb/o_data_valid_cmd
add wave -noupdate /fsm_rxcmdparser_tb/i_dready_cmd
add wave -noupdate /fsm_rxcmdparser_tb/i_data_data
add wave -noupdate /fsm_rxcmdparser_tb/i_valid_data
add wave -noupdate /fsm_rxcmdparser_tb/o_ready_data
add wave -noupdate /fsm_rxcmdparser_tb/o_data_data
add wave -noupdate /fsm_rxcmdparser_tb/o_data_valid_data
add wave -noupdate /fsm_rxcmdparser_tb/i_dready_data
add wave -noupdate -divider {DUT: 'fsm_rxcmdparser' IN ports}
add wave -noupdate /fsm_rxcmdparser_tb/dut/i_data_valid
add wave -noupdate /fsm_rxcmdparser_tb/dut/rst
add wave -noupdate /fsm_rxcmdparser_tb/dut/i_data
add wave -noupdate /fsm_rxcmdparser_tb/dut/clk
add wave -noupdate /fsm_rxcmdparser_tb/dut/i_cmd_valid
add wave -noupdate /fsm_rxcmdparser_tb/dut/i_cmd
add wave -noupdate -divider {DUT: 'fsm_rxcmdparser' OUT ports}
add wave -noupdate /fsm_rxcmdparser_tb/dut/o_pipeline_data
add wave -noupdate /fsm_rxcmdparser_tb/dut/o_pipeline_write_valid
add wave -noupdate /fsm_rxcmdparser_tb/dut/o_cmd_rd_en
add wave -noupdate /fsm_rxcmdparser_tb/dut/o_pipeline_addr
add wave -noupdate /fsm_rxcmdparser_tb/dut/o_pipeline_read_valid
add wave -noupdate /fsm_rxcmdparser_tb/dut/o_pipeline_cmd
add wave -noupdate /fsm_rxcmdparser_tb/dut/o_data_rd_en
add wave -noupdate -divider {DUT: 'fsm_rxcmdparser' INTERNAL signals}
add wave -noupdate /fsm_rxcmdparser_tb/dut/pipeline_cmd
add wave -noupdate /fsm_rxcmdparser_tb/dut/module_select
add wave -noupdate /fsm_rxcmdparser_tb/dut/pipeline_write_valid_out
add wave -noupdate /fsm_rxcmdparser_tb/dut/read_or_write
add wave -noupdate /fsm_rxcmdparser_tb/dut/pipeline_data
add wave -noupdate /fsm_rxcmdparser_tb/dut/pipeline_write_valid
add wave -noupdate /fsm_rxcmdparser_tb/dut/pipeline_read_valid_out
add wave -noupdate /fsm_rxcmdparser_tb/dut/pipeline_addr
add wave -noupdate /fsm_rxcmdparser_tb/dut/pipeline_read_valid
add wave -noupdate -radix ufixed -childformat {{{/fsm_rxcmdparser_tb/dut/cmd[27]} -radix ufixed} {{/fsm_rxcmdparser_tb/dut/cmd[26]} -radix ufixed} {{/fsm_rxcmdparser_tb/dut/cmd[25]} -radix ufixed} {{/fsm_rxcmdparser_tb/dut/cmd[24]} -radix ufixed} {{/fsm_rxcmdparser_tb/dut/cmd[23]} -radix ufixed} {{/fsm_rxcmdparser_tb/dut/cmd[22]} -radix ufixed} {{/fsm_rxcmdparser_tb/dut/cmd[21]} -radix ufixed} {{/fsm_rxcmdparser_tb/dut/cmd[20]} -radix ufixed} {{/fsm_rxcmdparser_tb/dut/cmd[19]} -radix ufixed} {{/fsm_rxcmdparser_tb/dut/cmd[18]} -radix ufixed} {{/fsm_rxcmdparser_tb/dut/cmd[17]} -radix ufixed} {{/fsm_rxcmdparser_tb/dut/cmd[16]} -radix ufixed} {{/fsm_rxcmdparser_tb/dut/cmd[15]} -radix ufixed} {{/fsm_rxcmdparser_tb/dut/cmd[14]} -radix ufixed} {{/fsm_rxcmdparser_tb/dut/cmd[13]} -radix ufixed} {{/fsm_rxcmdparser_tb/dut/cmd[12]} -radix ufixed} {{/fsm_rxcmdparser_tb/dut/cmd[11]} -radix ufixed} {{/fsm_rxcmdparser_tb/dut/cmd[10]} -radix ufixed} {{/fsm_rxcmdparser_tb/dut/cmd[9]} -radix ufixed} {{/fsm_rxcmdparser_tb/dut/cmd[8]} -radix ufixed} {{/fsm_rxcmdparser_tb/dut/cmd[7]} -radix ufixed} {{/fsm_rxcmdparser_tb/dut/cmd[6]} -radix ufixed} {{/fsm_rxcmdparser_tb/dut/cmd[5]} -radix ufixed} {{/fsm_rxcmdparser_tb/dut/cmd[4]} -radix ufixed} {{/fsm_rxcmdparser_tb/dut/cmd[3]} -radix ufixed} {{/fsm_rxcmdparser_tb/dut/cmd[2]} -radix ufixed} {{/fsm_rxcmdparser_tb/dut/cmd[1]} -radix ufixed} {{/fsm_rxcmdparser_tb/dut/cmd[0]} -radix ufixed}} -subitemconfig {{/fsm_rxcmdparser_tb/dut/cmd[27]} {-height 15 -radix ufixed} {/fsm_rxcmdparser_tb/dut/cmd[26]} {-height 15 -radix ufixed} {/fsm_rxcmdparser_tb/dut/cmd[25]} {-height 15 -radix ufixed} {/fsm_rxcmdparser_tb/dut/cmd[24]} {-height 15 -radix ufixed} {/fsm_rxcmdparser_tb/dut/cmd[23]} {-height 15 -radix ufixed} {/fsm_rxcmdparser_tb/dut/cmd[22]} {-height 15 -radix ufixed} {/fsm_rxcmdparser_tb/dut/cmd[21]} {-height 15 -radix ufixed} {/fsm_rxcmdparser_tb/dut/cmd[20]} {-height 15 -radix ufixed} {/fsm_rxcmdparser_tb/dut/cmd[19]} {-height 15 -radix ufixed} {/fsm_rxcmdparser_tb/dut/cmd[18]} {-height 15 -radix ufixed} {/fsm_rxcmdparser_tb/dut/cmd[17]} {-height 15 -radix ufixed} {/fsm_rxcmdparser_tb/dut/cmd[16]} {-height 15 -radix ufixed} {/fsm_rxcmdparser_tb/dut/cmd[15]} {-height 15 -radix ufixed} {/fsm_rxcmdparser_tb/dut/cmd[14]} {-height 15 -radix ufixed} {/fsm_rxcmdparser_tb/dut/cmd[13]} {-height 15 -radix ufixed} {/fsm_rxcmdparser_tb/dut/cmd[12]} {-height 15 -radix ufixed} {/fsm_rxcmdparser_tb/dut/cmd[11]} {-height 15 -radix ufixed} {/fsm_rxcmdparser_tb/dut/cmd[10]} {-height 15 -radix ufixed} {/fsm_rxcmdparser_tb/dut/cmd[9]} {-height 15 -radix ufixed} {/fsm_rxcmdparser_tb/dut/cmd[8]} {-height 15 -radix ufixed} {/fsm_rxcmdparser_tb/dut/cmd[7]} {-height 15 -radix ufixed} {/fsm_rxcmdparser_tb/dut/cmd[6]} {-height 15 -radix ufixed} {/fsm_rxcmdparser_tb/dut/cmd[5]} {-height 15 -radix ufixed} {/fsm_rxcmdparser_tb/dut/cmd[4]} {-height 15 -radix ufixed} {/fsm_rxcmdparser_tb/dut/cmd[3]} {-height 15 -radix ufixed} {/fsm_rxcmdparser_tb/dut/cmd[2]} {-height 15 -radix ufixed} {/fsm_rxcmdparser_tb/dut/cmd[1]} {-height 15 -radix ufixed} {/fsm_rxcmdparser_tb/dut/cmd[0]} {-height 15 -radix ufixed}} /fsm_rxcmdparser_tb/dut/cmd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {499800 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 232
configure wave -valuecolwidth 204
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
WaveRestoreZoom {29379158 ps} {33645308 ps}
