`timescale 1 ns / 1 ns

module fifo_cdcc
    #(
        parameter INT_FIFO_WIDTH = 32,
        parameter INT_FIFO_DEPTH = 1024 // Must be a multiple of 2 (because of Gray counter width)
    )(
        // Write Signals
        input  wire wr_clk,
        input  wire wr_rst,

        // Read Signals
        input  wire rd_clk,
        input  wire rd_rst,

        // AXI Input Ports
        input  wire[INT_FIFO_WIDTH-1:0] i_data,
        input  wire i_valid,
        output wire o_ready,    // This module ready

        // AXI Output Ports
        output wire[INT_FIFO_WIDTH-1:0] o_data,
        output wire o_data_valid,
        input  wire i_dready    // Destinantion ready
    );


    // Declare Constants
    localparam INT_FIFO_PTR_BITS_CNT = $clog2(INT_FIFO_DEPTH);

    // Loop variable
    genvar i;

    // Declare RAM
    reg[INT_FIFO_WIDTH-1:0] bram [INT_FIFO_DEPTH-1:0];
    reg[INT_FIFO_WIDTH-1:0] reg_o_data = 0;

    // Write Ctrl Signals
    wire write_en;
    wire[INT_FIFO_PTR_BITS_CNT-1:0] wr_bin_address_bram;
    wire[INT_FIFO_PTR_BITS_CNT:0] wr_grayptr_in_wrclk;
    reg[INT_FIFO_PTR_BITS_CNT:0] wr_grayptr_to_rdclk_1;
    reg[INT_FIFO_PTR_BITS_CNT:0] wr_grayptr_to_rdclk_2;

    // Read Ctrl Signals
    wire rd_en;
    wire[INT_FIFO_PTR_BITS_CNT-1:0] rd_bin_address_bram;
    wire[INT_FIFO_PTR_BITS_CNT:0] rd_grayptr_in_rdclk;
    reg[INT_FIFO_PTR_BITS_CNT:0] rd_grayptr_to_wrclk_1;
    reg[INT_FIFO_PTR_BITS_CNT:0] rd_grayptr_to_wrclk_2;


    // Write Ctrl
    // Input is a gray encoded pointer
    // Output 1 is an unsigned address for writing to RAM
    // Output 2 is an incremented gray encoded RAM address
    fifo_write_gray_ctrl #(
        .INT_FIFO_PTR_BITS_CNT(INT_FIFO_PTR_BITS_CNT)
    ) inst_fifo_write_gray_ctrl (
        // Write Signals
        .wr_clk(wr_clk),
        .wr_rst(wr_rst),
        .write_en(write_en),

        // AXI Input Port
        .i_valid(i_valid),
        .o_ready(o_ready),    // This module ready flag

        // Pointers on the WR side
        .o_wr_intptr(wr_bin_address_bram),
        .o_wr_grayptr(wr_grayptr_in_wrclk),
        .i_rd_grayptr(rd_grayptr_to_wrclk_2)
    );


    // Read Ctrl
    // Input is a gray encoded pointer
    // Output 1 is an unsigned address for reading from RAM
    // Output 2 is an incremented gray encoded RAM address
    fifo_read_gray_ctrl #(
        .INT_FIFO_PTR_BITS_CNT(INT_FIFO_PTR_BITS_CNT)
    ) inst_fifo_read_gray_ctrl (
        // Write Signals
        .rd_clk(rd_clk),
        .rd_rst(rd_rst),
        .rd_en(rd_en),

        // AXI Input Port
        .i_dready(i_dready),
        .o_valid(o_data_valid),    // This module ready flag

        // Pointers on the WR side
        .i_wr_grayptr(wr_grayptr_to_rdclk_2),
        .o_rd_intptr(rd_bin_address_bram),
        .o_rd_grayptr(rd_grayptr_in_rdclk)
    );


    // 2-FF Synchronizers. No reset for better placement freedom and reducing routing congestion
    always @(posedge wr_clk) begin
        rd_grayptr_to_wrclk_1 <= rd_grayptr_in_rdclk;
        rd_grayptr_to_wrclk_2 <= rd_grayptr_to_wrclk_1;
    end
    always @(posedge rd_clk) begin
        wr_grayptr_to_rdclk_1 <= wr_grayptr_in_wrclk;
        wr_grayptr_to_rdclk_2 <= wr_grayptr_to_rdclk_1;
    end


    // Dual-port RAM: Show BRAM content of the current pointer
    always @(posedge wr_clk) begin
        if (write_en) begin
            bram[wr_bin_address_bram] <= i_data;
        end
    end

    // Dual-port RAM: Show BRAM content of the current pointer
    assign o_data = reg_o_data;
    always @(posedge rd_clk) begin
        if (rd_en) begin
            reg_o_data <= bram[rd_bin_address_bram];
        end
    end

endmodule