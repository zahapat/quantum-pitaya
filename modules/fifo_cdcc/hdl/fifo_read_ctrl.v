`timescale 1 ns / 1 ps

module fifo_read_ctrl
    #(
        parameter INT_FIFO_PTR_BITS_CNT = 9
    )(
        // Write Signals
        input  wire rd_clk,
        input  wire rd_rst,

        // AXI Input Port
        input  wire i_dready,
        output wire o_valid,    // This module ready flag

        // Pointers on the WR side
        input wire[INT_FIFO_PTR_BITS_CNT-1:0] i_wr_ptr,
        output wire[INT_FIFO_PTR_BITS_CNT-1:0] o_rd_ptr
    );

    // Declare signals & initial conditions
    wire[INT_FIFO_PTR_BITS_CNT-1:0] int_elements_cnt;
    wire[INT_FIFO_PTR_BITS_CNT-1:0] int_head_ptr;
    reg[INT_FIFO_PTR_BITS_CNT-1:0] int_tail_ptr;
    wire valid_flag;
    reg[INT_FIFO_PTR_BITS_CNT-1:0] rd_ptr = {INT_FIFO_PTR_BITS_CNT{1'b0}}, rd_ptr_next;


    // Asynchonous valid control: Valid is asserted if BRAM is not full
    assign int_head_ptr = i_wr_ptr;
    assign int_elements_cnt = int_head_ptr - int_tail_ptr;
    assign valid_flag = (int_elements_cnt == {(INT_FIFO_PTR_BITS_CNT){1'b0}}) ? 1'b0 : 1'b1;
    assign o_valid = valid_flag;


    // Asynchronous ready control: Increment tail if data valid and ready: 
    always @* begin
        if (i_dready == 1'b1 && valid_flag == 1'b1) begin 
            rd_ptr <= (int_tail_ptr + 1);
        end else begin
            rd_ptr <= int_tail_ptr;
        end
    end
    assign o_rd_ptr = rd_ptr;


    // Synchronous process: Increment tail
    always @(posedge rd_clk) begin
        if (rd_rst == 1'b1) begin
            int_tail_ptr <= {(INT_FIFO_PTR_BITS_CNT){1'b0}};
        end else begin
            if (i_dready == 1'b1 && valid_flag == 1'b1) begin
                int_tail_ptr <= rd_ptr;
            end
        end
    end

endmodule