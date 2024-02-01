

    module fifo_ring #(
            parameter RAM_WIDTH = 32,
            parameter RAM_DEPTH = 1024
        )(

            input  logic clk,
            input  logic rst,
    
            // Write port
            input  logic i_wr_valid,
            input  logic [RAM_WIDTH-1:0] i_wr_data,
    
            // Read port
            input  logic i_rd_en,
            output logic o_rd_valid,
            output logic [RAM_WIDTH-1:0] o_rd_data,
    
            // Flags
            output logic o_ready,
            output logic o_empty,
            output logic o_empty_next,
            output logic o_full,
            output logic o_full_next,
    
            // The number of elements in the FIFO
            output logic [$clog2(RAM_DEPTH):0] o_fill_count

        );


        // Declare RAM
        typedef logic [RAM_WIDTH-1:0] array_2d [RAM_DEPTH-1:0];
        function array_2d init_ram;
            array_2d rom_values;
            for (int i = 1; i <= RAM_DEPTH; i = i + 1) begin
                rom_values[i-1] = RAM_WIDTH'(0);
            end
            return rom_values;
        endfunction
        logic [RAM_WIDTH-1:0] ram [RAM_DEPTH-1:0] = init_ram();

        // Pointers
        logic [$clog2(RAM_DEPTH):0] head = 0;
        logic [$clog2(RAM_DEPTH):0] tail = 0;

        // Increment pointers + wrap
        logic [$clog2(RAM_DEPTH):0] head_next;
        assign head_next
            = (head == (2**RAM_DEPTH)-1) ? 0 : head + 1;

        logic [$clog2(RAM_DEPTH):0] tail_next;
        assign tail_next
            = (tail == (2**RAM_DEPTH)-1) ? 0 : tail + i_rd_en;

        logic [$clog2(RAM_DEPTH):0] tail_incremented;
        assign tail_incremented
            = (tail == (2**RAM_DEPTH)-1) ? 0 : tail + 1;

        // Fill count
        logic [$clog2(RAM_DEPTH):0] fill_count = 0;

        // Flags
        logic empty;
        assign empty
            = ((head[$clog2(RAM_DEPTH):0] == tail[$clog2(RAM_DEPTH):0])) ? 1'b1 : 1'b0;

        logic empty_next;
        assign empty_next
            = ((head[$clog2(RAM_DEPTH):0] == tail_incremented[$clog2(RAM_DEPTH):0])) ? 1'b1 : 1'b0;

        logic full;
        assign full
            = (((head[$clog2(RAM_DEPTH)] != tail[$clog2(RAM_DEPTH)])) 
                & (head[$clog2(RAM_DEPTH)-1:0] == tail[$clog2(RAM_DEPTH)-1:0])) ? 1'b1 : 1'b0;

        logic full_next;
        assign full_next
            = (((head_next[$clog2(RAM_DEPTH)] != tail[$clog2(RAM_DEPTH)])) 
                & (head_next[$clog2(RAM_DEPTH)-1:0] >= tail[$clog2(RAM_DEPTH)-1:0])) ? 1'b1 : 1'b0;


        // Copy internal signals to output
        // assign o_rd_valid = ~empty_next & ~empty;
        assign o_rd_valid = ~empty;
        assign o_ready = ~full;
        assign o_empty = empty;
        assign o_empty_next = empty_next;
        assign o_full = full;
        assign o_full_next = full_next;

        assign o_fill_count = fill_count;

        // Update the head pointer in write
        always @(posedge clk) begin
            if (rst == 1'b1) begin
                head <= 0;

            end else begin
                // Do not write/increment head if memory full
                if (i_wr_valid == 1'b1) begin
                    head <= head_next;
                end

            end
        end

        // Update the tail pointer on read and pulse valid
        always @(posedge clk) begin
            if (rst == 1'b1) begin
                tail <= 0;

            end else begin
                // Do not read/increment tail if memory empty
                tail <= tail_next;
            end
        end

        // Fill count counter
        always @(posedge clk) begin
            if (rst == 1'b1) begin
                fill_count <= 0;
            end else begin
                case ({i_wr_valid, i_rd_en})
                    2'b10 : begin
                        fill_count <= fill_count + 1;
                    end
                    2'b01 : fill_count <= fill_count - 1;
                    default : fill_count <= fill_count;
                endcase
            end
        end


        // Write to and read from the RAM
        always @(posedge clk) begin
            if (i_wr_valid == 1'b1) begin
                ram[head[$clog2(RAM_DEPTH)-1:0]] <= i_wr_data;
            end
            o_rd_data <= ram[tail_next[$clog2(RAM_DEPTH)-1:0]];
        end
   
    endmodule