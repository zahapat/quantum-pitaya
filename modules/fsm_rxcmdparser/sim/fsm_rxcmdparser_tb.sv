`timescale 1 ns / 1 ns  // time-unit = 1 ns, precision = 10 ps

module fsm_rxcmdparser_tb;

    // ------------------------------------------------
    // DUT IO Signals and Instance
    // ------------------------------------------------
    // Generics
    localparam FIFO_DATA_WIDTH = 32;
    localparam FIFO_CMD_WIDTH = 32;
    localparam CMD_OUTPUT_WIDTH = 5;
    localparam MODULE_SELECT_WIDTH = 5;
    localparam MODULES_CNT = 13;

    // Ports
    logic clk = 0;
    logic rst = 0;

    logic i_cmd_valid;
    logic o_cmd_rd_en;

    logic i_data_valid;
    logic o_data_rd_en;

    logic [MODULES_CNT-1:0] o_pipeline_read_valid;
    logic [MODULES_CNT-1:0] o_pipeline_write_valid;

    logic [MODULES_CNT-1:0] [MODULE_SELECT_WIDTH-1:0] o_pipeline_addr;
    logic [MODULES_CNT-1:0] [CMD_OUTPUT_WIDTH-1:0] o_pipeline_cmd;
    logic [MODULES_CNT-1:0] [FIFO_DATA_WIDTH-1:0] o_pipeline_data;



    logic clk_wr = 1'b1;
    logic wr_rst = 0;
    logic rd_rst = 0;

    localparam INT_FIFO_WIDTH_cmd = 32;
    localparam INT_FIFO_DEPTH_cmd = 64;

    logic [INT_FIFO_WIDTH_cmd-1:0] i_data_cmd;
    logic i_valid_cmd;
    logic o_ready_cmd;

    logic [INT_FIFO_WIDTH_cmd-1:0] o_data_cmd;
    logic o_data_valid_cmd;
    logic i_dready_cmd;



    localparam INT_FIFO_WIDTH_data = 32;
    localparam INT_FIFO_DEPTH_data = INT_FIFO_DEPTH_cmd;

    logic [INT_FIFO_WIDTH_data-1:0] i_data_data;
    logic i_valid_data;
    logic o_ready_data;

    logic [INT_FIFO_WIDTH_data-1:0] o_data_data;
    logic o_data_valid_data;
    logic i_dready_data;


    // DUT Instance
    fsm_rxcmdparser #(
        .FIFO_DATA_WIDTH(FIFO_DATA_WIDTH),
        .FIFO_CMD_WIDTH(FIFO_CMD_WIDTH),
        .CMD_OUTPUT_WIDTH(CMD_OUTPUT_WIDTH),
        .MODULE_SELECT_WIDTH(MODULE_SELECT_WIDTH),
        .MODULES_CNT(MODULES_CNT)
    ) dut (
        .clk(clk),
        .rst(rst),

        // Cmd FIFO
        .i_cmd(o_data_cmd),
        .i_cmd_valid(o_data_valid_cmd),
        .o_cmd_rd_en(o_cmd_rd_en),

        // Data FIFO
        .i_data(o_data_data),
        .i_data_valid(o_data_valid_data),
        .o_data_rd_en(o_data_rd_en),

        // Outputs
        .o_pipeline_read_valid(o_pipeline_read_valid),
        .o_pipeline_write_valid(o_pipeline_write_valid),
        .o_pipeline_addr(o_pipeline_addr),
        .o_pipeline_cmd(o_pipeline_cmd),
        .o_pipeline_data(o_pipeline_data)
    );


    // FIFO transfering commands
    fifo_cdcc #(
        .INT_FIFO_WIDTH(INT_FIFO_WIDTH_cmd),
        .INT_FIFO_DEPTH(INT_FIFO_DEPTH_cmd)
    ) inst_fifo_cmd (
        // Signals
        .wr_clk(clk_wr),
        .wr_rst(wr_rst),
        .rd_clk(clk),
        .rd_rst(rd_rst),

        // Write
        .i_data(i_data_cmd),
        .i_valid(i_valid_cmd),
        .o_ready(o_ready_cmd),

        // Read
        .o_data(o_data_cmd),
        .o_data_valid(o_data_valid_cmd),
        .i_dready(o_cmd_rd_en)
    );


    // FIFO transfering data
    fifo_cdcc #(
        .INT_FIFO_WIDTH(INT_FIFO_WIDTH_data),
        .INT_FIFO_DEPTH(INT_FIFO_DEPTH_data)
    ) inst_fifo_data (
        // Signals
        .wr_clk(clk_wr),
        .wr_rst(wr_rst),
        .rd_clk(clk),
        .rd_rst(rd_rst),

        // Write
        .i_data(i_data_data),
        .i_valid(i_valid_data),
        .o_ready(o_ready_data),

        // Read
        .o_data(o_data_data),
        .o_data_valid(o_data_valid_data),
        .i_dready(o_data_rd_en)
    );

    // Clocks
    parameter clk_period_ns = 8; // * 1 ns on timescale
    initial forever begin #(clk_period_ns/2) clk = ~clk; end

    parameter clk_period_wr_ns = 5; // * 1 ns on timescale
    initial forever begin #(clk_period_wr_ns/2) clk_wr = ~clk_wr; end


    // ------------------------------------------------
    // Tasks
    // ------------------------------------------------


    // ------------------------------------------------
    // Stimulus Read
    // ------------------------------------------------
    initial begin
        rst = 1'b1;
        @(posedge clk);
        rst = 1'b0;
        @(posedge clk);

        for (int m = 1; m <= MODULES_CNT; m = m + 1) begin
            for (int c = 1; c <= INT_FIFO_DEPTH_cmd; c = c + 1) begin
                wait (o_pipeline_read_valid[m] == 1'b1);
                $display($time, "                       CATCHED EXPECTED READ;  cmd  = ", o_pipeline_cmd[m]);
                @(posedge clk);
            end
            for (int c = 1; c <= INT_FIFO_DEPTH_cmd; c = c + 1) begin
                wait (o_pipeline_write_valid[m] == 1'b1);
                $display($time, "                       CATCHED EXPECTED WRITE; cmd  = ", o_pipeline_cmd[m]);
                $display($time, "                                               data = ", o_pipeline_data[m]);
                @(posedge clk);
            end
        end

        @(posedge clk);
        $display($time, "                       CATCHED ALL");

    end

    // ------------------------------------------------
    // Stimulus Write
    // ------------------------------------------------
    initial begin
        rst = 1'b1;
        #100ns;
        @(posedge clk_wr);
        rst = 1'b0;
        @(posedge clk_wr);


        // For each module send set of transactions (read, write)
        for (int m = 1; m <= MODULES_CNT; m = m + 1) begin
            #200ns;
            @(posedge clk_wr);
            $display($time, "                       module_select =  ", m);
            $display($time, "                       READ COMMANDS");
            for (int c = 1; c <= INT_FIFO_DEPTH_cmd; c = c + 1) begin
                i_data_cmd = 0;
                i_data_cmd[0] = 0; // Read (0) or Write (1)
                i_data_cmd[MODULE_SELECT_WIDTH:1] = MODULE_SELECT_WIDTH'(m);
                i_data_cmd[INT_FIFO_WIDTH_cmd-1:MODULE_SELECT_WIDTH+1] = INT_FIFO_WIDTH_cmd'(c);
                i_valid_cmd = 1'b1;
                $display($time, "                       i_data_cmd[0] =  ", i_data_cmd[0]);
                $display($time, "                       i_data_cmd[MODULE_SELECT_WIDTH:1] =  ", i_data_cmd[MODULE_SELECT_WIDTH:1]);
                $display($time, "                       i_data_cmd =  ", INT_FIFO_WIDTH_cmd'(c));
                $display($time, "                       i_valid_cmd =  ", i_valid_cmd);

                i_data_data = 0;
                i_valid_data = 1'b0;
                $display($time, "                       i_data_data =  ", i_data_data);
                $display($time, "                       i_valid_data =  ", i_valid_data);
                @(posedge clk_wr);
                i_data_cmd = 0; i_valid_cmd = 0; i_data_data = 0; i_valid_data = 0;
                @(posedge clk_wr);
                @(posedge clk_wr);
                @(posedge clk_wr);
                @(posedge clk_wr);
            end

            #50ns;
            @(posedge clk_wr);
            $display($time, "                       module_select =  ", m);
            $display($time, "                       WRITE COMMANDS");
            for (int c = 1; c <= INT_FIFO_DEPTH_cmd; c = c + 1) begin
                i_data_cmd = 0;
                i_data_cmd[0] = 1'b1; // Read (0) or Write (1)
                i_data_cmd[MODULE_SELECT_WIDTH:1] = MODULE_SELECT_WIDTH'(m);
                i_data_cmd[INT_FIFO_WIDTH_cmd-1:MODULE_SELECT_WIDTH+1] = INT_FIFO_WIDTH_cmd'(c);
                i_valid_cmd = 1'b1;
                $display($time, "                       i_data_cmd[0] =  ", i_data_cmd[0]);
                $display($time, "                       i_data_cmd[MODULE_SELECT_WIDTH:1] =  ", i_data_cmd[MODULE_SELECT_WIDTH:1]);
                $display($time, "                       i_data_cmd =  ", INT_FIFO_WIDTH_cmd'(c));
                $display($time, "                       i_valid_cmd =  ", i_valid_cmd);

                i_data_data = INT_FIFO_WIDTH_data'(c);
                i_valid_data = 1'b1;
                $display($time, "                       i_data_data =  ", i_data_data);
                $display($time, "                       i_valid_data =  ", i_valid_data);
                @(posedge clk_wr);
                i_data_cmd = 0; i_valid_cmd = 0; i_data_data = 0; i_valid_data = 0;
                @(posedge clk_wr);
                @(posedge clk_wr);
                @(posedge clk_wr);
            end
        end


        #100ns;
        @(posedge clk_wr);

        $finish; // End of Simulation
    end
    
    
endmodule