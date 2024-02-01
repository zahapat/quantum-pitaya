`timescale 1 ns / 1 ns  // time-unit = 1 ns, precision = 10 ps

    module averager_tb;

        // ------------------------------------------------
        // DUT Ports and Instance
        // ------------------------------------------------
        // Generics 
        localparam INT_MAX_AVERAGE_BY = 40;   // Enter the number of how many data points are to be averaged
        localparam INT_IN_DATA_WIDTH = 14;
        localparam INT_DIVISOR_WIDTH = 42-INT_IN_DATA_WIDTH;

        // Ports
        logic clk = 0;
        logic rst;
        logic i_valid;
        logic signed [INT_IN_DATA_WIDTH-1:0] i_data;

        logic i_avg_cmd_valid;
        logic [$clog2(INT_MAX_AVERAGE_BY)-1:0] i_avg_cmd_data;

        logic o_valid_integrated;
        logic o_valid_averaged;
        logic signed [INT_IN_DATA_WIDTH + $clog2(INT_MAX_AVERAGE_BY)-1:0] o_data_integrated;
        logic signed [INT_IN_DATA_WIDTH-1:0] o_data_averaged_guotient;
        logic signed [INT_DIVISOR_WIDTH-1:0] o_data_averaged_remainder;

        // DUT Instance
        averager #(
            .INT_MAX_AVERAGE_BY(INT_MAX_AVERAGE_BY),
            .INT_IN_DATA_WIDTH(INT_IN_DATA_WIDTH),
            .INT_DIVISOR_WIDTH(INT_DIVISOR_WIDTH)
        ) inst_averager_dut (
            .clk(clk),
            .rst(rst),
            .i_valid(i_valid),
            .i_data(i_data),

            .i_avg_cmd_valid(i_avg_cmd_valid),
            .i_avg_cmd_data(i_avg_cmd_data),

            .o_valid_integrated(o_valid_integrated),
            .o_valid_averaged(o_valid_averaged),
            .o_data_integrated(o_data_integrated),
            .o_data_averaged_guotient(o_data_averaged_guotient),
            .o_data_averaged_remainder(o_data_averaged_remainder)
        );

        // Clocks
        parameter clk_period_ns = 8.0; // * 1 ns on timescale
        initial forever begin #(clk_period_ns/2.0) clk = ~clk; end

        // ------------------------------------------------
        // Tasks
        // ------------------------------------------------
        integer i;
        // task task_ ();
        // endtask


        // ------------------------------------------------
        // Stimulus
        // ------------------------------------------------
        initial begin
            i_avg_cmd_valid = 0;
            i_avg_cmd_data = 0;
            i_valid = 0;
            $display($time, " << Starting the Simulation");

            #100ns;
            @(posedge clk);

            for (int u = 0; u < INT_MAX_AVERAGE_BY; u = u + 1) begin
                i_avg_cmd_valid = 1'b1;
                i_avg_cmd_data = u;
                @(posedge clk);
                i_avg_cmd_valid = 0;
                i_avg_cmd_data = 0;

                #100ns;
                for (i = 0; i < INT_MAX_AVERAGE_BY; i = i + 1) begin
                    i_valid = 1'b1;
                    i_data = 100;
                    @(posedge clk);
                end
                i_valid = 1'b0;
                i_data = 0;
                @(posedge clk);
                #100ns;
                @(posedge clk);

                for (i = 0; i < INT_MAX_AVERAGE_BY; i = i + 1) begin
                    i_valid = 1'b1;
                    i_data = 50;
                    @(posedge clk);
                end
                i_valid = 1'b0;
                i_data = 0;
                @(posedge clk);
                #100ns;
                @(posedge clk);

                for (i = 0; i < INT_MAX_AVERAGE_BY; i = i + 1) begin
                    i_valid = 1'b1;
                    i_data = (2**(INT_IN_DATA_WIDTH-1)-1); // max value for a signed data port
                    @(posedge clk);
                end
                i_valid = 1'b0;
                i_data = 0;
                @(posedge clk);
                #100ns;
                @(posedge clk);

                for (i = 0; i < 3*INT_MAX_AVERAGE_BY; i = i + 1) begin
                    if (i % 3 == 0) begin
                        i_valid = 1'b1;
                        i_data = 100;
                    end else begin
                        i_valid = 1'b0;
                        i_data = 0;
                    end
                    @(posedge clk);
                end
                i_valid = 1'b0;
                i_data = 0;
                @(posedge clk);
                #100ns;
                @(posedge clk);

                for (i = 0; i < INT_MAX_AVERAGE_BY; i = i + 1) begin
                    i_valid = 1'b1;
                    i_data = -100;
                    @(posedge clk);
                end
                i_valid = 1'b0;
                i_data = 0;
                @(posedge clk);
                #100ns;
                @(posedge clk);

            end



            $display($time, " << Simulation Finished");
            $finish; // End of Simulation
        end


    endmodule