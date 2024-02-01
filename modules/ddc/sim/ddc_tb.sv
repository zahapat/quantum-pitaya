    `timescale 1 ns / 1 ns  // time-unit = 1 ns, precision = 10 ps

    module ddc_tb;

        // ------------------------------------------------
        // DUT Ports and Instance
        // ------------------------------------------------
        // Generics 
        localparam INT_NUMBER_OF_TAPS = 5;
        localparam INT_IN_DATA_WIDTH = 24;
        localparam INT_DOWNSAMPLING = 10;
        localparam INT_COEF_WIDTH = 16;
        localparam INT_OUT_DATA_WIDTH = 24;
        localparam REAL_LOCOSC_IN_FREQ_MHZ = 125.0;
        localparam REAL_LOCOSC_OUT_FREQ_MHZ = 25.0;

        // Ports
        logic clk = 0;
        logic rst;
        logic i_valid;
        logic signed [INT_IN_DATA_WIDTH-1:0] i_data;
        logic o_valid;
        logic signed [INT_OUT_DATA_WIDTH-1:0] o_data_i;
        logic signed [INT_OUT_DATA_WIDTH-1:0] o_data_q;


        // Ports to configure DOWNSAMPLING
        logic i_deci_cmd_valid = 0;
        logic [$clog2(INT_DOWNSAMPLING)-1:0] i_deci_cmd_data = 0;

        // Ports to configure FIR
        logic i_fir_cmd_valid;
        logic [$clog2(INT_NUMBER_OF_TAPS)-1:0] i_fir_cmd_coeffsel;
        logic signed [INT_COEF_WIDTH-1:0] i_fir_cmd_data;

        // DUT Instance
        ddc #(
            .INT_NUMBER_OF_TAPS(INT_NUMBER_OF_TAPS),
            .INT_IN_DATA_WIDTH(INT_IN_DATA_WIDTH),
            .INT_DOWNSAMPLING(INT_DOWNSAMPLING),
            .INT_COEF_WIDTH(INT_COEF_WIDTH),
            .INT_OUT_DATA_WIDTH(INT_OUT_DATA_WIDTH),
            .REAL_LOCOSC_IN_FREQ_MHZ(REAL_LOCOSC_IN_FREQ_MHZ),
            .REAL_LOCOSC_OUT_FREQ_MHZ(REAL_LOCOSC_OUT_FREQ_MHZ)
        ) inst_ddc_dut (
            .clk(clk),
            .rst(rst),
            .i_valid(i_valid),
            .i_data(i_data),

            // Ports to configure DOWNSAMPLING
            .i_deci_cmd_valid(i_deci_cmd_valid),
            .i_deci_cmd_data(i_deci_cmd_data),

            .i_fir_cmd_valid(i_fir_cmd_valid),
            .i_fir_cmd_coeffsel(i_fir_cmd_coeffsel),
            .i_fir_cmd_data(i_fir_cmd_data),

            .o_valid(o_valid),
            .o_data_i(o_data_i),
            .o_data_q(o_data_q)
        );

        // Clocks
        parameter clk_period_ns = 8; // * 1 ns on timescale
        initial forever begin #(clk_period_ns/2) clk = ~clk; end

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
            i_valid = 1'b0;
            i_data = 0;
            $display($time, " << Starting the Simulation");

            // Find Sine and Cosine of variable 'i'
            #100ns;
            for (i = 0; i <= 100; i = i + 1) begin
                i_valid = 1'b1;
                i_data = INT_IN_DATA_WIDTH'(1);
                @(posedge clk);
            end
            i_valid = 1'b0;
            i_data = 0;
            @(posedge clk);
            #100ns;


            #1000ns;
            $display($time, " << Updating Decimation Value");
            i_deci_cmd_valid = 1'b1;
            i_deci_cmd_data = 5-1; // i_deci_cmd_data = 4 means Decimation = 5, thus, one needs to decrement the value by 1
                                   // i_deci_cmd_data = 0 means Decimation = 1, which means no decimation
            @(posedge clk);
            i_deci_cmd_valid = 1'b0;
            i_deci_cmd_data = 0;

            // Find Sine and Cosine of variable 'i'
            #100ns;
            for (i = 0; i <= 100; i = i + 1) begin
                i_valid = 1'b1;
                i_data = INT_IN_DATA_WIDTH'(1);
                @(posedge clk);
            end
            i_valid = 1'b0;
            i_data = 0;
            @(posedge clk);
            #100ns;



            #1000ns;
            $display($time, " << Updating Decimation Value");
            i_deci_cmd_valid = 1'b1;
            i_deci_cmd_data = 1-1; // i_deci_cmd_data = 5 means Decimation = 6, thus, one needs to decrement the value by 1
            @(posedge clk);
            i_deci_cmd_valid = 1'b0;
            i_deci_cmd_data = 0;

            // Find Sine and Cosine of variable 'i'
            #100ns;
            for (i = 0; i <= 100; i = i + 1) begin
                i_valid = 1'b1;
                i_data = INT_IN_DATA_WIDTH'(1);
                @(posedge clk);
            end
            i_valid = 1'b0;
            i_data = 0;
            @(posedge clk);
            #100ns;


            $display($time, " << Simulation Finished");
            $finish; // End of Simulation
        end


    endmodule