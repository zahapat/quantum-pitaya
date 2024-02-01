

    module accumulator #(
        parameter RAM_WIDTH = 32,
        parameter RAM_DEPTH = 32,
        parameter ACCUMULATE_TIMES = 8
    )(

        input  logic clk,
        input  logic rst,

        // Write port
        input  logic i_wr_valid,
        input  logic [RAM_WIDTH-1:0] i_wr_data,

        // Read port
        output logic o_accum_valid,
        output logic [RAM_WIDTH-1:0] o_accum_data,

        // The number of elements in the FIFO
        output logic [$clog2(ACCUMULATE_TIMES):0] o_desired_items_accumulated

    );


    // Declare RAM
    typedef logic [RAM_WIDTH-1:0] array_2d [RAM_DEPTH-1:0];

    logic [RAM_WIDTH-1:0] ram [RAM_DEPTH-1:0];

    //  Read Valid
    logic rd_valid = 0;
    logic [RAM_WIDTH-1:0] read_data;
    (* use_dsp48 = "yes" *) logic [RAM_WIDTH-1:0] read_data_added;
    assign o_accum_data = read_data;

    // Pointers
    logic [$clog2(RAM_DEPTH):0] head = 0;
    logic [$clog2(RAM_DEPTH):0] tail = 0;

    logic [$clog2(RAM_DEPTH):0] head_next;
    assign head_next
        = (head == (2**RAM_DEPTH)-1) ? 0 : head + 1;

    logic [$clog2(RAM_DEPTH):0] tail_next;
    assign tail_next
        = (tail == (2**RAM_DEPTH)-1) ? 0 : tail + rd_valid;

    logic [$clog2(RAM_DEPTH):0] tail_incremented;
    assign tail_incremented
        = (tail == (2**RAM_DEPTH)-1) ? 0 : tail + 1;

    // Fill count
    logic [$clog2(ACCUMULATE_TIMES):0] desired_items_accumulated = 0;


    // Copy internal signals to output
    // assign o_rd_valid = ~empty_next & ~empty;

    assign o_desired_items_accumulated = desired_items_accumulated;

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

    // Update the tail pointer on together with wr valid
    always @(posedge clk) begin
        rd_valid <= i_wr_valid;
        if (rst == 1'b1) begin
            tail <= 0;

        end else begin
            // Do not write/increment head if memory full
            if (rd_valid == 1'b1) begin
                tail <= tail_next;
            end

        end
    end
    
    
    // Write to and read from the RAM
    assign read_data_added = read_data + i_wr_data;
    always @(posedge clk) begin
        ram[head[$clog2(RAM_DEPTH)-1:0]] <= read_data_added;
    end

    always @(posedge clk) begin
        read_data <= ram[tail[$clog2(RAM_DEPTH)-1:0]];
    end

    endmodule