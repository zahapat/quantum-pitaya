`timescale 1 ns / 1 ns

module fifo_write_gray_ctrl
    #(
        parameter INT_FIFO_PTR_BITS_CNT = 32
    )(
        // Write Signals
        input  wire wr_clk,
        input  wire wr_rst,
        output wire write_en,

        // AXI Input Port
        input  wire i_valid,
        output wire o_ready,    // This module ready flag

        // Pointers on the WR side
        output wire[INT_FIFO_PTR_BITS_CNT-1:0] o_wr_intptr,
        output wire[INT_FIFO_PTR_BITS_CNT:0] o_wr_grayptr,
        input wire[INT_FIFO_PTR_BITS_CNT:0] i_rd_grayptr  // 2-FF synchronized Gray pointer from the read clock domain
    );


    // Declare signals & initial conditions
    // reg[INT_FIFO_PTR_BITS_CNT:0] reg_head_ptr = {INT_FIFO_PTR_BITS_CNT+1{1'b0}};
    reg[INT_FIFO_PTR_BITS_CNT:0] reg_head_ptr = 0;
    // reg[INT_FIFO_PTR_BITS_CNT:0] reg_head_grayptr = {INT_FIFO_PTR_BITS_CNT+1{1'b0}};
    reg[INT_FIFO_PTR_BITS_CNT:0] reg_head_grayptr = 0;
    
    // Int and Gray Pointers
    wire[INT_FIFO_PTR_BITS_CNT:0] reg_head_grayptr_next;
    wire[INT_FIFO_PTR_BITS_CNT:0] reg_head_ptr_next;
    
    // Asynchonous ready control: Ready is asserted if BRAM is not full
    // Fifo is full when 2 MSBs are different (MSB has overflown) and the remaining bits match
    wire ready_flag = ~((reg_head_grayptr_next[INT_FIFO_PTR_BITS_CNT] != i_rd_grayptr[INT_FIFO_PTR_BITS_CNT]) &&
        (reg_head_grayptr_next[INT_FIFO_PTR_BITS_CNT-1] != i_rd_grayptr[INT_FIFO_PTR_BITS_CNT-1]) &&
        (reg_head_grayptr_next[INT_FIFO_PTR_BITS_CNT-2:0] == i_rd_grayptr[INT_FIFO_PTR_BITS_CNT-2:0]));
    assign o_ready = ready_flag;

    assign write_en = ((ready_flag == 1'b1) && (i_valid == 1'b1)) ? 1'b1 : 1'b0;

    assign reg_head_ptr_next 
        = (ready_flag == 1'b1 && i_valid == 1'b1) ? reg_head_ptr + 1 : reg_head_ptr;
        // = (i_valid == 1'b1) ? reg_head_ptr + 1 : reg_head_ptr;
        // = (ready_flag == 1'b1) ? reg_head_ptr + 1 : reg_head_ptr;

    assign reg_head_grayptr_next 
        = reg_head_ptr ^ (reg_head_ptr >> 1);


    // Synchronous process: Increment head
    assign o_wr_intptr = reg_head_ptr[INT_FIFO_PTR_BITS_CNT-1:0];
    assign o_wr_grayptr = reg_head_grayptr;
    always @(posedge wr_clk) begin
        if (wr_rst == 1'b1) begin
            reg_head_ptr <= {(INT_FIFO_PTR_BITS_CNT+1){1'b0}};
        end else begin
            // Pass incremented values on data valid
            // if (ready_flag == 1'b1 && i_valid == 1'b1) begin
            if (i_valid == 1'b1) begin
                reg_head_ptr <= reg_head_ptr_next;
            end
        end

        // Bypass reset for better placement freedom, 
        // pass an int pointer out; Will get reset value the next clk cycle
        reg_head_grayptr <= reg_head_grayptr_next;
    end

endmodule