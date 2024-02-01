`timescale 1 ns / 1 ns  // time-unit = 1 ns, precision = 10 ps

module fifo_multichannel_tb;

    // ------------------------------------------------
    // DUT IO Signals and Instance
    // ------------------------------------------------
    // Generics
    localparam RAM_WIDTH = 32;
    localparam RAM_DEPTH = 128;
    localparam FIFOS_CNT = 50;

    logic clk = 0;
    logic rst_all;

    // Write port (of the respective FIFO channel)
    logic [FIFOS_CNT-1:0] i_rst_channels;
    logic [FIFOS_CNT-1:0] i_wr_valid_channels;
    logic [FIFOS_CNT-1:0] [RAM_WIDTH-1:0] i_wr_data_channels;

    // Read port (of the respective FIFO channel)
    logic [FIFOS_CNT-1:0] i_rd_en_channels;
    logic [FIFOS_CNT-1:0] o_rd_valid_channels;
    logic [FIFOS_CNT-1:0] [RAM_WIDTH-1:0] o_rd_data_channels;

    // Flags (of the respective FIFO channel)
    logic [FIFOS_CNT-1:0] o_ready_channels;
    logic [FIFOS_CNT-1:0] o_empty_channels;
    logic [FIFOS_CNT-1:0] o_empty_next_channels;
    logic [FIFOS_CNT-1:0] o_full_channels;
    logic [FIFOS_CNT-1:0] o_full_next_channels;

    // The number of elements in the FIFO (of the respective FIFO channel)
    logic [FIFOS_CNT-1:0] [$clog2(RAM_DEPTH):0] o_fill_count_channels;

    // DUT Instance
    fifo_multichannel #(
        .RAM_WIDTH(RAM_WIDTH),
        .RAM_DEPTH(RAM_DEPTH), // Must be a multiple of 2 (because of Gray counter width)
        .FIFOS_CNT(FIFOS_CNT)
    ) dut (
        .clk(clk),
        .rst_all(rst_all),

        // Write port (of the respective FIFO channel)
        .i_rst_channels(i_rst_channels),
        .i_wr_valid_channels(i_wr_valid_channels),
        .i_wr_data_channels(i_wr_data_channels),

        // Read port (of the respective FIFO channel)
        .i_rd_en_channels(i_rd_en_channels),
        .o_rd_valid_channels(o_rd_valid_channels),
        .o_rd_data_channels(o_rd_data_channels),

        // Flags (of the respective FIFO channel)
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
    task task_write_burst_until_full(
        input int channel_id
    );
        #(1*clk_period_ns);

        // Synchronous Write
        wait (o_empty_channels[channel_id] == 1'b1);
        @(posedge clk);
        for (int i = 1; i <= RAM_DEPTH; i = i + 1) begin
            if (o_full_channels[channel_id] == 1'b0) begin
                i_wr_valid_channels[channel_id] = 1'b1;
                i_wr_data_channels[channel_id] = i;
                $display($time, "   i_wr_data_channels[",channel_id,"]"," = ", i, " << TX data to DUT");
            end else begin
                i_wr_valid_channels[channel_id] = 1'b0;
                i_wr_data_channels[channel_id] = 0;
                $display($time, "   i_wr_data_channels[",channel_id,"]","set to 0, no TX");
            end
            @(posedge clk);
        end
        $display($time, "   i_wr_data_channels[",channel_id,"]","set to 0, no TX");
        i_wr_valid_channels[channel_id] = 1'b0;
        i_wr_data_channels[channel_id] = 0;
        $display($time, "   End of TX");
        @(posedge clk);
        #(20*clk_period_ns);
    endtask

    task task_read_from_full_until_empty(
        input int channel_id
    );
        @(posedge clk);
        #(50*clk_period_ns);
        // Synchronous Read, (always read)

        wait (o_rd_valid_channels[channel_id] == 1'b1);
        $display($time, "   Some data are stored in the FIFO");

        // Wait until the FIFO is full
        wait (o_full_channels[channel_id] == 1'b1);
        @(posedge clk);
        $display($time, "   FIFO is Full, read all its content");
        for (;;) begin
            if (o_rd_valid_channels[channel_id] == 1'b1) begin
                i_rd_en_channels[channel_id] = 1'b1;
                @(posedge clk); // Send Dready
                $display($time, "   o_rd_data_channels[",channel_id,"]"," = ", o_rd_data_channels[channel_id], " << RX data from DUT");
            end else if (o_rd_valid_channels[channel_id] == 1'b0) begin
                i_rd_en_channels[channel_id] = 1'b0;
                @(posedge clk);
                $display($time, "   FIFO is Empty, break");
                break;
            end
        end

        #(50*clk_period_ns);
    endtask

    task task_accumulate_on_full_fifo(
        input int channel_id
    );
        #(1*clk_period_ns);

        // Read Part
        wait (o_rd_valid_channels[channel_id] == 1'b1);
        $display($time, "   Some data are stored in the FIFO");
        $display($time, "   FIFO channel [",channel_id,"] Fill Count = ", o_fill_count_channels[channel_id]);
        
        // Wait until the FIFO is full
        wait (o_full_channels[channel_id] == 1'b1);
        @(posedge clk);
        $display($time, "   FIFO is Full, accumulate on its content");

        // Read first: Read enable to update the Read pointer in the next clock cycle
        // if (o_rd_valid_channels[channel_id] == 1'b1) begin
        //     i_rd_en_channels[channel_id] = 1'b1;
        //     $display($time, "   o_rd_data_channels[",channel_id,"]"," = ", o_rd_data_channels[channel_id], " << PRE-READ RX data from DUT");
        // end
        // @(posedge clk);

        // Write next: After reading one item fifo won't be full anymore, thus we can start to accumulate data
        for (int i = 1; i <= RAM_DEPTH; i = i + 1) begin
            if (o_rd_valid_channels[channel_id] == 1'b1) begin
                // Write: Write valid to update the Write pointer in the enxt clock cycle 
                //  -> Accumulate on the specific item in the FIFO

                i_rd_en_channels[channel_id] = 1'b1;
                #1;

                $display($time, "   o_rd_data_channels[",channel_id,"]"," = ", o_rd_data_channels[channel_id], " << RX data from DUT");

                i_wr_valid_channels[channel_id] = 1'b1;
                i_wr_data_channels[channel_id] = o_rd_data_channels[channel_id] + i;
                $display($time, "   i_wr_data_channels[",channel_id,"]"," = ", o_rd_data_channels[channel_id] + i, " << TX data to DUT");
                @(posedge clk);
            end else begin
                i_rd_en_channels[channel_id] = 1'b0;
                i_wr_valid_channels[channel_id] = 1'b0;

                i_wr_data_channels[channel_id] = 0;
                @(posedge clk);
            end
        end
        i_rd_en_channels[channel_id] = 1'b0;
        i_wr_valid_channels[channel_id] = 1'b0;
        @(posedge clk);


        #(20*clk_period_ns);
    endtask


    // ------------------------------------------------
    // Write Stimulus
    // ------------------------------------------------
    initial begin
        // Reset all fifos
        i_wr_valid_channels = 0;
        i_wr_data_channels = 0;
        i_rst_channels = 0;
        rst_all = 1'b1;
        #100ns;
        rst_all = 1'b0;
        @(posedge clk);

        // Write to FIFO channels until all full
        for (int u = 0; u < FIFOS_CNT; u = u + 1) begin
            wait (o_empty_channels[u] == 1'b1);
            task_write_burst_until_full(u);
            i_wr_valid_channels = 0;
            i_wr_data_channels = 0;
            i_rst_channels = 0;
            @(posedge clk);
        end



        // $finish; // End of Simulation
    end

    // ------------------------------------------------
    // Read Stimulus
    // ------------------------------------------------
    initial begin
        i_rd_en_channels = 0;
        #100ns;
        #(RAM_DEPTH*clk_period_ns);
        #100ns;

        // Accumulate 1x over all channels
        // WAIT UNTIL AT LEAST THE FIRST CHANNEL IS FULL
        for (int u = 0; u < FIFOS_CNT; u = u + 1) begin
            wait (o_full_channels[u] == 1'b1);
            task_accumulate_on_full_fifo(u);
            i_rd_en_channels = 0;
            @(posedge clk);
        end

        $finish; // End of Simulation
    end


endmodule