    `timescale 1 ns / 1 ns  // time-unit = 1 ns, precision = 10 ps

    module fir_parallel_tb;

        // ------------------------------------------------
        // DUT Ports and Instance
        // ------------------------------------------------
        // Generics 
        localparam INT_NUMBER_OF_TAPS = 15;
        localparam INT_IN_DATA_WIDTH = 24;
        localparam INT_COEF_WIDTH = 15;
        localparam INT_OUT_DATA_WIDTH = 24;
        localparam INT_UPDATE_COEFFS_TRUE = 1;

        // The coefficients example:
        // parameter INT_NUMBER_OF_TAPS = 15;
        // parameter INT_COEF_WIDTH = 15;
        // logic signed[INT_COEF_WIDTH-1:0] fir_coefficients [INT_NUMBER_OF_TAPS-1:0] = '{
        //     INT_COEF_WIDTH'($rtoi((0.0021315395931926044) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        //     INT_COEF_WIDTH'($rtoi((0.006314944090010779) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        //     INT_COEF_WIDTH'($rtoi((-3.935575154681972**(-18)) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        //     INT_COEF_WIDTH'($rtoi((-0.033017674584738047) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        //     INT_COEF_WIDTH'($rtoi((-0.03993543702176473) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        //     INT_COEF_WIDTH'($rtoi((0.07710361101127595) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        //     INT_COEF_WIDTH'($rtoi((0.28803171716927617) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        //     INT_COEF_WIDTH'($rtoi((0.3987425994854944) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        //     INT_COEF_WIDTH'($rtoi((0.28803171716927617) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        //     INT_COEF_WIDTH'($rtoi((0.07710361101127595) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        //     INT_COEF_WIDTH'($rtoi((-0.03993543702176473) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        //     INT_COEF_WIDTH'($rtoi((-0.033017674584738047) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        //     INT_COEF_WIDTH'($rtoi((-3.935575154681972**(-18)) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        //     INT_COEF_WIDTH'($rtoi((0.006314944090010779) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        //     INT_COEF_WIDTH'($rtoi((0.0021315395931926044) * (2.0**(INT_COEF_WIDTH)/2 - 1.0)))
        // };

        // Inptus
        logic clk = 1'b1;
        logic i_valid;
        logic signed [INT_IN_DATA_WIDTH-1:0] i_data;

        logic i_cmd_valid;
        logic [$clog2(INT_NUMBER_OF_TAPS)-1:0] i_cmd;
        logic signed [INT_COEF_WIDTH-1:0] i_cmd_data;

        // Outputs
        logic o_valid;
        logic signed [INT_IN_DATA_WIDTH-1:0] o_data;

        // DUT Instance
        fir_parallel #( // Allows to use the DSP resources
            .INT_NUMBER_OF_TAPS(INT_NUMBER_OF_TAPS),
            .INT_IN_DATA_WIDTH(INT_IN_DATA_WIDTH),
            .INT_COEF_WIDTH(INT_COEF_WIDTH),
            .INT_OUT_DATA_WIDTH(INT_OUT_DATA_WIDTH),
            .INT_UPDATE_COEFFS_TRUE(INT_UPDATE_COEFFS_TRUE)
        ) inst_fir_parallel_dut (
            // Inputs
            .clk(clk),
            .i_valid(i_valid),
            .i_data(i_data),

            // Update Coeffitients
            .i_cmd_valid(i_cmd_valid),
            .i_cmd(i_cmd),
            .i_cmd_data(i_cmd_data),

            // Outputs
            .o_valid(o_valid),
            .o_data(o_data)
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
            i_valid = 0;
            i_data = 0;
            i_cmd_valid = 0;
            i_cmd = 0;
            i_cmd_data = 0;
            $display($time, " << Starting the Simulation");
            
            // This module has been tested within the DDC
            // Test updating the FIR coefficients
            #100ns;
            i_valid = 1'b1;
            i_cmd_valid = 1'b1;
            for (i = 0; i < INT_NUMBER_OF_TAPS; i = i + 1) begin
                i_cmd = i + 1;
                i_cmd_data = $random();
                @(posedge clk);
            end
            i_cmd_valid = 0;
            i_valid = 0;
            @(posedge clk);


            #100ns;
            for (i = 0; i < 100; i = i + 1) begin
                i_valid = 1'b1;
                @(posedge clk);
            end
            i_valid = 0;
            @(posedge clk);
            #100ns;


            $display($time, " << Simulation Finished");
            $finish; // End of Simulation
        end


    endmodule