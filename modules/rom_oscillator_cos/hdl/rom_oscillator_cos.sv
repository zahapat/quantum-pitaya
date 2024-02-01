    `timescale 1 ns/100 ps

    module rom_oscillator_cos #(
            parameter INT_DATA_WIDTH = 20,          // Width of input data
            parameter REAL_IN_FREQ_MHZ = 125.0,
            parameter REAL_OUT_FREQ_MHZ = 25.0
        )(
            // Inputs
            input  logic clk,
            input  logic i_valid,

            // Outputs
            output logic o_valid,
            output logic signed [INT_DATA_WIDTH-1:0] o_cos
        );

        // Declare Constants
        localparam PI = 3.141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117067;
        localparam NUMBER_OF_SAMPLES = (1.0*REAL_IN_FREQ_MHZ) / REAL_OUT_FREQ_MHZ;
        localparam INT_NUMBER_OF_SAMPLES = $rtoi(NUMBER_OF_SAMPLES);
        localparam ANGLE_INCREMENTS = 360.0/NUMBER_OF_SAMPLES;

        // ROM Address Pointer
        logic [$clog2(INT_NUMBER_OF_SAMPLES)-1:0] pointer = 0;

        // ROM Memory
        // Function to calculate sine values
        typedef logic signed [INT_DATA_WIDTH-1:0] array_2d [INT_NUMBER_OF_SAMPLES-1:0];
        function array_2d generate_rom;

            array_2d rom_values;

            for (int i = 0; i < INT_NUMBER_OF_SAMPLES; i = i + 1) begin

                rom_values[i][INT_DATA_WIDTH-1:0] = INT_DATA_WIDTH'(
                    //         Degrees to radians                  To data width scale
                    $rtoi(($cos(i*ANGLE_INCREMENTS*PI/180.0) * (2.0**(INT_DATA_WIDTH)/2 - 1.0)))
                );

            end

            return rom_values;
        endfunction
        array_2d ROM_VALUES = generate_rom();
        logic signed [INT_DATA_WIDTH-1:0] rom_value = 0;


        assign o_cos = rom_value;
        always_ff @(posedge clk) begin
            o_valid <= i_valid;

            // Increment on data valid
            pointer <= pointer + 1;
            if (pointer == INT_NUMBER_OF_SAMPLES-1) begin
                pointer <= 0;
            end

            // Read a constant value using an array of multiplexers
            rom_value <= ROM_VALUES[pointer];
            // for (int i; i < INT_NUMBER_OF_SAMPLES; i = i + 1) begin
            //     if (pointer == i) begin
            //         rom_value <= ROM_VALUES[i];
            //     end
            // end
        end


    endmodule