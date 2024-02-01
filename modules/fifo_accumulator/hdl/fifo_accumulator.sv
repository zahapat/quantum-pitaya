    
    module fifo_accumulator #(
            parameter CHANNEL_WIDTH = 32,
            parameter CHANNEL_DEPTH = 1024,
            parameter CHANNELS_CNT = 5,
            parameter CHANNEL_ACC_ROUNDS = 10
        )(
            input logic clk,
            input logic i_rst,

            input logic i_acc_trigger, // Must be pulsed, duration 1 clk
            input logic i_data_valid,
            input logic [CHANNEL_WIDTH-1:0] i_data,

            // Accumulator Done Flag
            output logic o_acc_valid,


            // Read port
            input  logic [CHANNELS_CNT-1:0] i_rd_en_channels, // No delay
            output logic [CHANNELS_CNT-1:0] o_rd_valid_channels, // No delay
            output logic [CHANNELS_CNT-1:0] [CHANNEL_WIDTH-1:0] o_rd_data_channels, // No delay

            // Flags
            output logic [CHANNELS_CNT-1:0] o_ready_channels, // No delay
            output logic [CHANNELS_CNT-1:0] o_empty_channels, // No delay
            output logic [CHANNELS_CNT-1:0] o_empty_next_channels, // No delay
            output logic [CHANNELS_CNT-1:0] o_full_channels, // No delay
            output logic [CHANNELS_CNT-1:0] o_full_next_channels, // No delay

            // The number of elements in the FIFO
            output logic [CHANNELS_CNT-1:0] [$clog2(CHANNEL_DEPTH):0] o_fill_count_channels // No delay
        );


        // FIFO Channel Selector
        logic [$clog2(CHANNELS_CNT)-1:0] wr_channel_select = 0;
        logic [$clog2(CHANNELS_CNT)-1:0] channel_rd_select = 0;
        logic [$clog2(CHANNEL_ACC_ROUNDS)-1:0] channel_rounds_cnt = 0;

        // Write port (of the respective FIFO channel)
        logic [CHANNELS_CNT-1:0] rst_channels;
        logic [CHANNEL_WIDTH-1:0] wr_data = 0;
        logic [CHANNEL_WIDTH-1:0] wr_data_p1 = 0;
        logic [CHANNEL_WIDTH-1:0] wr_data_p2 = 0;
        logic wr_valid = 0;
        logic wr_valid_p1 = 0;
        logic wr_valid_p2 = 0;
        logic wr_accumulate = 0;

        logic wr_valid_checked;
        // assign wr_valid_checked = full_next_channels;


        // Read port (of the respective FIFO channel)
        logic [CHANNELS_CNT-1:0] rd_en_channels = 0;
        // logic [CHANNELS_CNT-1:0] rd_valid_channels;
        logic [CHANNELS_CNT-1:0] [CHANNEL_WIDTH-1:0] rd_data_channels;
        assign o_rd_data_channels = rd_data_channels;

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
        logic [$clog2(CHANNEL_DEPTH):0] items_written_round = 0;
        logic [$clog2(CHANNEL_DEPTH * CHANNEL_ACC_ROUNDS):0] items_accumulated_channels = 0;
        logic [$clog2(CHANNEL_DEPTH * CHANNEL_ACC_ROUNDS):0] items_accumulated_channels_next;
        assign items_accumulated_channels_next = items_accumulated_channels + 1'b1;

        enum int unsigned {
            // One-hot encoding
            WAIT_FIRST_TRIGGER              = 0,
            WRITE_FIFO_CHANNEL_UNTIL_FULL   = 2,
            ACCUM_FIFO_CHANNEL              = 4,
            READ_CHANNELS_UNTIL_EMPTY       = 8
        } acc_state = WAIT_FIRST_TRIGGER;

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


        // FIFO Channel Selector & Control
        always @(posedge clk) begin
            if (i_rst == 1'b1) begin
                wr_channel_select <= 0;
                channel_rounds_cnt <= 0;
                wr_data <= 0;
                wr_valid <= 0;
                items_accumulated_channels <= 0;
                rd_en_channels <= 0;
                o_acc_valid <= 0;


            end else begin

                // Default
                rst_channels <= 0;
                wr_accumulate <= 0; // not used
                rd_en_channels <= 0;
                o_acc_valid <= 0;

                wr_valid <= 0;
                wr_valid_p1 <= wr_valid;
                wr_valid_p2 <= wr_valid_p1; // Not used
                wr_data <= i_data;
                wr_data_p1 <= wr_data;
                wr_data_p2 <= wr_data_p1; // Not used

                // Allow to write to the fifo if max number of items recorded per repetition have not been exceeded
                channel_rounds_cnt <= channel_rounds_cnt + i_acc_trigger;
                if (items_written_round != CHANNEL_DEPTH) begin
                    items_accumulated_channels <= items_accumulated_channels + i_data_valid;
                    items_written_round <= items_written_round + i_data_valid; // todo
                    wr_valid <= i_data_valid;
                end else begin
                    wr_valid <= 0;
                end

                // for (int i = 0; i < CHANNELS_CNT; i = i + 1) begin
                //     // Enable the selected channel based on channel address
                //     if (CHANNELS_IDS[i] == wr_channel_select) begin
                //         rd_en_channels[CHANNELS_IDS[i]] <= i_data_valid;
                //         // rd_en_channels[CHANNELS_IDS[i]] <= wr_valid;
                //         wr_data_p1 <= wr_data + rd_data_channels[CHANNELS_IDS[i]];
                //     end
                // end


                // Accumulator Control Logic & Operations flow
                case (acc_state)
                    WAIT_FIRST_TRIGGER: begin

                        // Send data to FIFO channel if valid on trigger
                        // items_accumulated_channels <= items_accumulated_channels + (i_data_valid & i_acc_trigger);
                        items_accumulated_channels <= 0;
                        channel_rounds_cnt <= 0;
                        wr_channel_select <= 0;
                        items_written_round <= 0;

                        // items_written_round <= i_data_valid & i_acc_trigger;
                        // wr_valid <= i_data_valid & i_acc_trigger;
                        wr_valid <= 0;

                        // Change FSM state
                        if (i_acc_trigger == 1'b1) begin
                            acc_state <= WRITE_FIFO_CHANNEL_UNTIL_FULL;
                        end
                    end


                    WRITE_FIFO_CHANNEL_UNTIL_FULL: begin

                        // Fill channel until full
                        // channel_rounds_cnt <= channel_rounds_cnt + i_acc_trigger;
                        wr_channel_select <= wr_channel_select + i_acc_trigger;

                        // Allow to write to fifo if max number of items recorded per repetition have not been exceeded
                        // if (items_written_round != CHANNEL_DEPTH) begin
                        //     items_accumulated_channels <= items_accumulated_channels + i_data_valid;
                        //     items_written_round <= items_written_round + i_data_valid; // todo
                        //     wr_valid <= i_data_valid;
                        // end else begin
                        //     wr_valid <= 0;
                        // end

                        // 'channel_rounds_cnt' control
                        if (i_acc_trigger == 1'b1) begin
                            items_written_round <= 0;
                            if (CHANNEL_ACC_ROUNDS-1 == 0) begin
                                channel_rounds_cnt <= 0;
                                wr_channel_select <= wr_channel_select + 1;
                            end else begin
                                acc_state <= ACCUM_FIFO_CHANNEL;
                                wr_channel_select <= wr_channel_select;
                            end
                        end

                        // 'items_accumulated_channels' control
                        if (items_accumulated_channels == (CHANNEL_DEPTH*CHANNEL_ACC_ROUNDS)) begin
                            if (i_acc_trigger == 1'b1) begin
                                items_accumulated_channels <= 0;
                            end
                        end

                        // Next State Decision Logic: Readout
                        if (wr_channel_select == (CHANNELS_CNT-1)) begin
                            if (channel_rounds_cnt == (CHANNEL_ACC_ROUNDS-1)) begin
                                if (items_accumulated_channels == (CHANNEL_DEPTH*CHANNEL_ACC_ROUNDS)) begin
                                    acc_state <= READ_CHANNELS_UNTIL_EMPTY;
                                end
                            end
                        end
                    end


                    ACCUM_FIFO_CHANNEL: begin

                        // Fill channel until full
                        // channel_rounds_cnt <= channel_rounds_cnt + i_acc_trigger;

                        // if (items_written_round != CHANNEL_DEPTH) begin
                        //     items_accumulated_channels <= items_accumulated_channels + i_data_valid;
                        //     items_written_round <= items_written_round + i_data_valid; // todo
                        //     wr_valid <= i_data_valid;
                        // end else begin
                        //     wr_valid <= 0;
                        // end

                        for (int i = 0; i < CHANNELS_CNT; i = i + 1) begin
                            // Enable the selected channel based on channel address
                            if (CHANNELS_IDS[i] == wr_channel_select) begin
                                rd_en_channels[CHANNELS_IDS[i]] <= 0;
                                if (items_written_round != CHANNEL_DEPTH) begin
                                    rd_en_channels[CHANNELS_IDS[i]] <= i_data_valid;
                                end

                                // rd_en_channels[CHANNELS_IDS[i]] <= wr_valid;
                                wr_data_p1 <= wr_data + rd_data_channels[CHANNELS_IDS[i]];
                            end
                        end

                        // 'channel_rounds_cnt' control
                        if (i_acc_trigger == 1'b1) begin
                            if (channel_rounds_cnt == (CHANNEL_ACC_ROUNDS-1)) begin
                                acc_state <= WRITE_FIFO_CHANNEL_UNTIL_FULL;
                                channel_rounds_cnt <= 0;
                                wr_channel_select <= wr_channel_select + 1;
                            end
                        end

                        // 'items_accumulated_channels' and 'items_written_round' control
                        if (i_acc_trigger == 1'b1) begin
                            items_written_round <= 0;
                            if (items_accumulated_channels == (CHANNEL_DEPTH*CHANNEL_ACC_ROUNDS)) begin
                                items_accumulated_channels <= 0;
                            end
                        end

                        // Next State Decision Logic: Readout
                        if (wr_channel_select == (CHANNELS_CNT-1)) begin
                            if (channel_rounds_cnt == (CHANNEL_ACC_ROUNDS-1)) begin
                                if (items_accumulated_channels == (CHANNEL_DEPTH*CHANNEL_ACC_ROUNDS)) begin
                                    acc_state <= READ_CHANNELS_UNTIL_EMPTY;
                                end
                            end
                        end
                    end


                    READ_CHANNELS_UNTIL_EMPTY: begin
                        // No further accumulation events are expected.
                        items_accumulated_channels <= items_accumulated_channels;
                        channel_rounds_cnt <= channel_rounds_cnt;
                        wr_channel_select <= wr_channel_select;
                        items_written_round <= items_written_round;

                        o_acc_valid <= 1'b1;
                        

                        // Free the memory, if empty, go back to detect trigger event
                        if (empty_channels == {(CHANNELS_CNT){1'b1}}) begin
                            acc_state <= WAIT_FIRST_TRIGGER;
                            rst_channels <= {(CHANNELS_CNT){1'b1}};
                        end
                    end

                    default: begin

                        // Send data to FIFO channel if valid on trigger
                        acc_state <= WAIT_FIRST_TRIGGER;
                        items_accumulated_channels <= 0;
                        channel_rounds_cnt <= 0;
                        wr_channel_select <= 0;
                        items_written_round <= 0;
                        wr_valid <= 0;
                        o_acc_valid <= 0;
                        rst_channels <= 0;
                        rd_en_channels <= 0;
                
                    end

                endcase
            end
        end


        // Generate Multichannel FIFO
        fifo_wrselector #(
            .CHANNEL_WIDTH(CHANNEL_WIDTH),
            .CHANNEL_DEPTH(CHANNEL_DEPTH),
            .CHANNELS_CNT(CHANNELS_CNT)
        ) inst_fifo_wrselector (
            .clk(clk),
            .rst_all(i_rst),

            // Write port (of the respective FIFO channel)
            .rst_channels(rst_channels),

            .i_channel_wr_select(wr_channel_select),
            .i_wr_valid(wr_valid_p1),
            .i_wr_data(wr_data_p1),

            // Read port (of the respective FIFO channel)
            .i_rd_en_channels(rd_en_channels | i_rd_en_channels),
            .o_rd_valid_channels(o_rd_valid_channels),
            .o_rd_data_channels(rd_data_channels),

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