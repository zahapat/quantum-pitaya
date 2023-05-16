// Description: This module performs the readout of an on-board ADC (1 or 2-channel) 
// with or without the generation of single-ended/differential clock buffers
// Note #1: This module supports only sigle-ended data signals
// Note #2: This module is limited to the INT_AXIS_DATA_WIDTH.
//          Therefore, data widths exceeding this number will result in an error
//          in the elaboration stage.
// 
// Generic Parameters Ranges:
//      - BIT_CREATE_CLK_BUFFERS: 1(true) or 0(false)
//      - BIT_DIFFERENTIAL_CLK: 1(true) or 0(false)
//      - INT_ADC_CHANNELS: 1 or 2
//      - INT_ADC_DATA_WIDTH: Enter the number of ADC data bits
//      - INT_AXIS_DATA_WIDTH: 32 bits typically, must be divisible by INT_DAC_INPUT_CHANNELS, all parts must be symmetric


`timescale 1 ns / 1 ps

module adc_read
    #(
        parameter INT_ADC_DATA_WIDTH = 10
    )(
        // Inputs
        input  wire in_clk,  // single-eded clock
        input  wire[INT_ADC_DATA_WIDTH-1:0] in_data,
        input  wire in_dready,

        // Outputs
        output wire[INT_ADC_DATA_WIDTH-1:0] out_data,
        output wire out_valid
    );

    // Declare registers
    reg[INT_ADC_DATA_WIDTH-1:0] reg_adc_data_2ff_1;
    // reg[INT_ADC_DATA_WIDTH-1:0] reg_adc_data_2ff_2;
    reg reg_valid;


    // Generate clock buffers to interface the ADC clock signal and the FPGA clock tree
    // generate
    //     // If buffers are required
    //     if (BIT_CREATE_CLK_BUFFERS) begin
    //         // If buffers are required
    //         if (BIT_DIFFERENTIAL_CLK) begin
    //             // Differential to single-ended conversion (buffers in the peripheral region)
    //             IBUFGDS inst_adc_clk_ibufgds
    //                 (
    //                     .I(in_clk[0]), 
    //                     .IB(in_clk[1]), 
    //                     .O(adc_clk_periph)
    //                 );
    //             // Use clock driver in the central region if the FPGA fabric
    //             BUFG inst_adc_clk_bufg
    //                 (
    //                     .I(adc_clk_periph),
    //                     .O(adc_clk)
    //                 );
    //             assign out_adc_clk = adc_clk;
    //         end

    //         else begin
    //             // Single-ended Clock Capable peripheral pin, use clock driver in central region of the FPGA
    //             BUFG inst_adc_clk_bufg
    //                 (
    //                     .I(in_clk[0]),
    //                     .O(adc_clk)
    //                 );
    //             assign out_adc_clk = adc_clk;
    //         end
    //     end

    //     else begin
    //         // Connect this module to a clean clock without creating any CLK buffers
    //         // I.e. if you need to create an MMCM/PLL somewhere else to clean jitter
    //         // or connect to a new clock synthesized somewhere else
    //         assign adc_clk = in_clk[0];
    //         assign out_adc_clk = adc_clk;
    //     end
    // endgenerate

    // Core: 2-FF Synchronizer to stabilize data / prevent reading metastable states
    assign out_data = reg_adc_data_2ff_1;
    assign out_valid = reg_valid;
    always @(posedge in_clk) begin
        reg_adc_data_2ff_1 <= in_data;
        // reg_adc_data_2ff_2 <= reg_adc_data_2ff_1;

        // Handshake: control the output rate by ready/valid signals
        // Valid propagates with reg_adc_data_2ff_1 value
        if (in_dready == 1'b1)
            reg_valid <= 1'b1;
        else
            reg_valid <= 1'b0;

    end

endmodule