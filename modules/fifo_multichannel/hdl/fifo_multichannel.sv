

    module fifo_multichannel #(
            parameter RAM_WIDTH = 32,
            parameter RAM_DEPTH = 1024,
            parameter FIFOS_CNT = 5
        )(

            input logic clk,
            input logic rst_all,

            input logic [FIFOS_CNT-1:0]i_rst_channels,
            input logic [FIFOS_CNT-1:0]i_wr_valid_channels,
            input wire [FIFOS_CNT-1:0] [RAM_WIDTH-1:0] i_wr_data_channels,

            // Read port (of the respective FIFO channel)
            input  logic [FIFOS_CNT-1:0] i_rd_en_channels,
            output logic [FIFOS_CNT-1:0] o_rd_valid_channels,
            output wire [FIFOS_CNT-1:0] [RAM_WIDTH-1:0] o_rd_data_channels,

            // Flags (of the respective FIFO channel)
            output logic [FIFOS_CNT-1:0] o_ready_channels,
            output logic [FIFOS_CNT-1:0] o_empty_channels,
            output logic [FIFOS_CNT-1:0] o_empty_next_channels,
            output logic [FIFOS_CNT-1:0] o_full_channels,
            output logic [FIFOS_CNT-1:0] o_full_next_channels,

            // The number of elements in the FIFO (of the respective FIFO channel)
            output wire [FIFOS_CNT-1:0] [$clog2(RAM_DEPTH):0] o_fill_count_channels

        );

        // Write port
        logic [FIFOS_CNT-1:0] rst_channels;
        assign rst_channels = i_rst_channels;

        // Write port
        logic [FIFOS_CNT-1:0] wr_valid_channels;
        assign wr_valid_channels = i_wr_valid_channels;

        // Read port
        logic [FIFOS_CNT-1:0] rd_en_channels;
        assign rd_en_channels = i_rd_en_channels;
        logic [FIFOS_CNT-1:0] rd_valid_channels;
        assign o_rd_valid_channels = rd_valid_channels;

        // Flags
        logic [FIFOS_CNT-1:0] ready_channels;
        assign o_ready_channels = ready_channels;
        logic [FIFOS_CNT-1:0] empty_channels;
        assign o_empty_channels = empty_channels;
        logic [FIFOS_CNT-1:0] empty_next_channels;
        assign o_empty_next_channels = empty_next_channels;
        logic [FIFOS_CNT-1:0] full_channels;
        assign o_full_channels = full_channels;
        logic [FIFOS_CNT-1:0] full_next_channels;
        assign o_full_next_channels = full_next_channels;

        // Fill count
        logic [FIFOS_CNT-1:0] [$clog2(RAM_DEPTH):0] fill_count_channels;
        assign o_fill_count_channels = fill_count_channels;


        // Pre-calculate FIFO IDs
        typedef logic [$clog2(FIFOS_CNT)-1:0] array_2d [FIFOS_CNT-1:0];
        function array_2d generate_fifo_ids;
            array_2d rom_values;
            for (int i = 0; i < FIFOS_CNT; i = i + 1) begin
                rom_values[i] = ($clog2(FIFOS_CNT))'(i);
            end
            return rom_values;
        endfunction


        // FIFO write/read selector and control
        array_2d FIFOS_IDS = generate_fifo_ids();
        // always @(posedge clk) begin
        //     if (rst_all == 1'b1) begin
        //         rst_channel      <= 0;
        //         wr_valid_channel <= 0;
        //         wr_data_channel  <= 0;

        //         // Outputs
        //         // rd_valid_channels   <= 0;
        //         // rd_data_channels    <= 0;
        //         // ready_channels      <= 0;
        //         // empty_channels      <= 0;
        //         // empty_next_channels <= 0;
        //         // full_channels       <= 0;
        //         // full_next_channels  <= 0;
        //         // fill_count_channels <= 0;

        //     end else begin

        //         // Reset control
        //         // for (int i = 0; i < FIFOS_CNT; i = i + 1) begin
        //         //     if (FIFOS_IDS[i] == i_fifo_channel_id) begin
        //         //         // Switch Channel based on channel address
        //         //         rst_channel[FIFOS_IDS[i]] <= i_rst_channel;
        //         //     end
        //         // end

        //         // Write control
        //         // for (int i = 0; i < FIFOS_CNT; i = i + 1) begin
        //         //     if (FIFOS_IDS[i] == i_fifo_channel_id) begin
        //         //         // Switch Channel based on channel address
        //         //         wr_valid_channel[FIFOS_IDS[i]] <= i_wr_valid_channel;
        //         //         wr_data_channel[FIFOS_IDS[i]]  <= i_wr_data_channel;
        //         //     end
        //         // end
        //     end
        // end


        // Generate FIFO Channels
        generate
            for (genvar i = 0; i < FIFOS_CNT; i = i + 1) begin
                fifo_ring #(
                    .RAM_WIDTH(RAM_WIDTH),
                    .RAM_DEPTH(RAM_DEPTH)
                ) inst_fifo_ring (
                    .clk(clk),
                    .rst(rst_all | rst_channels[i]),

                    // Write port
                    .i_wr_valid(wr_valid_channels[i]),
                    .i_wr_data(i_wr_data_channels[i]),

                    // Read port
                    .i_rd_en(rd_en_channels[i]),
                    .o_rd_valid(rd_valid_channels[i]),
                    .o_rd_data(o_rd_data_channels[i]),

                    // Flags
                    .o_ready(ready_channels[i]),
                    .o_empty(empty_channels[i]),
                    .o_empty_next(empty_next_channels[i]),
                    .o_full(full_channels[i]),
                    .o_full_next(full_next_channels[i]),

                    // The number of elements in the FIFO channel
                    .o_fill_count(fill_count_channels[i])
                );
            end
        endgenerate
   
    endmodule