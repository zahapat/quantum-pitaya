    `timescale 1 ns / 1 ns

    module ddc #(
            parameter INT_NUMBER_OF_TAPS = 5, // Max FIR Order + 1
            parameter INT_IN_DATA_WIDTH = 10,
            parameter INT_DOWNSAMPLING = 10,
            parameter INT_COEF_WIDTH = 10,
            parameter INT_OUT_DATA_WIDTH = 20,
            parameter REAL_LOCOSC_IN_FREQ_MHZ = 125.0,
            parameter REAL_LOCOSC_OUT_FREQ_MHZ = 25.0
        )(
            // Inputs
            input  logic clk,
            input  logic rst,
            input  logic i_valid,
            input  logic signed [INT_IN_DATA_WIDTH-1:0] i_data,

            // Ports to configure DOWNSAMPLING
            input  logic i_deci_cmd_valid,
            input  logic [$clog2(INT_DOWNSAMPLING)-1:0] i_deci_cmd_data, // i_deci_cmd_data = 5 means Decimation = 6, thus, one needs to decrement the value by 1

            // Ports to configure FIR
            input  logic i_fir_cmd_valid,
            input  logic [$clog2(INT_NUMBER_OF_TAPS)-1:0] i_fir_cmd_coeffsel,
            input  logic signed [INT_COEF_WIDTH-1:0] i_fir_cmd_data,

            // Outputs
            output logic o_valid,
            output logic signed [INT_OUT_DATA_WIDTH-1:0] o_data_i,
            output logic signed [INT_OUT_DATA_WIDTH-1:0] o_data_q
        );

        // Declare Constants
        localparam PI = 3.1415926535897932384626433832795;
        localparam NUMBER_OF_SAMPLES = (1.0*REAL_LOCOSC_IN_FREQ_MHZ) / REAL_LOCOSC_OUT_FREQ_MHZ;
        localparam INT_NUMBER_OF_SAMPLES = $rtoi(NUMBER_OF_SAMPLES);
        localparam ANGLE_INCREMENTS = 360.0/NUMBER_OF_SAMPLES;

        // Declare signals
        logic valid_downsampling;
        logic valid_downsampling_opipe;
        logic [$clog2(INT_DOWNSAMPLING)-1:0] counter_downsampling = 0;
        logic [$clog2(INT_DOWNSAMPLING)-1:0] counter_downsampling_maxvalue = INT_DOWNSAMPLING-1;
        logic [$clog2(INT_NUMBER_OF_SAMPLES)-1:0] sin_pointer = 0;
        logic [$clog2(INT_NUMBER_OF_SAMPLES)-1:0] cos_pointer = 0;
        (* USE_DSP = "YES" *) logic signed [2*INT_IN_DATA_WIDTH-1:0] sin_value_multiplied;
        (* USE_DSP = "YES" *) logic signed [2*INT_IN_DATA_WIDTH-1:0] cos_value_multiplied;
        logic signed [2*INT_IN_DATA_WIDTH-1:0] sin_value_multiplied_dsp_opipe;
        logic signed [2*INT_IN_DATA_WIDTH-1:0] cos_value_multiplied_dsp_opipe;
        logic signed [2*INT_IN_DATA_WIDTH-1:0] sin_value_multiplied_dsp_ipipe;
        logic signed [2*INT_IN_DATA_WIDTH-1:0] cos_value_multiplied_dsp_ipipe;
        logic o_valid_i;
        logic o_valid_q;
        logic increment_allowed = 1'b1;

        // Declare new types
        typedef logic signed [INT_IN_DATA_WIDTH-1:0] array_2d [INT_NUMBER_OF_SAMPLES-1:0];

        // Pre-calculate sine function ROM values
        function array_2d generate_rom_sin;
            array_2d rom_values;
            for (int i = 0; i < INT_NUMBER_OF_SAMPLES; i = i + 1) begin
                rom_values[i] = INT_IN_DATA_WIDTH'($rtoi(
                    //         Degrees to radians               To data width scale
                    $sin(i*ANGLE_INCREMENTS*PI/180.0) * (2.0**(INT_IN_DATA_WIDTH)/2 - 1.0))
                );
            end
            return rom_values;
        endfunction

        // Pre-calculate cosine function ROM values
        function array_2d generate_rom_cos;
            array_2d rom_values;
            for (int i = 0; i < INT_NUMBER_OF_SAMPLES; i = i + 1) begin
                rom_values[i] = INT_IN_DATA_WIDTH'($rtoi(
                    //         Degrees to radians                  To data width scale
                    $cos(i*ANGLE_INCREMENTS*PI/180.0) * (2.0**(INT_IN_DATA_WIDTH)/2 - 1.0))
                );
            end
            return rom_values;
        endfunction

        // Decare ROM memory and its contents
        array_2d ROM_VALUES_SIN = generate_rom_sin();
        array_2d ROM_VALUES_COS = generate_rom_cos();
        logic signed [INT_IN_DATA_WIDTH-1:0] sin_rom_value_dsp_ipipe = 0;
        logic signed [INT_IN_DATA_WIDTH-1:0] cos_rom_value_dsp_ipipe = 0;


        // Decimation logic (runs in parallel with LO multiplication part)
        always_ff @(posedge clk) begin

            if (i_deci_cmd_valid == 1'b1) begin
                valid_downsampling <= 1'b0;
                valid_downsampling_opipe <= valid_downsampling;
                counter_downsampling <= 0;

                counter_downsampling_maxvalue <= i_deci_cmd_data;

                // This is to prevent incrementation when no averaging (actual_accumulate_max_value == 0) is to be performed
                if (i_deci_cmd_data == 0) begin
                    increment_allowed <= 0;
                end else begin
                    increment_allowed <= 1'b1;
                end

            end else begin

                valid_downsampling <= 1'b0;
                valid_downsampling_opipe <= valid_downsampling;
                counter_downsampling <= 0;

                // Always increment decimation counter and send valid every time counter is in 0
                // Keeping only INT_DOWNSAMPLING'th sample
                if (i_valid == 1'b1) begin
                    counter_downsampling <= counter_downsampling + increment_allowed;
                    if (counter_downsampling == counter_downsampling_maxvalue) begin
                        counter_downsampling <= 0;
                        valid_downsampling <= 1'b1;
                    end
                end
            end
        end

        // Multiply input signal with sine and cosine wave local oscillator
        // assign o_data_i = sin_value_multiplied;
        always_ff @(posedge clk) begin
            // (In-Phase Path)
            // Increment the ROM pointer
            sin_pointer <= sin_pointer + 1;
            if (sin_pointer == INT_NUMBER_OF_SAMPLES-1) begin
                sin_pointer <= 0;
            end

            sin_rom_value_dsp_ipipe <= ROM_VALUES_SIN[sin_pointer];

            // Read a constant value using an array of multiplexers
            // sin_value_multiplied_dsp_opipe <= i_data * ROM_VALUES_SIN[sin_pointer];
            sin_value_multiplied <= i_data * sin_rom_value_dsp_ipipe;
            sin_value_multiplied_dsp_opipe <= sin_value_multiplied; // Solved DPOP DRC Issue
            // sin_value_multiplied <= ROM_VALUES_SIN[sin_pointer];
        end

        // assign o_data_q = cos_value_multiplied;
        always_ff @(posedge clk) begin
            // (In-Phase Path)
            // Increment the ROM pointer
            cos_pointer <= cos_pointer + 1;
            if (cos_pointer == INT_NUMBER_OF_SAMPLES-1) begin
                cos_pointer <= 0;
            end

            cos_rom_value_dsp_ipipe <= ROM_VALUES_COS[cos_pointer];

            // Read a constant value using an array of multiplexers
            // cos_value_multiplied_dsp_opipe <= i_data * ROM_VALUES_COS[cos_pointer];
            cos_value_multiplied <= i_data * cos_rom_value_dsp_ipipe;
            cos_value_multiplied_dsp_opipe <= cos_value_multiplied; // Solved DPOP DRC Issue
            // cos_value_multiplied <= ROM_VALUES_COS[cos_pointer];
        end


        // Instantiate Transposed Pipelined Parallel FIR Core
        assign o_valid = o_valid_i & o_valid_q;
        // (In-Phase Path)
        fir_parallel #(
            .INT_NUMBER_OF_TAPS(INT_NUMBER_OF_TAPS), // Max FIR Order + 1
            .INT_IN_DATA_WIDTH(2*INT_IN_DATA_WIDTH),
            .INT_COEF_WIDTH(INT_COEF_WIDTH),
            .INT_OUT_DATA_WIDTH(INT_OUT_DATA_WIDTH)
        ) inst_fir_parallel_i (
            // Inputs
            .clk(clk),
            .i_valid(valid_downsampling_opipe),
            .i_data(sin_value_multiplied_dsp_opipe),

            // Ports to Update Coeffitients
            .i_cmd_valid(i_fir_cmd_valid),
            .i_cmd(i_fir_cmd_coeffsel),
            .i_cmd_data(i_fir_cmd_data),

            // Outputs
            .o_valid(o_valid_i),
            .o_data(o_data_i)
        );

        // (Quadrature Path)
        fir_parallel #(
            .INT_NUMBER_OF_TAPS(INT_NUMBER_OF_TAPS), // Max FIR Order + 1
            .INT_IN_DATA_WIDTH(2*INT_IN_DATA_WIDTH),
            .INT_COEF_WIDTH(INT_COEF_WIDTH),
            .INT_OUT_DATA_WIDTH(INT_OUT_DATA_WIDTH)
        ) inst_fir_parallel_q (
            // Inputs
            .clk(clk),
            .i_valid(valid_downsampling_opipe),
            .i_data(cos_value_multiplied_dsp_opipe),

            // Ports to Update Coeffitients
            .i_cmd_valid(i_fir_cmd_valid),
            .i_cmd(i_fir_cmd_coeffsel),
            .i_cmd_data(i_fir_cmd_data),

            // Outputs
            .o_valid(o_valid_q),
            .o_data(o_data_q)
        );

    endmodule