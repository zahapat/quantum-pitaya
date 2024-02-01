    // The equations that need to be performed are:
    // Note: Signs change based on whether current rocation (accumulated) 
    //       is smaller(+)/larger(-) than the target rotation, thus define
    //       which can be also determined by the sign of the last "i_z_pres"
    // 1) X[i+1] = X[i] -/+ (2^(-i) * Y[i]); 
    // 2) Y[i+1] = Y[i] +/- (2^(-i) * X[i]);
    // 3) Z[i+1] = Z[i] -/+ arctan(2^(-1));
    // Note #2: The inverse required in the right hand side factors in the equations 
    //          above can be performed by right operation (signed)

    `timescale 1 ns/100 ps

    module cordic_oscillator_iq #(
            parameter INT_DATA_WIDTH = 20,       // Width of input data
            parameter INT_ANGLE_WIDTH = 32,      // Resolution of the requested sin and cos angle
            parameter INT_ITERATIONS_CNT = 30,     // How many iterations is to be performed
            parameter INT_WAVE_RESOLUTION_BITS = 13, // Speed up the counter by counting in higher bits
            parameter REAL_IN_FREQ_MHZ = 125,
            parameter REAL_OUT_FREQ_MHZ = 25
        )(
            // Inputs
            input  logic clk,
            input  logic i_valid,

            // Outputs
            output logic o_valid,
            output logic signed [INT_DATA_WIDTH:0] o_cos,
            output logic signed [INT_DATA_WIDTH:0] o_sin
        );

        // Declare Constants
        // Calculate the Arcus Tangens value in degrees
        localparam PI = 3.141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117067;
        localparam NUMBER_OF_SAMPLES = (1.0*REAL_IN_FREQ_MHZ) / REAL_OUT_FREQ_MHZ;
        localparam ANGLE_INCREMENTS = 360.0/NUMBER_OF_SAMPLES;
        localparam INCREMENT_COUNTER_BY = signed'(INT_WAVE_RESOLUTION_BITS'($rtoi(((1.0*ANGLE_INCREMENTS)/360.0) * (2.0**(INT_ANGLE_WIDTH)-1))));


        // Declare signals
        logic signed [INT_ANGLE_WIDTH-1:0] target_angle = 0;
        logic valid;

        // Pass angles to the CORDIC processor
        generate
            // Compare current rotation so far with the target rotation
            if (INT_WAVE_RESOLUTION_BITS < INT_ANGLE_WIDTH) begin
                always @(posedge clk) begin
                    // The output data and target rotation will propagate to the next clock cycle
                    valid <= i_valid;
                    if (i_valid == 1'b1) begin      
                        // Compare current rotation so far with the target rotation
                        target_angle = {target_angle[INT_ANGLE_WIDTH-1:INT_ANGLE_WIDTH-INT_WAVE_RESOLUTION_BITS] + INCREMENT_COUNTER_BY, target_angle[INT_ANGLE_WIDTH-INT_WAVE_RESOLUTION_BITS-1:0]};
                    end
                end
            end else begin
                always @(posedge clk) begin
                    // The output data and target rotation will propagate to the next clock cycle
                    valid <= i_valid;
                    if (i_valid == 1'b1) begin
                        // Compare current rotation so far with the target rotation
                        target_angle = target_angle + INCREMENT_COUNTER_BY;
                    end
                end
            end
        endgenerate


        // Instantiate the CORDIC processor
        cordic_sin_cos #(
            .INT_DATA_WIDTH(INT_DATA_WIDTH),  // Width of input data
            .INT_ANGLE_WIDTH(INT_ANGLE_WIDTH), // Resolution of the rotation angle
            .ITERATIONS_CNT(INT_ITERATIONS_CNT)   // How many iterations is to be performed
        ) inst_cordic_sin_cos (
            // Inputs
            .clk(clk),
            .i_valid(valid),
            .i_target_angle(target_angle),

            // Outputs
            .o_valid(o_valid),
            .o_cos(o_cos),
            .o_sin(o_sin),
            .o_z_next() // not needed
        );


    endmodule