`timescale 1 ns / 1 ns  // time-unit = 1 ns, precision = 10 ps

module fifo_accumulator_tb;

    // ------------------------------------------------
    // DUT IO Signals and Instance
    // ------------------------------------------------
    // Generics
    localparam CHANNEL_WIDTH = 32;
    localparam CHANNEL_DEPTH = 128;
    localparam CHANNELS_CNT = 5;
    localparam CHANNEL_ACC_ROUNDS = 5;

    logic clk = 0;
    logic i_rst;

    // Write port (of the respective FIFO channel)
    // logic [$clog2(CHANNELS_CNT)-1:0] i_fifo_channel_id;

    logic i_acc_trigger;
    logic i_data_valid;
    logic [CHANNEL_WIDTH-1:0] i_data;

    logic o_acc_valid;

    // Read port (of the respective FIFO channel)
    logic [CHANNELS_CNT-1:0] i_rd_en_channels;
    logic [CHANNELS_CNT-1:0] o_rd_valid_channels;
    logic [CHANNELS_CNT-1:0] [CHANNEL_WIDTH-1:0] o_rd_data_channels;

    // Flags (of the respective FIFO channel)
    logic [CHANNELS_CNT-1:0] o_ready_channels;
    logic [CHANNELS_CNT-1:0] o_empty_channels;
    logic [CHANNELS_CNT-1:0] o_empty_next_channels;
    logic [CHANNELS_CNT-1:0] o_full_channels;
    logic [CHANNELS_CNT-1:0] o_full_next_channels;

    // The number of elements in the FIFO (of the respective FIFO channel)
    logic [CHANNELS_CNT-1:0] [$clog2(CHANNEL_DEPTH):0] o_fill_count_channels;

    // DUT Instance
    fifo_accumulator #(
        .CHANNEL_WIDTH(CHANNEL_WIDTH),
        .CHANNEL_DEPTH(CHANNEL_DEPTH),
        .CHANNELS_CNT(CHANNELS_CNT),
        .CHANNEL_ACC_ROUNDS(CHANNEL_ACC_ROUNDS)
    ) dut (
        .clk(clk),
        .i_rst(i_rst),

        // Write port (of the respective FIFO channel)
        .i_acc_trigger(i_acc_trigger),
        .i_data_valid(i_data_valid),
        .i_data(i_data),

        .o_acc_valid(o_acc_valid),

        // Read port (of all FIFO channels)
        .i_rd_en_channels(i_rd_en_channels),
        .o_rd_valid_channels(o_rd_valid_channels),
        .o_rd_data_channels(o_rd_data_channels),
        .o_ready_channels(o_ready_channels),
        .o_empty_channels(o_empty_channels),
        .o_empty_next_channels(o_empty_next_channels),
        .o_full_channels(o_full_channels),
        .o_full_next_channels(o_full_next_channels),

        // The number of elements in the FIFO (of the respective FIFO channel)
        .o_fill_count_channels(o_fill_count_channels)
    );

    // Clocks
    parameter clk_period_ns = 10; // * 1 ns on timescale
    initial forever begin #(clk_period_ns/2) clk = ~clk; end


    // ------------------------------------------------
    // Tasks
    // ------------------------------------------------
    

    // ------------------------------------------------
    // Stimulus
    // ------------------------------------------------
    initial begin
        i_rd_en_channels = 0;
        i_data_valid = 0;
        i_data = 0;
        i_acc_trigger = 0;
        i_rst = 1'b1;
        #100ns;
        @(posedge clk);
        i_rst = 1'b0;
        @(posedge clk);

        for (int i = 0; i < CHANNELS_CNT*CHANNEL_ACC_ROUNDS; i = i + 1 ) begin
            i_acc_trigger = 1'b1;
            @(posedge clk);
            i_acc_trigger = 1'b0;
            @(posedge clk);
            for (int j = 1; j <= CHANNEL_DEPTH; j = j + 1) begin
                i_data_valid = 1'b1;
                i_data = j;
                #1;
                #1;
                #1;
                #1;
                #1;
                #1;
                #1;
                #1;
                @(posedge clk);
            end
            i_data_valid = 0;
            i_data = 0;
            @(posedge clk);
        end
        @(posedge clk);
        @(posedge clk);
        #100ns;

        // Read the content of the fifo
        @(posedge clk);
        for (int i = 0; i < CHANNELS_CNT; i = i + 1 ) begin
            for (int j = 1; j <= CHANNEL_DEPTH; j = j + 1) begin
                i_rd_en_channels = 0;
                i_rd_en_channels[i] = 1'b1;
                @(posedge clk);
            end
        end
        i_rd_en_channels = 1'b0;

        @(posedge clk);
        #100ns;
        @(posedge clk);


        $finish; // End of Simulation
    end


endmodule