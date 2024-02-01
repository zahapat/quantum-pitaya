    `timescale 1 ns / 1 ns  // time-unit = 1 ns, precision = 10 ps

    module cordic_sin_cos_tb;

        // ------------------------------------------------
        // DUT Ports and Instance
        // ------------------------------------------------
        // Generics 
        localparam INT_DATA_WIDTH = 20;     // Width of input data
        localparam INT_ANGLE_WIDTH = 32;    // Resolution of the requested sin and cos angle
        localparam ITERATIONS_CNT = 30;      // How many iterations is to be performed

        // Inptus
        logic clk = 1'b1;
        logic i_valid;
        logic signed[INT_ANGLE_WIDTH-1:0] i_target_angle;

        // Outputs
        logic o_valid;
        logic signed [INT_DATA_WIDTH:0] o_cos;
        logic signed [INT_DATA_WIDTH:0] o_sin;
        logic signed [INT_ANGLE_WIDTH-1:0] o_z_next;

        // DUT Instance
        cordic_sin_cos #(
            .INT_DATA_WIDTH(INT_DATA_WIDTH),
            .INT_ANGLE_WIDTH(INT_ANGLE_WIDTH),
            .ITERATIONS_CNT(ITERATIONS_CNT)
        ) inst_cordic_sin_cos_dut (
            // Inputs
            .clk(clk),
            .i_valid(i_valid),
            .i_target_angle(i_target_angle),

            // Outputs
            .o_valid(o_valid),
            .o_cos(o_cos),
            .o_sin(o_sin),
            .o_z_next(o_z_next)
        );

        // Clocks
        parameter clk_period_ns = 8; // * 1 ns on timescale
        initial forever begin #(clk_period_ns/2) clk = ~clk; end

        // Other Constants
        localparam PI = 3.141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117067;

        // ------------------------------------------------
        // Tasks
        // ------------------------------------------------
        real i;
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
            i_target_angle <= INT_ANGLE_WIDTH'(1'b0);
            $display($time, " << Starting the Simulation");

            // Find Sine and Cosine of variable 'i'
            #100ns;
            for (i = 0.0; i <= 360.0; i = i + 0.5) begin
                i_valid = 1'b1;
                i_target_angle <= signed'(INT_ANGLE_WIDTH'($rtoi(((1.0*i)/360.0) * (2.0**(INT_ANGLE_WIDTH)-1.0))));
                @(posedge clk);
                i_valid = 1'b0;
                @(posedge clk);
                @(posedge o_valid);
                #0; #0; #0; #0;

                $display($time, " >> angle = ", i, " degrees");

                // Cosine
                cos_hw = (o_cos)*((0.5*PI)/(2.0**(INT_DATA_WIDTH)-1.0));
                cos_sw = $cos(i*PI/180.0);
                cos_diff = cos_sw - cos_hw;
                // $display($time, " >> cosine = ", o_cos);
                $display($time, " >> cosine (hardware)  = ", cos_hw);
                $display($time, " >> cosine (software)  = ", cos_sw);
                $display($time, " >> cosine (dif:hw-sw) = ", cos_diff);

                // Sine
                sin_hw = (o_sin)*((0.5*PI)/(2.0**(INT_DATA_WIDTH)-1.0));
                sin_sw = $sin(i*PI/180.0);
                sin_diff = sin_sw - sin_hw;
                // $display($time, "     >> sine = ", o_sin);
                $display($time, "     >> sine (hardware)  = ", sin_hw);
                $display($time, "     >> sine (software)  = ", sin_sw);
                $display($time, "     >> sine (dif:hw-sw) = ", sin_diff);
                $display($time, "         >> z (convergence indicator) = ", o_z_next);
                // $display($time, "         >> z(converted) = ", (o_z_next)*(360.0/(2.0**(INT_ANGLE_WIDTH))));
                @(posedge clk);
            end
            

            $display($time, " << Simulation Finished");
            $finish; // End of Simulation
        end


    endmodule