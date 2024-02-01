    
    module fsm_rxcmdparser #(
            parameter FIFO_DATA_WIDTH = 32,
            parameter FIFO_CMD_WIDTH = 32,
            parameter CMD_OUTPUT_WIDTH = 5,
            parameter MODULE_SELECT_WIDTH = 5,
            parameter MODULES_CNT = 19 // on Zynq 7010 19 is the max value that won't give a warning
        )(
            input  logic clk,
            input  logic rst,

            // Read FIFO cmd port (queue of RX commands/instructions)
            input  logic [FIFO_CMD_WIDTH-1:0] i_cmd,
            input  logic i_cmd_valid,
            output logic o_cmd_rd_en, // update read pointer

            // Read FIFO data port (queue of RX data)
            input  logic [FIFO_DATA_WIDTH-1:0] i_data,
            input  logic i_data_valid,
            output logic o_data_rd_en, // update read pointer

            // Command Pipeline
            output logic [MODULES_CNT-1:0] o_pipeline_read_valid,
            output logic [MODULES_CNT-1:0] o_pipeline_write_valid,
            output logic [MODULES_CNT-1:0] [MODULE_SELECT_WIDTH-1:0] o_pipeline_addr,
            output logic [MODULES_CNT-1:0] [CMD_OUTPUT_WIDTH-1:0] o_pipeline_cmd,
            output logic [MODULES_CNT-1:0] [FIFO_DATA_WIDTH-1:0] o_pipeline_data
        );

        // Example: FIFO_CMD_WIDTH     = 32 bit CMD Transaction
        // Example: CMD_DESTADDR_WIDTH = 5
        // -------------------------------------------------------------------------------------------------
        // |31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0|
        //                 NOT USED                     |             COMMAND             |MODULE_SELECT|RW|
        // -------------------------------------------------------------------------------------------------

        // -----------------------------------------------------------
        // |         Write CMD         |          Read CMD           |
        // -----------------------------------------------------------
        // |  ... To write somewhere   |  ... To read from somwhere  |
        // |    / update write ptr     |      / update read ptr      |
        // -----------------------------------------------------------


        // Signals
        logic read_or_write;
        assign read_or_write = i_cmd[0]; // Write == 1'b1; Read == 1'b0
        logic [MODULE_SELECT_WIDTH-1:0] module_select;
        assign module_select = i_cmd[MODULE_SELECT_WIDTH:1];
        logic [CMD_OUTPUT_WIDTH-1:0] cmd;
        assign cmd = i_cmd[CMD_OUTPUT_WIDTH + MODULE_SELECT_WIDTH+1:MODULE_SELECT_WIDTH+1];


        // CMD pipeline
        logic [MODULES_CNT:0] pipeline_read_valid = 0;
        logic [MODULES_CNT-1:0] pipeline_read_valid_out = 0;
        assign o_pipeline_read_valid = pipeline_read_valid_out;
        logic [MODULES_CNT:0] pipeline_write_valid = 0;
        logic [MODULES_CNT-1:0] pipeline_write_valid_out = 0;
        assign o_pipeline_write_valid = pipeline_write_valid_out;
        logic [MODULES_CNT:0] [MODULE_SELECT_WIDTH-1:0] pipeline_addr = 0;
        assign o_pipeline_addr = pipeline_addr[MODULES_CNT:1];
        logic [MODULES_CNT:0] [CMD_OUTPUT_WIDTH-1:0] pipeline_cmd = 0;
        assign o_pipeline_cmd = pipeline_cmd[MODULES_CNT:1];
        logic [MODULES_CNT:0] [FIFO_DATA_WIDTH-1:0] pipeline_data = 0;
        assign o_pipeline_data = pipeline_data[MODULES_CNT:1];

        always @* begin
            // Read cmd ack only if i_cmd[0] is low, otherwise wait for it
            o_cmd_rd_en <= i_cmd_valid;
            if (i_cmd_valid == 1'b1) begin
                if (i_cmd[0] == 1'b0) begin
                    // No wait for ch2 data -> send enable command
                    o_cmd_rd_en <= i_cmd_valid;
                end else begin
                    // Wait for ch2 data -> send data enable command once detected
                    o_cmd_rd_en <= i_data_valid;
                end
            end


            // Read data ack only if valid "write" cmd is to be read
            o_data_rd_en <= i_data_valid & i_cmd_valid & i_cmd[0];
        end


        // Pre-calculate Module IDs (start with 1, 0 is invalid)
        typedef logic [MODULE_SELECT_WIDTH-1:0] array_2d [MODULES_CNT-1:0];
        function array_2d generate_module_ids;
            array_2d rom_values;
            for (int i = 1; i <= MODULES_CNT; i = i + 1) begin
                rom_values[i-1] = MODULE_SELECT_WIDTH'(i);
            end
            return rom_values;
        endfunction
        array_2d MODULE_IDS = generate_module_ids();


        // Parsing the 'i_cmd' port on i_cmd_valid & i_data_valid
        always @(posedge clk) begin
            if (rst == 1'b1) begin
                pipeline_write_valid <= 0;
                pipeline_read_valid <= 0;
            end else begin

                // Default
                pipeline_write_valid[0] <= 0;
                pipeline_read_valid[0] <= 0;
                pipeline_addr[0] <= 0;
                // pipeline_data[0] <= i_data;
                // pipeline_cmd[0] <= cmd;

                pipeline_write_valid_out <= 0;
                pipeline_read_valid_out <= 0;

                // Pipeline: distribute parsed values to desired modules on addresses
                for (int i = 0; i < MODULES_CNT; i = i + 1) begin
                    pipeline_write_valid[i+1] <= pipeline_write_valid[i];
                    pipeline_read_valid[i+1] <= pipeline_read_valid[i];

                    pipeline_addr[i+1] <= pipeline_addr[i];
                    pipeline_data[i+1] <= pipeline_data[i];
                    pipeline_cmd[i+1] <= pipeline_cmd[i];

                    if (MODULE_IDS[i] == pipeline_addr[i]) begin
                        pipeline_write_valid_out[i] <= pipeline_write_valid[i];
                        pipeline_read_valid_out[i] <= pipeline_read_valid[i];
                    end
                end


                // If read/switch or write/set operation is requested:
                if (module_select != 0) begin
                    // Read/switch cmd detected, read only from cmd fifo
                    if ((i_cmd_valid == 1'b1) & (i_data_valid == 0)) begin
                        if (read_or_write == 1'b0) begin
                            pipeline_read_valid[0] <= i_cmd_valid;
                            pipeline_addr[0] <= module_select;
                            pipeline_cmd[0] <= cmd;
                        end
                    end

                    // Write/set cmd detected, read from both cmd and data fifo
                    if ((i_cmd_valid == 1'b1) & (i_data_valid == 1'b1)) begin
                        if (read_or_write == 1'b1) begin
                            pipeline_write_valid[0] <= i_cmd_valid & i_data_valid;
                            pipeline_addr[0] <= module_select;
                            pipeline_data[0] <= i_data;
                            pipeline_cmd[0] <= cmd;
                        end
                    end
                end
                

            end
        end
   
    endmodule