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

    module cordic_sin_cos_iter #(
            parameter INT_DATA_WIDTH = 10,       // Width of input data
            parameter INT_ANGLE_WIDTH = 32,      // Resolution of the requested sin and cos angle
            parameter INT_ITERATION_NUM = 0
        )(
            // Inputs
            input  logic clk,
            input  logic i_valid,
            input  logic signed [INT_DATA_WIDTH:0] i_x_pres,
            input  logic signed [INT_DATA_WIDTH:0] i_y_pres,
            input  logic signed [INT_ANGLE_WIDTH-1:0] i_z_pres,

            // Outputs
            output logic o_valid,
            output logic signed [INT_DATA_WIDTH:0] o_x_next,
            output logic signed [INT_DATA_WIDTH:0] o_y_next,
            output logic signed [INT_ANGLE_WIDTH-1:0] o_z_next
        );

        // Declare Constants
        // Calculate the Arcus Tangens value in degrees
        localparam PI = 3.141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117067;
        localparam ARCTAN_TWO_POWEROF_NEGITER_DEG = $atan(2.0**(-INT_ITERATION_NUM)) * (180.0/PI);

        // Declare signals
        // Convert the value to the correct scale (e.g. 32b'111...111 = 360, 32b'000...000 = 0)
        wire signed [INT_ANGLE_WIDTH-1:0] arctan_anglewidth_scaled = INT_ANGLE_WIDTH'(unsigned'((ARCTAN_TWO_POWEROF_NEGITER_DEG/360.0) * (2.0**(INT_ANGLE_WIDTH)-1.0)));
        // Perform X[i] * 2^(-i) 
        //     and Y[i] * 2^(-i)
        wire signed[INT_DATA_WIDTH:0] x_right_factor = (i_y_pres >>> INT_ITERATION_NUM);
        wire signed[INT_DATA_WIDTH:0] y_right_factor = (i_x_pres >>> INT_ITERATION_NUM);

        always @(posedge clk) begin
            // The output data and target rotation will propagate to the next clock cycle
            o_valid <= i_valid;

            // Compare current rotation so far with the target rotation
            o_x_next <= i_x_pres + x_right_factor;
            o_y_next <= i_y_pres - y_right_factor;
            o_z_next <= i_z_pres + arctan_anglewidth_scaled;
            if (i_z_pres[INT_ANGLE_WIDTH-1] == 1'b0) begin
                o_x_next <= i_x_pres - x_right_factor;
                o_y_next <= i_y_pres + y_right_factor;
                o_z_next <= i_z_pres - arctan_anglewidth_scaled;
            end
        end


    endmodule