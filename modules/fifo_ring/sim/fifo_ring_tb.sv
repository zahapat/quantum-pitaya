`timescale 1 ns / 1 ns  // time-unit = 1 ns, precision = 10 ps

module fifo_ring_tb;

    // ------------------------------------------------
    // DUT IO Signals and Instance
    // ------------------------------------------------
    // Generics
    localparam RAM_WIDTH = 32;
    localparam RAM_DEPTH = 256;

    // Signals (drivers)
    logic clk = 1'b1;
    logic rst;

     // Write port
    logic i_wr_valid;
    logic [RAM_WIDTH-1:0] i_wr_data;

    // Read port
    logic i_rd_en;
    logic o_rd_valid;
    logic [RAM_WIDTH-1:0] o_rd_data;

    // Flags
    logic o_ready;
    logic o_empty;
    logic o_empty_next;
    logic o_full;
    logic o_full_next;

    // The number of elements in the FIFO
    logic [$clog2(RAM_DEPTH):0] o_fill_count;

    // DUT Instance
    fifo_ring #(
        .RAM_WIDTH(RAM_WIDTH),
        .RAM_DEPTH(RAM_DEPTH) // Must be a multiple of 2 (because of Gray counter width)
    ) dut (
        .clk(clk),
        .rst(rst),

        // Write port
        .i_wr_valid(i_wr_valid),
        .i_wr_data(i_wr_data),

        // Read port
        .i_rd_en(i_rd_en),
        .o_rd_valid(o_rd_valid),
        .o_rd_data(o_rd_data),

        // Flags
        .o_ready(o_ready),
        .o_empty(o_empty),
        .o_empty_next(o_empty_next),
        .o_full(o_full),
        .o_full_next(o_full_next),

        // The number of elements in the FIFO
        .o_fill_count(o_fill_count)
    );

    // Clocks
    parameter clk_period_ns = 10; // * 1 ns on timescale
    initial forever begin #(clk_period_ns/2) clk = ~clk; end


    // ------------------------------------------------
    // Tasks
    // ------------------------------------------------
    task task_wr_rst ();
        rst = 1'b1;
        #(20*clk_period_ns);
        rst = 0;
    endtask

    task task_rd_rst ();
        rst = 1'b1;
        #(20*clk_period_ns);
        rst = 0;
    endtask

    integer i; task task_write_burst_until_full();
        #(1*clk_period_ns);

        // Synchronous Write
        wait (o_empty == 1'b1);
        @(posedge clk);
        for (i = 1; i <= RAM_DEPTH; i = i + 1) begin
            if (o_full == 1'b0) begin
                i_wr_valid = 1'b1;
                i_wr_data = i;
                $display($time, "   i_wr_data = ", i, " << TX data to DUT");
            end else begin
                i_wr_valid = 1'b0;
                i_wr_data = 0;
                $display($time, "   i_wr_data = ", 0, " << i_wr_data set to 0, no TX");
            end
            @(posedge clk);
        end
        $display($time, "   i_wr_data = ", 0, " << i_wr_data set to 0, no TX");
        i_wr_valid = 1'b0;
        i_wr_data = 0;
        $display($time, "   End of TX");
        @(posedge clk);
        #(20*clk_period_ns);
    endtask

    task task_read_from_full_until_empty();
        @(posedge clk);
        #(50*clk_period_ns);
        // Synchronous Read, (always read)

        wait (o_rd_valid == 1'b1);
        $display($time, "   Some data are stored in the FIFO");

        // Wait until the FIFO is full
        wait (o_full == 1'b1);
        @(posedge clk);
        $display($time, "   FIFO is Full, read all its content");
        for (;;) begin
            if (o_rd_valid == 1'b1) begin
                i_rd_en = 1'b1;
                @(posedge clk); // Send Dready
                $display($time, "   o_rd_data = ", o_rd_data, " << RX data from DUT");
            end else if (o_rd_valid == 1'b0) begin
                i_rd_en = 1'b0;
                @(posedge clk);
                $display($time, "   FIFO is Empty, break");
                break;
            end
        end

        #(50*clk_period_ns);
    endtask


    // ------------------------------------------------
    // Write Stimulus
    // ------------------------------------------------
    initial begin
        i_wr_valid = 1'b0;
        $display($time, " << Starting the Simulation");
        task_wr_rst();
        task_write_burst_until_full();

        // Wait until fifo is empty and ready to accept data
        wait (o_ready == 1'b1);
        wait (o_rd_valid == 1'b0);
        #100ns
        // Synchronous Write "RAM_DEPTH"-times each after 100ns
        // i = 1;
        repeat (RAM_DEPTH) begin
            @(posedge clk);
            if (o_ready == 1'b1) begin
                i_wr_valid = 1'b1;
                i_wr_data = i;
                $display($time, "   i_wr_data = ", i, " << TX data to DUT");
            end else begin 
                $display($time, "   o_ready = ", o_ready, " << FIFO full, prevent write");
            end
            @(posedge clk);
            i_wr_valid = 1'b0;
            @(posedge clk);
            #100ns;
            i = i + 1;
        end
        // $finish; // End of Simulation
    end

    // ------------------------------------------------
    // Read Stimulus
    // ------------------------------------------------
    initial begin
        i_rd_en = 1'b0;
        task_rd_rst();
        task_read_from_full_until_empty();

        // Wait until fifo is empty and ready to accept data, dready is always high
        // wait (o_ready == 1'b1);
        // task_read_from_full_until_empty();
        // wait (o_rd_valid == 1'b0);


        // @(posedge clk);
        // i_rd_en = 1'b1;

        // Synchronous Read: Detect "RAM_DEPTH" values
        // repeat (RAM_DEPTH) begin
        //     wait (o_rd_valid == 1'b1) begin
        //         $display($time, "   o_rd_data = ", o_rd_data, " << RX data from DUT");
        //     end
        // end;
        // @(posedge clk);
        
        $finish; // End of Simulation
    end


endmodule