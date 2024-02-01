    `timescale 1 ns/100 ps

    module cordic_sin_cos #(
            parameter INT_DATA_WIDTH = 20,  // Width of input data
            parameter INT_ANGLE_WIDTH = 32, // Resolution of the rotation angle
            parameter ITERATIONS_CNT = 20   // How many iterations is to be performed
        )(
            // Inputs
            input  logic clk,
            input  logic i_valid,
            input  logic signed [INT_ANGLE_WIDTH-1:0] i_target_angle,

            // Outputs
            output logic o_valid,
            output logic signed [INT_DATA_WIDTH:0] o_cos,
            output logic signed [INT_DATA_WIDTH:0] o_sin,
            output logic signed [INT_ANGLE_WIDTH-1:0] o_z_next
        );

        // Declare Constants
        // localparam ITERATIONS_CNT = 20; 
        localparam INT_DATA_WIDTH_PLUSONE = INT_DATA_WIDTH + 1;
        localparam PI = 3.141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117067;
        localparam SYSTEM_GAIN = 0.6072;


        // Declare Wires
        logic[ITERATIONS_CNT:0] valid_pres_to_next;
        logic[INT_DATA_WIDTH:0] x_pres_to_next [ITERATIONS_CNT:0];
        logic[INT_DATA_WIDTH:0] y_pres_to_next [ITERATIONS_CNT:0];
        logic[INT_ANGLE_WIDTH-1:0] z_pres_to_next [ITERATIONS_CNT:0];


        // The algorithm is only able to produce waveforms of sine and cosine for quadrants I and IV.
        // To complete cos (sin) period, create initial conditions to switch between sine and cosine
        // quadrants
        always @(posedge clk)
        begin

            // Assign initial values to the first stage
            valid_pres_to_next[0] <= i_valid;

            // Initial values for the iteration process. Quadrants are encoded in two MSBs
            case (i_target_angle[INT_ANGLE_WIDTH-1:INT_ANGLE_WIDTH-2])
                // Quadrants I and IV are OK, no rotation needed
                2'b00, 2'b11: begin
                    x_pres_to_next[0] <= signed'(INT_DATA_WIDTH'((1.0*SYSTEM_GAIN/(0.5*PI)) * (2.0**(INT_DATA_WIDTH)-1.0)));
                    y_pres_to_next[0] <= signed'(INT_DATA_WIDTH'((0.0*SYSTEM_GAIN/(0.5*PI)) * (2.0**(INT_DATA_WIDTH)-1.0)));
                    z_pres_to_next[0] <= i_target_angle;
                end

                // Create initial conditions that will create cosine instead of sine and by adding rotation by pi/2 and vice versa
                2'b10: begin
                    x_pres_to_next[0] <= signed'(INT_DATA_WIDTH'((0.0*SYSTEM_GAIN/(0.5*PI)) * (2.0**(INT_DATA_WIDTH)-1.0)));
                    y_pres_to_next[0] <= signed'(INT_DATA_WIDTH'((-1.0*SYSTEM_GAIN/(0.5*PI)) * (2.0**(INT_DATA_WIDTH)-1.0)));
                    z_pres_to_next[0] <= signed'({2'b11, i_target_angle[INT_ANGLE_WIDTH-3:0]});
                end

                // Convert sine to cosine and vice versa for quadrant II by subtraacting pi/2
                2'b01: begin
                    x_pres_to_next[0] <= signed'(INT_DATA_WIDTH'((0.0*SYSTEM_GAIN/(0.5*PI)) * (2.0**(INT_DATA_WIDTH)-1.0)));
                    y_pres_to_next[0] <= signed'(INT_DATA_WIDTH'((1.0*SYSTEM_GAIN/(0.5*PI)) * (2.0**(INT_DATA_WIDTH)-1.0)));
                    z_pres_to_next[0] <= signed'({2'b00, i_target_angle[INT_ANGLE_WIDTH-3:0]});
                end

            endcase
        end


        // Send to output
        assign o_valid = valid_pres_to_next[ITERATIONS_CNT];
        assign o_cos = x_pres_to_next[ITERATIONS_CNT][INT_DATA_WIDTH:0];
        assign o_sin = y_pres_to_next[ITERATIONS_CNT][INT_DATA_WIDTH:0];
        assign o_z_next = z_pres_to_next[ITERATIONS_CNT][INT_ANGLE_WIDTH-1:0];

        // Instances of the CORDIC Iteration Stages
        generate
            for (genvar i = 0; i < ITERATIONS_CNT; i = i + 1) begin
                cordic_sin_cos_iter #(
                    .INT_DATA_WIDTH(INT_DATA_WIDTH),
                    .INT_ANGLE_WIDTH(INT_ANGLE_WIDTH),
                    .INT_ITERATION_NUM(i)
                ) inst_cordic_sin_cos_iter (
                    // Inputs
                    .clk(clk),
                    .i_valid(valid_pres_to_next[i]),
                    .i_x_pres(x_pres_to_next[i][INT_DATA_WIDTH:0]), // Represent 1-bit value as a INT_DATA_WIDTH-bit vector
                    .i_y_pres(y_pres_to_next[i][INT_DATA_WIDTH:0]),
                    .i_z_pres(z_pres_to_next[i][INT_ANGLE_WIDTH-1:0]),

                    // Outputs
                    .o_valid(valid_pres_to_next[i+1]),
                    .o_x_next(x_pres_to_next[i+1][INT_DATA_WIDTH:0]),
                    .o_y_next(y_pres_to_next[i+1][INT_DATA_WIDTH:0]),
                    .o_z_next(z_pres_to_next[i+1][INT_ANGLE_WIDTH-1:0])
                );
            end
        endgenerate

    endmodule