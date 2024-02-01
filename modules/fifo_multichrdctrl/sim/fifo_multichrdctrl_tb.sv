`timescale 1 ns / 1 ns  // time-unit = 1 ns, precision = 10 ps

module fifo_multichrdctrl_tb;

    // ------------------------------------------------
    // DUT IO Signals and Instance
    // ------------------------------------------------
    // Generics
    localparam CHANNEL_WIDTH = 32;
    localparam CHANNEL_DEPTH = 64;
    localparam CHANNELS_CNT = 5;
    localparam CHANNEL_ACC_ROUNDS = 5; // Repetitions

    // Accumulator
    logic clk = 0;
    logic i_rst_accum;

    logic i_acc_trigger_accum;
    logic i_data_valid_accum;
    logic [CHANNEL_WIDTH-1:0] i_data_accum;

    logic o_acc_valid;

    // DUT
    logic rst;

    // Read port
    logic [$clog2(CHANNELS_CNT)-1:0] i_channel_rd_select; // Must be used to retreive data from the desired channel, then read the data
    logic i_rd_en = 0;
    logic [$clog2(CHANNELS_CNT)-1:0] o_channel_rd_select = 0; // Actual channel selected
    logic [CHANNEL_WIDTH-1:0] o_rd_data;
    logic o_rd_valid;
    logic [$clog2(CHANNEL_DEPTH):0] o_fill_count;


    // Multichannel FIFO Signals (source)
    logic [CHANNELS_CNT-1:0] [CHANNEL_WIDTH-1:0] i_rd_data_channels; // No delay
    logic [CHANNELS_CNT-1:0] o_rd_en_channels;
    logic [CHANNELS_CNT-1:0] i_rd_valid_channels;    // ~empty_next & ~empty;
    logic [CHANNELS_CNT-1:0] i_ready_channels;       // ~full;
    logic [CHANNELS_CNT-1:0] i_empty_channels;
    logic [CHANNELS_CNT-1:0] i_empty_next_channels;
    logic [CHANNELS_CNT-1:0] i_full_channels;
    logic [CHANNELS_CNT-1:0] i_full_next_channels;
    logic [CHANNELS_CNT-1:0] [$clog2(CHANNEL_DEPTH):0] i_fill_count_channels;

    // Multichannel FIFO Signals (passthrough flags)
    logic [CHANNELS_CNT-1:0] o_rd_valid_channels;    // ~empty_next & ~empty = some data present
    logic [CHANNELS_CNT-1:0] o_ready_channels;       // ~full;
    logic [CHANNELS_CNT-1:0] o_empty_channels;
    logic [CHANNELS_CNT-1:0] o_empty_next_channels;
    logic [CHANNELS_CNT-1:0] o_full_channels;
    logic [CHANNELS_CNT-1:0] o_full_next_channels;
    logic [CHANNELS_CNT-1:0] [$clog2(CHANNEL_DEPTH):0] o_fill_count_channels;

    

    // Instance: fifo accumulator
    fifo_accumulator #(
        .CHANNEL_WIDTH(CHANNEL_WIDTH),
        .CHANNEL_DEPTH(CHANNEL_DEPTH),
        .CHANNELS_CNT(CHANNELS_CNT),
        .CHANNEL_ACC_ROUNDS(CHANNEL_ACC_ROUNDS)
    ) inst_fifo_accumulator (
        .clk(clk),
        .i_rst(i_rst_accum),

        // Write port (of the respective FIFO channel)
        .i_acc_trigger(i_acc_trigger_accum),
        .i_data_valid(i_data_valid_accum),
        .i_data(i_data_accum),

        .o_acc_valid(o_acc_valid),

        // Read port (of all FIFO channels)
        .i_rd_en_channels(o_rd_en_channels),
        .o_rd_data_channels(i_rd_data_channels),   // no delay
        .o_rd_valid_channels(i_rd_valid_channels), // ~empty_next & ~empty;
        .o_ready_channels(i_ready_channels),       // ~full;
        .o_empty_channels(i_empty_channels),
        .o_empty_next_channels(i_empty_next_channels),
        .o_full_channels(i_full_channels),
        .o_full_next_channels(i_full_next_channels),

        // The number of elements in the FIFO (of the respective FIFO channel)
        .o_fill_count_channels(i_fill_count_channels)
    );


    // Multichannel FIFO Read Selector
    fifo_rdselector #(
        .CHANNEL_WIDTH(CHANNEL_WIDTH),
        .CHANNEL_DEPTH(CHANNEL_DEPTH),
        .CHANNELS_CNT(CHANNELS_CNT)
    ) inst_fifo_rdselector (
        .clk(clk),
        .rst(rst),

        // Write port

        // Read port
        .i_channel_rd_select(i_channel_rd_select), // Must be used to retreive data from the desired channel, then read the data
        .i_rd_en(i_rd_en),

        .o_channel_rd_select(o_channel_rd_select), // Actual channel selected
        .o_rd_data(o_rd_data),
        .o_rd_valid(o_rd_valid),
        .o_fill_count(o_fill_count),

        // Multichannel FIFO Signals (source)
        .i_rd_data_channels(i_rd_data_channels),   // No delay
        .o_rd_en_channels(o_rd_en_channels),
        .i_rd_valid_channels(i_rd_valid_channels), // ~empty_next & ~empty;
        .i_ready_channels(i_ready_channels),       // ~full;
        .i_empty_channels(i_empty_channels),
        .i_empty_next_channels(i_empty_next_channels),
        .i_full_channels(i_full_channels),
        .i_full_next_channels(i_full_next_channels),

        .i_fill_count_channels(i_fill_count_channels),

        // Passthrough FIFO flags
        .o_rd_valid_channels(o_rd_valid_channels), // ~empty_next & ~empty;
        .o_ready_channels(o_ready_channels),       // ~full;
        .o_empty_channels(o_empty_channels),
        .o_empty_next_channels(o_empty_next_channels),
        .o_full_channels(o_full_channels),
        .o_full_next_channels(o_full_next_channels),

        .o_fill_count_channels(o_fill_count_channels)
    );


    // DUT
    parameter RD_CHANNEL_CNT = CHANNELS_CNT;
    parameter RD_CHANNEL_DEPTH = CHANNEL_DEPTH;
    parameter RD_DELAY_CYCLES = 5; // Wait to update the ready/valid flags from the multich fifo, thus doublereads
    logic i_cmd_valid = 0;
    logic [$clog2(RD_CHANNEL_CNT)-1:0] i_cmd_rdchsel = 0;
    logic [$clog2(RD_CHANNEL_DEPTH):0] i_cmd_rdcnt = 0;
    logic o_cmd_ready = 0;

    logic o_singlechannel_wr_valid = 0;
    logic [CHANNEL_WIDTH-1:0] o_singlechannel_wr_data = 0;
    logic i_singlechannel_wr_dready = 0;

    fifo_multichrdctrl #(
        .CHANNEL_WIDTH(CHANNEL_WIDTH),
        .RD_CHANNEL_CNT(CHANNELS_CNT),
        .RD_CHANNEL_DEPTH(CHANNEL_DEPTH),
        .RD_DELAY_CYCLES(RD_DELAY_CYCLES)
    ) dut (
        .clk(clk),
        .rst(rst),
        .i_cmd_valid(i_cmd_valid),
        .i_cmd_rdchsel(i_cmd_rdchsel),
        .i_cmd_rdcnt(i_cmd_rdcnt),
        .o_cmd_ready(o_cmd_ready),
        .o_multichannel_rd_en(i_rd_en),
        .i_multichannel_rd_select(o_channel_rd_select),
        .o_multichannel_rd_select(i_channel_rd_select),
        .i_multichannel_rd_valid(o_rd_valid),
        .i_multichannel_rd_data(o_rd_data),
        .o_singlechannel_wr_valid(o_singlechannel_wr_valid),
        .o_singlechannel_wr_data(o_singlechannel_wr_data),
        .i_singlechannel_wr_dready(i_singlechannel_wr_dready)
    );




    // Clocks
    parameter clk_period_ns = 10; // * 1 ns on timescale
    initial forever begin #(clk_period_ns/2) clk = ~clk; end


    // ------------------------------------------------
    // Tasks
    // ------------------------------------------------


    // ------------------------------------------------
    // Stimulus: Write
    // ------------------------------------------------
    initial begin
        // i_rd_en_channels_accum = 0;
        i_data_valid_accum = 0;
        i_data_accum = 0;
        i_acc_trigger_accum = 0;
        i_rst_accum = 1'b1;
        #1000ns;
        @(posedge clk);
        i_rst_accum = 1'b0;
        @(posedge clk);

        for (int i = 0; i < CHANNELS_CNT*CHANNEL_ACC_ROUNDS; i = i + 1 ) begin
            i_acc_trigger_accum = 1'b1;
            @(posedge clk);
            i_acc_trigger_accum = 1'b0;
            @(posedge clk);
            for (int j = 1; j <= (CHANNEL_DEPTH+100); j = j + 1) begin
                i_data_valid_accum = 1'b1;
                i_data_accum = j;
                #1;
                @(posedge clk);
            end
            i_data_valid_accum = 0;
            i_data_accum = 0;
            @(posedge clk);
        end
        @(posedge clk);
        @(posedge clk);


        // $finish; // End of Simulation
    end

    // ------------------------------------------------
    // Stimulus: Read
    // ------------------------------------------------
    initial begin

        i_singlechannel_wr_dready = 1'b1;
        wait (o_acc_valid == 1'b1);

        for (int i = 0; i < CHANNELS_CNT; i = i + 1) begin
            // Prepare the Read Command
            if (o_cmd_ready == 1'b1) begin
                i_cmd_valid = 1'b1;
                i_cmd_rdchsel = i+1;
                i_cmd_rdcnt = CHANNEL_DEPTH;
                @(posedge clk);
                i_cmd_valid = 0;
            end

            for (int j = 0; j < CHANNEL_DEPTH; j = j + 1) begin
                // Read the content after seiding the command
                wait (o_singlechannel_wr_valid == 1'b1);
                $display($time, "      RX REQUEST:      i_channel_rd_select       =  ", i_channel_rd_select);
                $display($time, "                       o_fill_count              =  ", o_fill_count);
                $display($time, "                       o_singlechannel_wr_valid  =  ", o_singlechannel_wr_valid);
                $display($time, "                       o_singlechannel_wr_data   =  ", o_singlechannel_wr_data);
                $display($time, "                       i_singlechannel_wr_dready =  ", i_singlechannel_wr_dready);
                @(posedge clk);
                #1;
            end
        end

        wait (o_acc_valid == 1'b0);

        @(posedge clk);
        #1000ns;
        @(posedge clk);

        $finish; // End of Simulation
    end



endmodule