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


`timescale 1 ns / 1 ns

module adc_read
    #(
        // Check ADC Documentation and configure how data should be interpreted in the FPGA
        parameter INT_ADC_DATA_WIDTH = 10,
        parameter INT_ADC_DATA_IS_INVERTED = 1, // 1 If RF ADC gives inverted values
        parameter INT_IDATA_ENC_OFFSETBIN = 1,  // 1 If input ADC data is encoded in 'Offset Binary', else 0
        parameter INT_IDATA_ENC_TWOSCOMPL = 0,  // 1 If input ADC data is encoded in 'Two's Complement', else 0
        parameter INT_ODATA_ENC_OFFSETBIN = 0,  // 1 To convert data into 'Offset Binary' encoding, else 0
        parameter INT_ODATA_ENC_TWOSCOMPL = 1   // 1 To convert data into 'Two's Complement' encoding, else 0
    )(
        // Inputs
        input  wire in_clk,  // single-eded clock only
        input  wire [INT_ADC_DATA_WIDTH-1:0] in_data,
        input  wire in_dready,

        // Outputs
        output reg [INT_ADC_DATA_WIDTH-1:0] out_data,
        output reg out_valid
    );

    // Declare registers, wires
    (* async_reg = "true" *) reg  [INT_ADC_DATA_WIDTH-1:0] reg_adc_data_ff;
    wire [INT_ADC_DATA_WIDTH-1:0] adc_data_converted;
    reg reg_valid = 0;

    // Core: 2-FF Synchronizer to stabilize data / prevent reading metastable states
    generate
        // Pass data through if the ADC encoding is desirable
        if ((INT_IDATA_ENC_OFFSETBIN == 1 && INT_ODATA_ENC_OFFSETBIN == 0) || 
            (INT_IDATA_ENC_TWOSCOMPL == 0 && INT_ODATA_ENC_TWOSCOMPL == 1)) begin

            // Revert the inverted signal in the RF path
            if (INT_ADC_DATA_IS_INVERTED == 1) begin
                // If inverted, it is only needed to invert bits lower than MSB to get Two's Complement value // Red Pitaya
                assign adc_data_converted[INT_ADC_DATA_WIDTH-1] = reg_adc_data_ff[INT_ADC_DATA_WIDTH-1]; // CRITICAL WARNING: [Constraints 18-841] Port in_data_ch1_0[9] has IOB constraint. But it drives multiple flops. Please specify IOB constraint on individual flop. The IOB constraint on port will be ignored.
                assign adc_data_converted[INT_ADC_DATA_WIDTH-2:0] = ~reg_adc_data_ff[INT_ADC_DATA_WIDTH-2:0];
            end else begin
                // If not inverted, it is only needed invert the MSB to get Two's Complement value
                assign adc_data_converted[INT_ADC_DATA_WIDTH-1] = ~reg_adc_data_ff[INT_ADC_DATA_WIDTH-1];
                assign adc_data_converted[INT_ADC_DATA_WIDTH-2:0] = reg_adc_data_ff[INT_ADC_DATA_WIDTH-2:0];
            end

        // Convert Two's Complement encoding into Offset Binary
        end else if ((INT_IDATA_ENC_OFFSETBIN == 0 && INT_ODATA_ENC_OFFSETBIN == 1) || 
                     (INT_IDATA_ENC_TWOSCOMPL == 1 && INT_ODATA_ENC_TWOSCOMPL == 0)) begin

            // Revert the inverted signal in the RF path
            if (INT_ADC_DATA_IS_INVERTED == 1) begin
                // If inverted, it is only needed invert the MSB to get the Offset Binary value
                assign adc_data_converted[INT_ADC_DATA_WIDTH-1] = ~reg_adc_data_ff[INT_ADC_DATA_WIDTH-1];
                assign adc_data_converted[INT_ADC_DATA_WIDTH-2:0] = reg_adc_data_ff[INT_ADC_DATA_WIDTH-2:0];
            end else begin
                // If not inverted, it is only needed to invert bits lower than MSB to get the Offset Binary value
                assign adc_data_converted[INT_ADC_DATA_WIDTH-1] = reg_adc_data_ff[INT_ADC_DATA_WIDTH-1];
                assign adc_data_converted[INT_ADC_DATA_WIDTH-2:0] = ~reg_adc_data_ff[INT_ADC_DATA_WIDTH-2:0];
            end

        end else begin

            // Perform no converion, revert the inverted signal in the RF path
            if (INT_ADC_DATA_IS_INVERTED == 1) begin
                assign adc_data_converted[INT_ADC_DATA_WIDTH-1:0] = ~reg_adc_data_ff[INT_ADC_DATA_WIDTH-1:0];
            end else begin
                assign adc_data_converted[INT_ADC_DATA_WIDTH-1:0] = reg_adc_data_ff[INT_ADC_DATA_WIDTH-1:0];
            end
        end


    endgenerate


    // Always pass the data from outside of the FPGA through a Flip-Flop
    // assign out_valid = reg_valid;
    // assign out_data = adc_data_converted;
    always @(posedge in_clk) begin
        reg_adc_data_ff[INT_ADC_DATA_WIDTH-1:0] <= in_data[INT_ADC_DATA_WIDTH-1:0];
        out_valid <= reg_valid;
        out_data[INT_ADC_DATA_WIDTH-1:0] <= adc_data_converted[INT_ADC_DATA_WIDTH-1:0];
        // Valid propagates together with reg_adc_data_2ff
        // Handshake: control the output rate by ready/valid signals
        if (in_dready == 1'b1) begin
            reg_valid <= 1'b1;
        end else begin
            reg_valid <= 1'b0;
        end
    end

endmodule