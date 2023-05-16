`timescale 1 ns / 1 ps

module fifo_write_ctrl
    #(
        parameter INT_FIFO_PTR_BITS_CNT = 32
    )(
        // Write Signals
        input  wire wr_clk,
        input  wire wr_rst,

        // AXI Input Port
        input  wire i_valid,
        output wire o_ready,    // This module ready flag

        // Pointers on the WR side
        output wire[INT_FIFO_PTR_BITS_CNT-1:0] o_wr_ptr,
        input wire[INT_FIFO_PTR_BITS_CNT-1:0] i_rd_ptr
    );

    // Declare constants
    // Recalculate the number of elements
    localparam INT_RAM_DEPTH = 2**INT_FIFO_PTR_BITS_CNT;


    // Declare signals & initial conditions
    wire[INT_FIFO_PTR_BITS_CNT-1:0] int_elements_cnt;
    reg[INT_FIFO_PTR_BITS_CNT-1:0] int_head_ptr;
    wire[INT_FIFO_PTR_BITS_CNT-1:0] int_tail_ptr;
    wire ready_flag;

    // Asynchonous ready control: Ready is asserted if BRAM is not full
    assign o_wr_ptr = int_head_ptr;
    assign int_tail_ptr = i_rd_ptr;
    assign int_elements_cnt = int_head_ptr - int_tail_ptr;
    assign ready_flag = (int_elements_cnt < INT_RAM_DEPTH-1) ? 1'b1 : 1'b0;
    assign o_ready = ready_flag;

    // Synchronous process: Increment head
    always @(posedge wr_clk) begin
        if (wr_rst == 1'b1) begin
            int_head_ptr <= {(INT_FIFO_PTR_BITS_CNT){1'b0}};
        end else begin
            if (ready_flag == 1'b1 && i_valid == 1'b1) begin
                int_head_ptr <= int_head_ptr + 1;
            end
        end
    end

endmodule