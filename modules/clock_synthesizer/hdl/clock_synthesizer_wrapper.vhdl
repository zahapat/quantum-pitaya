// To set parameters to set up this core according to your
// specifications, it is possible to use the "mmcm_analysis.py"
// script. This script will generate set of parameters to set
// up this core as possible to your output clock requirements

`timescale 1 ns / 1 ps

module clock_synthesizer
    #(
         // Set input clk parameters
         parameter REAL_CLKIN1_MHZ = 125.0,
         parameter INT_OUT_CLOCKS = 2,

         // Setup the VCO frequency for the entire device
         parameter INT_VCO_DIVIDE = 1,
         parameter REAL_VCO_MULTIPLY = 9.000,

         parameter REAL_DIVIDE_OUT0 = 9.000,
         parameter INT_DIVIDE_OUT1 = 9,
         parameter INT_DIVIDE_OUT2 = 1,
         parameter INT_DIVIDE_OUT3 = 1,
         parameter INT_DIVIDE_OUT4 = 1,
         parameter INT_DIVIDE_OUT5 = 1,
         parameter INT_DIVIDE_OUT6 = 1,

         parameter REAL_DUTY_OUT0 = 0.500,
         parameter REAL_DUTY_OUT1 = 0.500,
         parameter REAL_DUTY_OUT2 = 0.500,
         parameter REAL_DUTY_OUT3 = 0.500,
         parameter REAL_DUTY_OUT4 = 0.500,
         parameter REAL_DUTY_OUT5 = 0.500,
         parameter REAL_DUTY_OUT6 = 0.500,

         parameter REAL_PHASE_OUT0 = 90.000,
         parameter REAL_PHASE_OUT1 = 115.000,
         parameter REAL_PHASE_OUT2 = 0.000,
         parameter REAL_PHASE_OUT3 = 0.000,
         parameter REAL_PHASE_OUT4 = 0.000,
         parameter REAL_PHASE_OUT5 = 0.000,
         parameter REAL_PHASE_OUT6 = 0.000
    )(
        // Inputs
        input  logic in_clk0,

        // Fine Phase Shift
        input  logic in_fineps_clk,
        input  logic in_fineps_incr,
        input  logic in_fineps_decr,
        input  logic in_fineps_valid,
        output logic out_fineps_dready,

        // Outputs
        output logic out_clk0,
        output logic out_clk1,
        output logic out_clk2,
        output logic out_clk3,
        output logic out_clk4,
        output logic out_clk5,
        output logic out_clk6,
        output logic locked
);

    

endmodule