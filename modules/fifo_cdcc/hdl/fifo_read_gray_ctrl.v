`timescale 1 ns / 1 ns

module fifo_read_gray_ctrl
    #(
        parameter INT_FIFO_PTR_BITS_CNT = 9
    )(
        // Write Signals
        input  wire rd_clk,
        input  wire rd_rst,
        output wire rd_en,

        // AXI Input Port
        input  wire i_dready,
        output wire o_valid,    // This module ready flag

        // Pointers on the WR side
        input wire[INT_FIFO_PTR_BITS_CNT:0] i_wr_grayptr,
        output wire[INT_FIFO_PTR_BITS_CNT-1:0] o_rd_intptr,
        output wire[INT_FIFO_PTR_BITS_CNT:0] o_rd_grayptr
    );

    // Declare signals & initial conditions
    reg[INT_FIFO_PTR_BITS_CNT:0] reg_tail_ptr = 0;
    reg[INT_FIFO_PTR_BITS_CNT:0] reg_tail_grayptr = 0;

    // Int and Gray Pointers
    wire[INT_FIFO_PTR_BITS_CNT:0] reg_tail_grayptr_next;
    wire[INT_FIFO_PTR_BITS_CNT:0] reg_tail_ptr_next;

    // Asynchonous valid control: Valid is asserted if BRAM is not empty
    // If pointers are equal (MSB did not overflow), fifo is empty, read is forbidden
    reg reg_valid_flag = 1'b0;
    wire valid_flag = (i_wr_grayptr == reg_tail_grayptr_next) ? 1'b0 : 1'b1;


    // assign o_valid = valid_flag;
    assign o_valid = reg_valid_flag;

    // assign rd_en = valid_flag;
    assign rd_en = 1'b1;
    // assign rd_en = (valid_flag == 1'b1 && i_dready == 1'b1);

    assign reg_tail_ptr_next
        // = (i_dready == 1'b1) ? reg_tail_ptr + 1 : reg_tail_ptr;
        = (reg_valid_flag == 1'b1 && i_dready == 1'b1) ? reg_tail_ptr + 1 : reg_tail_ptr;
        // = (reg_valid_flag == 1'b1) ? reg_tail_ptr + i_dready : reg_tail_ptr;
        // = (reg_valid_flag == 1'b1) ? reg_tail_ptr + 1 : reg_tail_ptr;

    assign reg_tail_grayptr_next
        = reg_tail_ptr_next ^ (reg_tail_ptr_next >> 1);
        // = reg_tail_ptr ^ (reg_tail_ptr >> 1);

    // Synchronous process: Increment tail
    assign o_rd_intptr = reg_tail_ptr_next[INT_FIFO_PTR_BITS_CNT-1:0];
    // assign o_rd_intptr = reg_tail_ptr[INT_FIFO_PTR_BITS_CNT-1:0];
    assign o_rd_grayptr = reg_tail_grayptr;
    always @(posedge rd_clk) begin
        if (rd_rst == 1'b1) begin
            reg_tail_ptr <= 0;
            reg_valid_flag <= 0;
        end else begin
            reg_valid_flag <= valid_flag;
            // reg_tail_ptr <= reg_tail_ptr_next;
            // if (i_dready == 1'b1) begin
            // if (i_dready == 1'b1) begin
            // if (i_dready == 1'b1) begin
            reg_tail_ptr <= reg_tail_ptr_next;
            // if (reg_valid_flag == 1'b1 && i_dready == 1'b1) begin
                // reg_tail_ptr <= reg_tail_ptr + 1;
            // end
            // reg_tail_ptr <= reg_tail_ptr_next;
            // if (i_dready == 1'b1) begin
                // reg_tail_ptr <= reg_tail_ptr_next;
            // end
            // if (i_dready == 1'b1) begin
            //     reg_tail_ptr <= reg_tail_ptr_next;
            // end
        end

        // Bypass reset, pass an int pointer out
        // Will get reset value the next clk after reg_tail_ptr cycle
        reg_tail_grayptr <= reg_tail_grayptr_next;
    end


    // ORIGINAL:
    // assign o_valid = valid_flag;
    // // assign rd_en = valid_flag;
    // assign rd_en = 1'b1;

    // assign reg_tail_ptr_next
    //     = (i_dready == 1'b1) ? reg_tail_ptr + 1 : reg_tail_ptr;

    // assign reg_tail_grayptr_next
    //     = reg_tail_ptr_next ^ (reg_tail_ptr_next >> 1);

    // // Synchronous process: Increment tail
    // assign o_rd_intptr = reg_tail_ptr_next[INT_FIFO_PTR_BITS_CNT-1:0];
    // assign o_rd_grayptr = reg_tail_grayptr;
    // always @(posedge rd_clk) begin
    //     if (rd_rst == 1'b1) begin
    //         reg_tail_ptr <= {(INT_FIFO_PTR_BITS_CNT){1'b0}};
    //         reg_valid_flag <= 1'b0;
    //     end else begin
    //         reg_valid_flag <= valid_flag;
    //         reg_tail_ptr <= reg_tail_ptr_next;
    //     end

    //     // Bypass reset, pass an int pointer out
    //     // Will get reset value the next clk after reg_tail_ptr cycle
    //     reg_tail_grayptr <= reg_tail_grayptr_next;
    // end


endmodule