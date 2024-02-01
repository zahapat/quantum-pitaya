    
    module fifo_multichrdctrl #(
            parameter CHANNEL_WIDTH = 32,
            parameter RD_CHANNEL_CNT = 5,
            parameter RD_CHANNEL_DEPTH = 1024,
            parameter RD_DELAY_CYCLES = 5 // Wait to update the ready/valid flags from the multich fifo, thus doublereads
        )(
            input  logic clk,
            input  logic rst,

            // Commands
            input  logic i_cmd_valid, // Validate/invalidate the command
            input  logic [$clog2(RD_CHANNEL_CNT)-1:0] i_cmd_rdchsel, // Select channel to read from
            input  logic [$clog2(RD_CHANNEL_DEPTH):0] i_cmd_rdcnt, // Read transactions to be performed
            output logic o_cmd_ready, // This module ready to receive a command

            // Read port (Read from multichannel FIFO read selector)
            output logic o_multichannel_rd_en,
            input  logic [$clog2(RD_CHANNEL_CNT)-1:0] i_multichannel_rd_select, // Must agree with 'o_multichannel_rd_select' for this module to start its operation
            output logic [$clog2(RD_CHANNEL_CNT)-1:0] o_multichannel_rd_select, // Must be used to retreive data from the desired channel, then read the data

            input  logic i_multichannel_rd_valid,
            input  logic [CHANNEL_WIDTH-1:0] i_multichannel_rd_data,


            // Write port: Write to single-channel CDCC FIFO Buffer
            output logic o_singlechannel_wr_valid,
            output logic [CHANNEL_WIDTH-1:0] o_singlechannel_wr_data,
            input  logic i_singlechannel_wr_dready

        );

        // Signals
        logic wr_valid = 0;
        assign o_singlechannel_wr_valid = wr_valid;

        logic [CHANNEL_WIDTH-1:0] wr_data = 0;
        assign o_singlechannel_wr_data = wr_data;

        logic multichannel_rd_en = 0;
        assign o_multichannel_rd_en = multichannel_rd_en;

        logic doing_stuff;
        assign o_cmd_ready = ~doing_stuff;

        logic [$clog2(RD_DELAY_CYCLES)-1:0] rd_delay_counter = 0;
        logic rd_delay_counter_enable;

        // Lock read select and number of transactions
        logic [$clog2(RD_CHANNEL_CNT)-1:0] rdchsel = 0;
        assign o_multichannel_rd_select = rdchsel;

        logic [$clog2(RD_CHANNEL_DEPTH):0] rdcnt = 0;

        // Read Enable Delayed Trigger
        always @(posedge clk) begin

            // Default
            multichannel_rd_en <= 0;
            wr_valid <= 0;
            wr_data <= i_multichannel_rd_data;



            // Read Enable Counter: start counting after 'doing_stuff' is '1'
            rd_delay_counter <= rd_delay_counter + rd_delay_counter_enable;
            if (rd_delay_counter == RD_DELAY_CYCLES-1) begin
                rd_delay_counter <= 0;
            end

            // Enable counting if requested channel has been already switched, otherwise wait for comfirmation, then start counting
            if ((i_cmd_valid == 1'b1) | (doing_stuff == 1'b1)) begin
                if (rdchsel == i_multichannel_rd_select) begin
                    rd_delay_counter_enable <= 1'b1;
                end
            end

            // Make sure i_cmd_rdcnt is not 0; 0 does nothing (read 0 items is nonsense)
            // It will only switch the rdselector to a specific channel
            if (rdcnt != 0) begin
                // Do stuff
                if (rd_delay_counter == RD_DELAY_CYCLES-1) begin
                    if ((i_singlechannel_wr_dready == 1'b1) 
                        & (i_multichannel_rd_valid == 1'b1)) begin
                        rdcnt <= rdcnt - rd_delay_counter_enable;
                        multichannel_rd_en <= rd_delay_counter_enable;
                        wr_valid <= rd_delay_counter_enable;
                    end
                end
            end else begin
                doing_stuff <= 0;
                rd_delay_counter_enable <= 0;
            end

            // Set a new task, disregard the previous one if overriden
            if (i_cmd_valid == 1'b1) begin
                rdchsel <= i_cmd_rdchsel;
                rdcnt <= i_cmd_rdcnt; // make sure it is not 0, 0 does nothing (read 0 items is a nonsense)
                rd_delay_counter <= 0;
                rd_delay_counter_enable <= 0;
                doing_stuff <= 1'b1;
                // reads_done_counter <= 0;
            end

        end


    endmodule









// logic [$clog2(RD_CHANNEL_DEPTH)-1:0] reads_done_counter = 0;
    // If 'doing_stuff' is high -> do the task; Once done -> set 'doing_stuff' low
            // if (doing_stuff == 1'b1) begin
            //     // Do stuff
            //     if (rd_delay_counter == RD_DELAY_CYCLES-1) begin
            //         if (i_multichannel_rd_valid == 1'b1) begin
            //             multichannel_rd_en <= doing_stuff;
            //             reads_done_counter <= reads_done_counter + doing_stuff;
            //         end
            //     end
            //     if (reads_done_counter == rdcnt) begin
            //         doing_stuff = 0;
            //     end
            // end