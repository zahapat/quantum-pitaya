    `timescale 1 ns/100 ps
    `include "fir_parallel_coeff.svh"

    (* USE_DSP = "YES" *)
    module fir_parallel #( // Allows to use the DSP resources
            parameter INT_NUMBER_OF_TAPS = 5,   // Max FIR Order + 1
            parameter INT_IN_DATA_WIDTH = 24,
            parameter INT_COEF_WIDTH = 16,
            parameter INT_OUT_DATA_WIDTH = 24,
            parameter INT_UPDATE_COEFFS_TRUE = 1
        )(
            // Inputs
            input logic clk,
            input logic i_valid,
            input logic signed [INT_IN_DATA_WIDTH-1:0] i_data,

            input logic i_cmd_valid,
            input logic [$clog2(INT_NUMBER_OF_TAPS)-1:0] i_cmd,
            input logic signed [INT_COEF_WIDTH-1:0] i_cmd_data,


            // Outputs
            output logic o_valid,
            output logic signed [INT_OUT_DATA_WIDTH-1:0] o_data
        );


        // Declare Constants
        localparam MAC_WIDTH = INT_IN_DATA_WIDTH + INT_COEF_WIDTH;

        // Declare signals
        logic[INT_NUMBER_OF_TAPS:0] valid;
        logic signed[INT_IN_DATA_WIDTH-1:0] reg_input_data_splitter [INT_NUMBER_OF_TAPS-1:0]; // reduce fanout and supports better placement
        logic signed[MAC_WIDTH-1:0] reg_multiplied [INT_NUMBER_OF_TAPS-1:0];
        logic signed[MAC_WIDTH-1:0] reg_added_accumulated [INT_NUMBER_OF_TAPS-1:0];

        // Coefficients Update Command Pipeline
        logic [INT_NUMBER_OF_TAPS:0] [$clog2(INT_NUMBER_OF_TAPS)-1:0] cmd_pipe_coeff_select = 0;
        logic [INT_NUMBER_OF_TAPS:0] [INT_COEF_WIDTH-1:0] cmd_pipe_coeff_data = 0;

        // Pre-calculate Coefficient IDs (start with 1, 0 is invalid)
        typedef logic [$clog2(INT_NUMBER_OF_TAPS)-1:0] array_2d [INT_NUMBER_OF_TAPS-1:0];
        function array_2d generate_module_ids;
            array_2d rom_values;
            for (int i = 1; i <= INT_NUMBER_OF_TAPS; i = i + 1) begin
                rom_values[i-1] = $clog2(INT_NUMBER_OF_TAPS)'(i);
            end
            return rom_values;
        endfunction
        array_2d COEFF_IDS = generate_module_ids();

        // Update FIR Coefficients based on the command (if used)
        always_ff @(posedge clk) begin
            // Pipeline: distribute sampled coefficients after sampling cmd valid
            for (int i = 0; i < INT_NUMBER_OF_TAPS; i = i + 1) begin
                cmd_pipe_coeff_select[i+1] <= cmd_pipe_coeff_select[i];
                cmd_pipe_coeff_data[i+1] <= cmd_pipe_coeff_data[i];

                // If coeff select matches with coeff ID, update it (Note: coeff_select 0 does nothing!)
                if (COEFF_IDS[i] == cmd_pipe_coeff_select[i]) begin
                    fir_coefficients[COEFF_IDS[i]-1] <= cmd_pipe_coeff_data[i];
                end
            end

            // Sampling cmd and cmd_data on cmd_valid
            if (i_cmd_valid == 1'b1) begin
                // Send to pipeline
                cmd_pipe_coeff_select[0] <= i_cmd;
                cmd_pipe_coeff_data[0] <= i_cmd_data;
            end
        end



        // Transposed Pipelined Parallel FIR Core
        assign o_valid = valid[INT_NUMBER_OF_TAPS];
        assign o_data[INT_OUT_DATA_WIDTH-1:0] = reg_added_accumulated[0][MAC_WIDTH-1-1:MAC_WIDTH-INT_OUT_DATA_WIDTH-1];

        always_ff @(posedge clk) begin

            // All N orders have multiply block
            valid[0] <= i_valid; // This is present because of the "data_splitter" register that adds 1 clk delay
            for (int i = 0; i < INT_NUMBER_OF_TAPS; i = i + 1) begin
                reg_input_data_splitter[i] <= i_data;

                valid[i+1] <= valid[i];
                reg_multiplied[i] <= reg_input_data_splitter[i] * fir_coefficients[i];
            end

            // Orders less than N have accumulators
            for (int i = 0; i < INT_NUMBER_OF_TAPS-1; i = i + 1) begin
                reg_added_accumulated[i] <= reg_multiplied[i] + reg_added_accumulated[i+1];
            end

            // Highest order does not have an accumulator
            reg_added_accumulated[INT_NUMBER_OF_TAPS-1] <= reg_multiplied[INT_NUMBER_OF_TAPS-1];

            // o_valid <= valid[INT_NUMBER_OF_TAPS];
        end


        // DSP48E1: 48-bit Multi-Functional Arithmetic Block
        //          7 Series
        // Xilinx HDL Language Template, version 2023.1

        // DSP48E1 #(
        //     // Feature Control Attributes: Data Path Selection
        //     .A_INPUT("DIRECT"),               // Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
        //     .B_INPUT("DIRECT"),               // Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
        //     .USE_DPORT("FALSE"),              // Select D port usage (TRUE or FALSE)
        //     .USE_MULT("MULTIPLY"),            // Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
        //     .USE_SIMD("ONE48"),               // SIMD selection ("ONE48", "TWO24", "FOUR12")
        //     // Pattern Detector Attributes: Pattern Detection Configuration
        //     .AUTORESET_PATDET("NO_RESET"),    // "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH"
        //     .MASK(48'h3fffffffffff),          // 48-bit mask value for pattern detect (1=ignore)
        //     .PATTERN(48'h000000000000),       // 48-bit pattern match for pattern detect
        //     .SEL_MASK("MASK"),                // "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2"
        //     .SEL_PATTERN("PATTERN"),          // Select pattern value ("PATTERN" or "C")
        //     .USE_PATTERN_DETECT("NO_PATDET"), // Enable pattern detect ("PATDET" or "NO_PATDET")
        //     // Register Control Attributes: Pipeline Register Configuration
        //     .ACASCREG(1),                     // Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
        //     .ADREG(1),                        // Number of pipeline stages for pre-adder (0 or 1)
        //     .ALUMODEREG(1),                   // Number of pipeline stages for ALUMODE (0 or 1)
        //     .AREG(1),                         // Number of pipeline stages for A (0, 1 or 2)
        //     .BCASCREG(1),                     // Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
        //     .BREG(1),                         // Number of pipeline stages for B (0, 1 or 2)
        //     .CARRYINREG(1),                   // Number of pipeline stages for CARRYIN (0 or 1)
        //     .CARRYINSELREG(1),                // Number of pipeline stages for CARRYINSEL (0 or 1)
        //     .CREG(1),                         // Number of pipeline stages for C (0 or 1)
        //     .DREG(1),                         // Number of pipeline stages for D (0 or 1)
        //     .INMODEREG(1),                    // Number of pipeline stages for INMODE (0 or 1)
        //     .MREG(1),                         // Number of multiplier pipeline stages (0 or 1)
        //     .OPMODEREG(1),                    // Number of pipeline stages for OPMODE (0 or 1)
        //     .PREG(1)                          // Number of pipeline stages for P (0 or 1)
        // )
        // DSP48E1_inst (
        //     // Cascade: 30-bit (each) output: Cascade Ports
        //     .ACOUT(ACOUT),                   // 30-bit output: A port cascade output
        //     .BCOUT(BCOUT),                   // 18-bit output: B port cascade output
        //     .CARRYCASCOUT(CARRYCASCOUT),     // 1-bit output: Cascade carry output
        //     .MULTSIGNOUT(MULTSIGNOUT),       // 1-bit output: Multiplier sign cascade output
        //     .PCOUT(PCOUT),                   // 48-bit output: Cascade output
        //     // Control: 1-bit (each) output: Control Inputs/Status Bits
        //     .OVERFLOW(OVERFLOW),             // 1-bit output: Overflow in add/acc output
        //     .PATTERNBDETECT(PATTERNBDETECT), // 1-bit output: Pattern bar detect output
        //     .PATTERNDETECT(PATTERNDETECT),   // 1-bit output: Pattern detect output
        //     .UNDERFLOW(UNDERFLOW),           // 1-bit output: Underflow in add/acc output
        //     // Data: 4-bit (each) output: Data Ports
        //     .CARRYOUT(CARRYOUT),             // 4-bit output: Carry output
        //     .P(P),                           // 48-bit output: Primary data output
        //     // Cascade: 30-bit (each) input: Cascade Ports
        //     .ACIN(ACIN),                     // 30-bit input: A cascade data input
        //     .BCIN(BCIN),                     // 18-bit input: B cascade input
        //     .CARRYCASCIN(CARRYCASCIN),       // 1-bit input: Cascade carry input
        //     .MULTSIGNIN(MULTSIGNIN),         // 1-bit input: Multiplier sign input
        //     .PCIN(PCIN),                     // 48-bit input: P cascade input
        //     // Control: 4-bit (each) input: Control Inputs/Status Bits
        //     .ALUMODE(ALUMODE),               // 4-bit input: ALU control input
        //     .CARRYINSEL(CARRYINSEL),         // 3-bit input: Carry select input
        //     .CLK(CLK),                       // 1-bit input: Clock input
        //     .INMODE(INMODE),                 // 5-bit input: INMODE control input
        //     .OPMODE(OPMODE),                 // 7-bit input: Operation mode input
        //     // Data: 30-bit (each) input: Data Ports
        //     .A(A),                           // 30-bit input: A data input
        //     .B(B),                           // 18-bit input: B data input
        //     .C(C),                           // 48-bit input: C data input
        //     .CARRYIN(CARRYIN),               // 1-bit input: Carry input signal
        //     .D(D),                           // 25-bit input: D data input
        //     // Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
        //     .CEA1(CEA1),                     // 1-bit input: Clock enable input for 1st stage AREG
        //     .CEA2(CEA2),                     // 1-bit input: Clock enable input for 2nd stage AREG
        //     .CEAD(CEAD),                     // 1-bit input: Clock enable input for ADREG
        //     .CEALUMODE(CEALUMODE),           // 1-bit input: Clock enable input for ALUMODE
        //     .CEB1(CEB1),                     // 1-bit input: Clock enable input for 1st stage BREG
        //     .CEB2(CEB2),                     // 1-bit input: Clock enable input for 2nd stage BREG
        //     .CEC(CEC),                       // 1-bit input: Clock enable input for CREG
        //     .CECARRYIN(CECARRYIN),           // 1-bit input: Clock enable input for CARRYINREG
        //     .CECTRL(CECTRL),                 // 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
        //     .CED(CED),                       // 1-bit input: Clock enable input for DREG
        //     .CEINMODE(CEINMODE),             // 1-bit input: Clock enable input for INMODEREG
        //     .CEM(CEM),                       // 1-bit input: Clock enable input for MREG
        //     .CEP(CEP),                       // 1-bit input: Clock enable input for PREG
        //     .RSTA(RSTA),                     // 1-bit input: Reset input for AREG
        //     .RSTALLCARRYIN(RSTALLCARRYIN),   // 1-bit input: Reset input for CARRYINREG
        //     .RSTALUMODE(RSTALUMODE),         // 1-bit input: Reset input for ALUMODEREG
        //     .RSTB(RSTB),                     // 1-bit input: Reset input for BREG
        //     .RSTC(RSTC),                     // 1-bit input: Reset input for CREG
        //     .RSTCTRL(RSTCTRL),               // 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
        //     .RSTD(RSTD),                     // 1-bit input: Reset input for DREG and ADREG
        //     .RSTINMODE(RSTINMODE),           // 1-bit input: Reset input for INMODEREG
        //     .RSTM(RSTM),                     // 1-bit input: Reset input for MREG
        //     .RSTP(RSTP)                      // 1-bit input: Reset input for PREG
        // );
        
        // End of DSP48E1_inst instantiation


    endmodule