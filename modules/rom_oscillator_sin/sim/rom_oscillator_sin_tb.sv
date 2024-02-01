    `timescale 1 ns / 1 ns  // time-unit = 1 ns, precision = 10 ps

    module rom_oscillator_sin_tb;

        // ------------------------------------------------
        // DUT Ports and Instance
        // ------------------------------------------------
        // Generics 
        localparam INT_DATA_WIDTH = 32;         // Width of input data
        localparam REAL_IN_FREQ_MHZ = 125.0;    // Resolution of the requested sin and cos angle
        localparam REAL_OUT_FREQ_MHZ = 25.0;

        // Inptus
        logic clk = 1'b1;
        logic i_valid;

        // Outputs
        logic o_valid;
        logic signed [INT_DATA_WIDTH-1:0] o_sin;

        // DUT Instance
        rom_oscillator_sin #(
            .INT_DATA_WIDTH(INT_DATA_WIDTH),
            .REAL_IN_FREQ_MHZ(REAL_IN_FREQ_MHZ),
            .REAL_OUT_FREQ_MHZ(REAL_OUT_FREQ_MHZ)
        ) inst_rom_oscillator_sin_dut (
            // Inputs
            .clk(clk),
            .i_valid(i_valid),

            // Outputs
            .o_valid(o_valid),
            .o_sin(o_sin)
        );

        // Clocks
        parameter clk_period_ns = 8; // * 1 ns on timescale
        initial forever begin #(clk_period_ns/2) clk = ~clk; end

        // Other Constants
        localparam PI = 3.141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117067;

        // ------------------------------------------------
        // Tasks
        // ------------------------------------------------
        integer i;
        real sin_hw;
        real sin_sw;
        real sin_diff;
        // task task_ ();
        // endtask


        // ------------------------------------------------
        // Stimulus
        // ------------------------------------------------
        initial begin
            i_valid = 1'b0;
            $display($time, " << Starting the Simulation");

            // Find Sine and Cosine of variable 'i'
            #100ns;
            for (i = 0; i <= 100; i = i + 1) begin
                i_valid = 1'b1;
                @(posedge clk);
            end
            i_valid = 1'b0;
            @(posedge clk);
            #100ns;
            

            $display($time, " << Simulation Finished");
            $finish; // End of Simulation
        end


    endmodule