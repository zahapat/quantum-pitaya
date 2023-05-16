`timescale 1 ns / 1 ns  // time-unit = 1 ns, precision = 10 ps

module fifo_cdcc_tb;

    // ------------------------------------------------
    // DUT IO Signals and Instance
    // ------------------------------------------------
    // Generics
    localparam INT_FIFO_WIDTH = 32;
    localparam INT_FIFO_DEPTH = 256;
    localparam INT_FIFO_PTR_BITS_CNT = $clog2(INT_FIFO_DEPTH);
    // Write Signals (drivers)
    reg wr_clk = 1'b1;
    reg wr_rst = 0;
    // Read Signals (drivers)
    reg rd_clk = 1'b1;
    reg rd_rst = 0;
    // AXI Input Signals
    reg[INT_FIFO_WIDTH-1:0] i_data;
    reg i_valid;
    wire o_ready;
    // AXI Output Signals
    wire[INT_FIFO_WIDTH-1:0] o_data;
    wire o_data_valid;
    reg i_dready;
    // DUT Instance
    fifo_cdcc #(
        .INT_FIFO_WIDTH(INT_FIFO_WIDTH),
        .INT_FIFO_DEPTH(INT_FIFO_DEPTH) // Must be a multiple of 2 (because of Gray counter width)
    ) inst_fifo_cdcc_dut (
        // Write Signals
        .wr_clk(wr_clk),
        .wr_rst(wr_rst),

        // Read Signals
        .rd_clk(rd_clk),
        .rd_rst(rd_rst),

        // AXI Input Ports
        .i_data(i_data),
        .i_valid(i_valid),
        .o_ready(o_ready),    // This module ready

        // AXI Output Ports
        .o_data(o_data),
        .o_data_valid(o_data_valid),
        .i_dready(i_dready)    // Destinantion ready
    );

    // Clocks
    parameter clk1_period_ns = 10; // * 1 ns on timescale
    parameter clk2_period_ns = 6; // * 1 ns on timescale
    // initial begin forever #10 wr_clk = ~wr_clk; end
    initial forever begin #(clk1_period_ns/2) wr_clk = ~wr_clk; end
    initial forever begin #(clk2_period_ns/2) rd_clk = ~rd_clk; end


    // ------------------------------------------------
    // Tasks
    // ------------------------------------------------
    task task_wr_rst ();
        wr_rst = 1'b1;
        #(20*clk1_period_ns);
        wr_rst = 0;
    endtask
    task task_rd_rst ();
        rd_rst = 1'b1;
        #(20*clk2_period_ns);
        rd_rst = 0;
    endtask
    integer i; task task_write_burst_until_full();
        #(1*clk1_period_ns);

        // Synchronous Write
        wait (o_ready == 1'b1);
        @(posedge wr_clk);
        for (i = 1; i <= INT_FIFO_DEPTH; i = i + 1) begin
            if (o_ready == 1'b1) begin
                i_valid = 1'b1;
                i_data = i;
                $display($time, "   i_data = ", i, " << TX data to DUT");
            end else begin
                i_valid = 1'b0;
                i_data = 0;
                $display($time, "   i_data = ", 0, " << i_data set to 0, no TX");
            end
            @(posedge wr_clk);
        end
        $display($time, "   i_data = ", 0, " << i_data set to 0, no TX");
        i_valid = 1'b0;
        i_data = 0;
        $display($time, "   End of TX");
        @(posedge wr_clk);
        #(20*clk1_period_ns);
    endtask
    task task_read_from_full_until_empty();
        @(posedge wr_clk);
        #(50*clk2_period_ns);
        // Synchronous Read, (always read)

        wait (o_data_valid == 1'b1);
        $display($time, "   Some data are stored in the FIFO");
        
        // Wait until the FIFO is full
        wait (o_ready == 1'b0);
        @(posedge rd_clk);
        $display($time, "   FIFO is Full, read all its content");
        for (;;) begin
            if (o_data_valid == 1'b1) begin
                i_dready = 1'b1;
                @(posedge rd_clk); // Send Dready
                $display($time, "   o_data = ", o_data, " << RX data from DUT");
            end else if (o_data_valid == 1'b0) begin
                i_dready = 1'b0;
                @(posedge rd_clk);
                $display($time, "   FIFO is Empty, break");
                break;
            end
        end

        #(50*clk2_period_ns);
    endtask


    // ------------------------------------------------
    // Write Stimulus
    // ------------------------------------------------
    initial begin
        i_valid = 1'b0;
        $display($time, " << Starting the Simulation");
        task_wr_rst();
        task_write_burst_until_full();

        // Wait until fifo is empty and ready to accept data
        wait (o_ready == 1'b1);
        wait (o_data_valid == 1'b0);
        #100ns
        // Synchronous Write "INT_FIFO_DEPTH"-times each after 100ns
        // i = 1;
        repeat (INT_FIFO_DEPTH) begin
            @(posedge wr_clk);
            if (o_ready == 1'b1) begin
                i_valid = 1'b1;
                i_data = i;
                $display($time, "   i_data = ", i, " << TX data to DUT");
            end else begin 
                $display($time, "   o_ready = ", o_ready, " << FIFO full, prevent write");
            end
            @(posedge wr_clk);
            i_valid = 1'b0;
            @(posedge wr_clk);
            #100ns;
            i = i + 1;
        end
        // $finish; // End of Simulation
    end

    // ------------------------------------------------
    // Read Stimulus
    // ------------------------------------------------
    initial begin
        i_dready = 1'b0;
        task_rd_rst();
        task_read_from_full_until_empty();

        // Wait until fifo is empty and ready to accept data, dready is always high
        wait (o_ready == 1'b1);
        task_read_from_full_until_empty();
        wait (o_data_valid == 1'b0);
        // @(posedge rd_clk);
        // i_dready = 1'b1;

        // Synchronous Read: Detect "INT_FIFO_DEPTH" values
        // repeat (INT_FIFO_DEPTH) begin
        //     wait (o_data_valid == 1'b1) begin
        //         $display($time, "   o_data = ", o_data, " << RX data from DUT");
        //     end
        // end;
        // @(posedge rd_clk);
        $finish; // End of Simulation
    end


endmodule