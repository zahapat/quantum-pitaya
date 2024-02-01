    
    module fifo_rdselector #(
            parameter CHANNEL_WIDTH = 32,
            parameter CHANNEL_DEPTH = 1024,
            parameter CHANNELS_CNT = 3
        )(
            input  logic clk,
            input  logic rst,

            // Write port

            // Read port
            input  logic [$clog2(CHANNELS_CNT)-1:0] i_channel_rd_select, // Must be used to retreive data from the desired channel, then read the data
            input  logic i_rd_en,

            output logic [$clog2(CHANNELS_CNT)-1:0] o_channel_rd_select, // Actual channel selected
            output logic [CHANNEL_WIDTH-1:0] o_rd_data,
            output logic o_rd_valid,
            output logic [$clog2(CHANNEL_DEPTH):0] o_fill_count,

            // Multichannel FIFO Signals (source)
            input  logic [CHANNELS_CNT-1:0] [CHANNEL_WIDTH-1:0] i_rd_data_channels, // No delay
            output logic [CHANNELS_CNT-1:0] o_rd_en_channels,
            input  logic [CHANNELS_CNT-1:0] i_rd_valid_channels,    // ~empty_next & ~empty;
            input  logic [CHANNELS_CNT-1:0] i_ready_channels,       // ~empty;
            input  logic [CHANNELS_CNT-1:0] i_empty_channels,       
            input  logic [CHANNELS_CNT-1:0] i_empty_next_channels,  
            input  logic [CHANNELS_CNT-1:0] i_full_channels,        
            input  logic [CHANNELS_CNT-1:0] i_full_next_channels,   
            input  logic [CHANNELS_CNT-1:0] [$clog2(CHANNEL_DEPTH):0] i_fill_count_channels,

            // Multichannel FIFO Signals (passthrough flags)
            output logic [CHANNELS_CNT-1:0] o_rd_valid_channels,    // ~empty_next & ~empty = some data present
            output logic [CHANNELS_CNT-1:0] o_ready_channels,       // ~empty = ready to accept data
            output logic [CHANNELS_CNT-1:0] o_empty_channels,       
            output logic [CHANNELS_CNT-1:0] o_empty_next_channels,  
            output logic [CHANNELS_CNT-1:0] o_full_channels,        
            output logic [CHANNELS_CNT-1:0] o_full_next_channels,   
            output logic [CHANNELS_CNT-1:0] [$clog2(CHANNEL_DEPTH):0] o_fill_count_channels
        );

        // Binary address to one-hot (bit enable) conversion
        logic [CHANNELS_CNT-1:0] channel_rd_select_onehot = 1;
        logic [CHANNELS_CNT-1:0] base_or_higher = 0;
        logic [CHANNELS_CNT-1:0] bound_or_lower = 0;


        // FIFO Channel Selector
        // Read port (of the respective FIFO channel)
        logic [$clog2(CHANNELS_CNT)-1:0] channel_rd_select_current = 0;
        logic [$clog2(CHANNELS_CNT)-1:0] channel_rd_select = 0;
        assign o_channel_rd_select = channel_rd_select;
        logic [CHANNEL_WIDTH-1:0] rd_data;
        assign o_rd_data = rd_data;
        logic rd_valid = 0;
        assign o_rd_valid
            = (i_channel_rd_select == channel_rd_select_current) ? rd_valid : 1'b0;


        // Flags (of the respective FIFO channel)
        logic [CHANNELS_CNT-1:0] rd_valid_channels;
        assign rd_valid_channels = i_rd_valid_channels;
        assign o_rd_valid_channels = rd_valid_channels;
        logic [CHANNELS_CNT-1:0] ready_channels;
        assign ready_channels = i_ready_channels;
        assign o_ready_channels = ready_channels;
        logic [CHANNELS_CNT-1:0] empty_channels;
        assign empty_channels = i_empty_channels;
        assign o_empty_channels = empty_channels;
        logic [CHANNELS_CNT-1:0] empty_next_channels;
        assign empty_next_channels = i_empty_next_channels;
        assign o_empty_next_channels = empty_next_channels;
        logic [CHANNELS_CNT-1:0] full_channels;
        assign full_channels = i_full_channels;
        assign o_full_channels = full_channels;
        logic [CHANNELS_CNT-1:0] full_next_channels;
        assign full_next_channels = i_full_next_channels;
        assign o_full_next_channels = full_next_channels;

        // The number of elements in the FIFO (of the respective FIFO channel)
        logic [CHANNELS_CNT-1:0] [$clog2(CHANNEL_DEPTH):0] fill_count_channels;
        assign fill_count_channels = i_fill_count_channels;
        assign o_fill_count_channels = fill_count_channels;
        logic [$clog2(CHANNEL_DEPTH):0] fill_count = 0;
        assign o_fill_count = fill_count;

        // Read port (of the respective FIFO channel)
        logic [CHANNELS_CNT-1:0] rd_en_channels_current = 0;

        // assign o_rd_en_channels = {CHANNELS_CNT{i_rd_en}} & channel_rd_select_onehot[CHANNELS_CNT:1] & ~empty_channels; // original
        assign o_rd_en_channels = {CHANNELS_CNT{i_rd_en}} & channel_rd_select_onehot[CHANNELS_CNT-1:0] & ~empty_channels;

        // logic rd_en_p1 = 0;


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


        // Binary address to one-hot (bit enable) conversion - not the best idea
        generate
            always @(*) begin
                channel_rd_select_onehot = 0;
                for (int i = 0; i < CHANNELS_CNT; i = i + 1) begin
                    base_or_higher = 0;
                    bound_or_lower = 0;
                    base_or_higher = (channel_rd_select_current >= ($clog2(CHANNELS_CNT))'(i));
                    bound_or_lower = (channel_rd_select_current <= ($clog2(CHANNELS_CNT))'(i));
                    channel_rd_select_onehot[i] = (base_or_higher == 1'b1) && (bound_or_lower == 1'b1);
                end
            end
        endgenerate



        // FIFO Channel Read Selector
        always @(posedge clk) begin

            if (rst == 1'b1) begin

                // Initial condition for this signal must be 1
                // channel_rd_select_onehot <= 1;
                channel_rd_select_current <= 1;

            end else begin

                // Defaults
                rd_valid <= 0;
                channel_rd_select_current <= i_channel_rd_select;
                // rd_en_channels_current <= channel_rd_select_onehot[CHANNELS_CNT:1]; // original
                rd_en_channels_current <= channel_rd_select_onehot[CHANNELS_CNT-1:0];
                // rd_en_p1 <= i_rd_en;

                for (int i = 0; i < CHANNELS_CNT; i = i + 1) begin
                    // Switch to the desired channel
                    // if ((CHANNELS_IDS[i]+1) == i_channel_rd_select) begin // original
                    if ((CHANNELS_IDS[i]) == i_channel_rd_select) begin
                        // Show data anyway, send valid if read requested & fifo not empty
                        rd_data <= i_rd_data_channels[CHANNELS_IDS[i]];
                        fill_count <= fill_count_channels[CHANNELS_IDS[i]];
                        // channel_rd_select <= CHANNELS_IDS[i] + 1; // original
                        channel_rd_select <= CHANNELS_IDS[i];

                        rd_valid <= rd_valid_channels[CHANNELS_IDS[i]];
    
                        // Allow reading only if the correct fifo channel has been switched
                        if (channel_rd_select_current == i_channel_rd_select) begin
                            rd_valid <= rd_valid_channels[CHANNELS_IDS[i]];
                        end else begin
                            rd_valid <= 0;
                        end
                    end
                end
            end

        end

    endmodule