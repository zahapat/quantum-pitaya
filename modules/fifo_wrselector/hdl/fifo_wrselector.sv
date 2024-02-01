    
    module fifo_wrselector #(
            parameter CHANNEL_WIDTH = 32,
            parameter CHANNEL_DEPTH = 1024,
            parameter CHANNELS_CNT = 3
        )(
            input  logic clk,
            input  logic rst_all,
            input  logic [CHANNELS_CNT-1:0] rst_channels,

            // Write port
            input  logic [$clog2(CHANNELS_CNT)-1:0] i_channel_wr_select, // Must be used to deliver data to the desired channel
            input  logic i_wr_valid,
            input  logic [CHANNEL_WIDTH-1:0] i_wr_data,
            // input  logic i_wr_accumulate, // Will Force Write to the FIFO and accumulate to the next read element

            // Read port
            // input  logic [$clog2(CHANNELS_CNT)-1:0] i_channel_rd_select, // Optional - Either use the parallel version or set the desires output data channel
            input  logic [CHANNELS_CNT-1:0] i_rd_en_channels,
            output logic [CHANNELS_CNT-1:0] o_rd_valid_channels,
            output logic [CHANNELS_CNT-1:0] [CHANNEL_WIDTH-1:0] o_rd_data_channels,

            // Flags
            output logic [CHANNELS_CNT-1:0] o_ready_channels,
            output logic [CHANNELS_CNT-1:0] o_empty_channels,
            output logic [CHANNELS_CNT-1:0] o_empty_next_channels,
            output logic [CHANNELS_CNT-1:0] o_full_channels,
            output logic [CHANNELS_CNT-1:0] o_full_next_channels,

            // The number of elements in the FIFO
            output logic [CHANNELS_CNT-1:0] [$clog2(CHANNEL_DEPTH):0] o_fill_count_channels

        );

        logic [CHANNELS_CNT-1:0] rst;

        // FIFO Channel Selector
        // Write port (of the respective FIFO channel)
        logic [CHANNELS_CNT-1:0] data_valid;
        logic [CHANNELS_CNT-1:0] [CHANNEL_WIDTH-1:0] data;
        logic [CHANNELS_CNT-1:0] wr_valid_channels;
        logic [CHANNELS_CNT-1:0] [CHANNEL_WIDTH-1:0] wr_data_channels;

        // Read port (of the respective FIFO channel)
        // logic [CHANNELS_CNT-1:0] rd_en_channels;
        // logic [CHANNELS_CNT-1:0] rd_valid_channels;
        // logic [CHANNELS_CNT-1:0] [CHANNEL_WIDTH-1:0] rd_data_channels;

        // Flags (of the respective FIFO channel)
        logic [CHANNELS_CNT-1:0] ready_channels;
        assign o_ready_channels = ready_channels;
        logic [CHANNELS_CNT-1:0] empty_channels;
        assign o_empty_channels = empty_channels;
        logic [CHANNELS_CNT-1:0] empty_next_channels;
        assign o_empty_next_channels = empty_next_channels;
        logic [CHANNELS_CNT-1:0] full_channels;
        assign o_full_channels = full_channels;
        logic [CHANNELS_CNT-1:0] full_next_channels;
        assign o_full_next_channels = full_next_channels;

        // The number of elements in the FIFO (of the respective FIFO channel)
        logic [CHANNELS_CNT-1:0] [$clog2(CHANNEL_DEPTH):0] fill_count_channels;
        assign o_fill_count_channels = fill_count_channels;

        // Pre-calculate FIFO IDs
        typedef logic [$clog2(CHANNELS_CNT)-1:0] array_2d [CHANNELS_CNT-1:0];
        function array_2d generate_fifo_ids;
            array_2d rom_values;
            for (int i = 0; i < CHANNELS_CNT; i = i + 1) begin
                rom_values[i] = ($clog2(CHANNELS_CNT))'(i);
            end
            return rom_values;
        endfunction
        array_2d CHANNELS_IDS = generate_fifo_ids();


        // FIFO Channel Write Selector
        always @(posedge clk) begin
            // Defaults
            data_valid <= 0;
            rst <= rst_channels;

            for (int i = 0; i < CHANNELS_CNT; i = i + 1) begin
                // Fork the input data into multiple channels
                // data[CHANNELS_IDS[i]] <= i_wr_data;

                // Enable the selected channel based on channel address
                if (CHANNELS_IDS[i] == i_channel_wr_select) begin
                    // Channel Write (if previously empty)
                    // if (o_full_channels[CHANNELS_IDS[i]] == 1'b0) begin
                        data[CHANNELS_IDS[i]] <= i_wr_data;
                        data_valid[CHANNELS_IDS[i]] <= i_wr_valid;
                    // end
                end
            end
        end


        // Generate Multichannel FIFO
        fifo_multichannel #(
            .RAM_WIDTH(CHANNEL_WIDTH),
            .RAM_DEPTH(CHANNEL_DEPTH),
            .FIFOS_CNT(CHANNELS_CNT)
        ) inst_fifo_multichannel (
            .clk(clk),
            .rst_all(rst_all),

            // Write port (of the respective FIFO channel)
            .i_rst_channels(rst),
            .i_wr_valid_channels(data_valid),
            .i_wr_data_channels(data),

            // Read port (of the respective FIFO channel)
            .i_rd_en_channels(i_rd_en_channels),
            .o_rd_valid_channels(o_rd_valid_channels),
            .o_rd_data_channels(o_rd_data_channels),

            // Flags (of the respective FIFO channel)
            .o_ready_channels(ready_channels),
            .o_empty_channels(empty_channels),
            .o_empty_next_channels(empty_next_channels),
            .o_full_channels(full_channels),
            .o_full_next_channels(full_next_channels),

            // The number of elements in the FIFO (of the respective FIFO channel)
            .o_fill_count_channels(fill_count_channels)
        );
   
    endmodule