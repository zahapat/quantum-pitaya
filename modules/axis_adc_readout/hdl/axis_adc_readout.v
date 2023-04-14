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
//      - INT_AXIS_DATA_WIDTH: 32 bits typically


`timescale 1 ns / 1 ps

module axis_adc_readout
    #(
        parameter BIT_CREATE_CLK_BUFFERS = 1'b1,
        parameter BIT_DIFFERENTIAL_CLK = 1'b0,
        parameter INT_ADC_CHANNELS = 2,
        parameter INT_ADC_DATA_WIDTH = 10,
        parameter INT_AXIS_DATA_WIDTH = 32
    )
    (
        // Inputs
        input   wire[BIT_DIFFERENTIAL_CLK:0] in_adc_clk,    // [clk_n][clk_p]
        input   wire[INT_ADC_DATA_WIDTH-1:0] in_adc_data_a,
        input   wire[INT_ADC_DATA_WIDTH-1:0] in_adc_data_b, // Not connect or zeros if 1 channel used only

        // Outputs
        output  wire out_adc_clk,
        output  wire out_adc_data_a,
        output  wire out_adc_data_b,

        output  wire m_axis_valid,
        output  wire[INT_AXIS_DATA_WIDTH-1:0] m_axis_data
    );


    // Declare constants
    localparam AXIS_DATA_WIDTH_ONE_ADC_CHANNEL = INT_AXIS_DATA_WIDTH/INT_ADC_CHANNELS;
    localparam AXIS_DATA_WIDTH_UNOCCUPIED_BITS = AXIS_DATA_WIDTH_ONE_ADC_CHANNEL - INT_ADC_DATA_WIDTH;


    // Declare signals
    wire adc_clk;
    wire adc_clk_periph;


    // Declare registers
    reg[INT_ADC_DATA_WIDTH-1:0] reg_adc_data_a1 = {(INT_ADC_DATA_WIDTH){1'b0}};
    reg[INT_ADC_DATA_WIDTH-1:0] reg_adc_data_a2 = {(INT_ADC_DATA_WIDTH){1'b0}};
    reg[INT_ADC_DATA_WIDTH-1:0] reg_adc_data_b1 = {(INT_ADC_DATA_WIDTH){1'b0}};
    reg[INT_ADC_DATA_WIDTH-1:0] reg_adc_data_b2 = {(INT_ADC_DATA_WIDTH){1'b0}};


    // Initialize registers
    // initial begin
    //     reg_adc_data_a1 = {(INT_ADC_DATA_WIDTH){1'b0}};
    //     reg_adc_data_a2 = {(INT_ADC_DATA_WIDTH){1'b0}};
    //     reg_adc_data_b1 = {(INT_ADC_DATA_WIDTH){1'b0}};
    //     reg_adc_data_b2 = {(INT_ADC_DATA_WIDTH){1'b0}};
    // end


    // Generate clock buffers to interface the ADC clock signal and the FPGA clock tree
    generate
        // If buffers are required
        if (BIT_CREATE_CLK_BUFFERS) begin
            // If buffers are required
            if (BIT_DIFFERENTIAL_CLK) begin
                // Differential to single-ended conversion (buffers in the peripheral region)
                IBUFGDS inst_adc_clk_ibufgds
                    (
                        .I(in_adc_clk[0]), 
                        .IB(in_adc_clk[1]), 
                        .O(adc_clk_periph)
                    );
                // Use clock driver in the central region if the FPGA fabric
                BUFG inst_adc_clk_bufg
                    (
                        .I(adc_clk_periph),
                        .O(adc_clk)
                    );
                assign out_adc_clk = adc_clk;
            end

            else begin
                // Single-ended Clock Capable peripheral pin, use clock driver in central region of the FPGA
                BUFG inst_adc_clk_bufg
                    (
                        .I(in_adc_clk[0]),
                        .O(adc_clk)
                    );
                assign out_adc_clk = adc_clk;
            end
        end

        else begin
            // Connect this module to a clean clock without creating any CLK buffers
            // I.e. if you need to create an MMCM/PLL somewhere else to clean jitter
            // or connect to a new clock synthesized somewhere else
            assign adc_clk = in_adc_clk[0];
            assign out_adc_clk = adc_clk;
        end
    endgenerate


    // Generate the core
    generate
        // Check for invalid generic parameters
        if ((AXIS_DATA_WIDTH_UNOCCUPIED_BITS <= 0) | (INT_ADC_CHANNELS < 1) | (INT_ADC_CHANNELS > 2)) begin
            $error(1, "ERROR: Invalid parameters. Check the documentation for this module for the correct configuration.");
        end

        // Generate the core with correct parameters
        else begin
            // Core: 2-FF Synchronizer to stabilize data / prevent reading metastable states
            assign out_adc_data_a = reg_adc_data_a2;
            assign out_adc_data_b = reg_adc_data_b2;
            always @(posedge adc_clk) begin
                reg_adc_data_a1 <= in_adc_data_a;
                reg_adc_data_a2 <= reg_adc_data_a1;
            end

            if (INT_ADC_CHANNELS == 2) begin
                always @(posedge adc_clk) begin
                    reg_adc_data_b1 <= in_adc_data_b;
                    reg_adc_data_b2 <= reg_adc_data_b1;
                end
            end


            // AXIStream Handshake: Data always valid
            assign m_axis_valid = 1'b1;
            assign m_axis_data = 
            {
                {(AXIS_DATA_WIDTH_UNOCCUPIED_BITS){1'b0}}, reg_adc_data_b2,
                {(AXIS_DATA_WIDTH_UNOCCUPIED_BITS){1'b0}}, reg_adc_data_a2
            };

            // Example for a 10-bit 2-channel ADC:
            //                     --- reg_adc_data_b2 [9:0] ---                   --- reg_adc_data_a2 [9:0] ---
            //                     9  8  7  6  5  4  3  2  1  0                    9  8  7  6  5  4  3  2  1  0
            //                    [1][1][1][0][1][0][0][1][1][1]                  [1][1][1][0][1][0][0][1][1][1]
            //                     |  |  |  |  |  |  |  |  |  |                    |  |  |  |  |  |  |  |  |  | 
            //  31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0 
            //  [0][0][0][0][0][0][1][1][1][0][1][0][0][1][1][1][0][0][0][0][0][0][1][1][1][0][1][0][0][1][1][1] = m_axis_data[31:0]

        end
    endgenerate

endmodule