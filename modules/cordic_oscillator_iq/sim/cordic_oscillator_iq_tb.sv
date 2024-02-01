    `timescale 1 ns / 1 ns  // time-unit = 1 ns, precision = 10 ps

    module cordic_oscillator_iq_tb;

        // ------------------------------------------------
        // DUT Ports and Instance
        // ------------------------------------------------
        // Generics 
        localparam INT_DATA_WIDTH = 15;     // Width of input data
        localparam INT_ANGLE_WIDTH = 30;    // Resolution of the requested sin and cos angle
        localparam INT_ITERATIONS_CNT = 16;      // How many iterations is to be performed
        localparam REAL_IN_FREQ_MHZ = 125.0;
        localparam REAL_OUT_FREQ_MHZ = 25.0;
        localparam INT_WAVE_RESOLUTION_BITS = INT_ANGLE_WIDTH;

        // Inptus
        logic clk = 1'b1;
        logic i_valid;

        // Outputs
        logic o_valid;
        logic signed [INT_DATA_WIDTH:0] o_cos;
        logic signed [INT_DATA_WIDTH:0] o_sin;

        // DUT Instance
        cordic_oscillator_iq #(
            .INT_DATA_WIDTH(INT_DATA_WIDTH),
            .INT_ANGLE_WIDTH(INT_ANGLE_WIDTH),
            .INT_ITERATIONS_CNT(INT_ITERATIONS_CNT),
            .INT_WAVE_RESOLUTION_BITS(INT_WAVE_RESOLUTION_BITS),
            .REAL_IN_FREQ_MHZ(REAL_IN_FREQ_MHZ),
            .REAL_OUT_FREQ_MHZ(REAL_OUT_FREQ_MHZ)
        ) inst_cordic_oscillator_iq_dut (
            // Inputs
            .clk(clk),
            .i_valid(i_valid),

            // Outputs
            .o_valid(o_valid),
            .o_cos(o_cos),
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
        real cos_hw, sin_hw;
        real cos_sw, sin_sw;
        real cos_diff, sin_diff;
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