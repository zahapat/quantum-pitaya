`timescale 1 ns / 1 ps

module adc_readout 
    #(
        parameter integer IN_ADC_DATA_WIDTH = 10,
        parameter bit     DIFFERENTIAL_CLK = 0,
        parameter integer AXIS_ADC_DATA_WIDTH = 32
    )
    (
        // Inputs
        input   wire in_adc_clk_p,
        input   wire in_adc_clk_n,    // Not connect if unused
        input   wire[IN_ADC_DATA_WIDTH-1:0] in_adc_data_a,
        input   wire[IN_ADC_DATA_WIDTH-1:0] in_adc_data_b,

        // Outputs
        output  wire out_adc_clk,
        output  wire out_adc_data_a,
        output  wire out_adc_data_b,

        output  wire m_axis_valid,
        output  wire[] m_axis_data
    );


    // Declare signals
    wire adc_clk;
    wire adc_clk_periph;


    // Declare registers
    reg[IN_ADC_DATA_WIDTH-1:0] reg_adc_data_a1;
    reg[IN_ADC_DATA_WIDTH-1:0] reg_adc_data_a2;
    reg[IN_ADC_DATA_WIDTH-1:0] reg_adc_data_b1;
    reg[IN_ADC_DATA_WIDTH-1:0] reg_adc_data_b2;


    // Generate ADC clock signal: 'adc_clk' to work with
    generate
        if (DIFFERENTIAL_CLK)
            // Differential to single-ended conversion (peripheral region)
            IBUFGDS inst_adc_clk_ibufgds
                (
                    .I(in_adc_clk_p), 
                    .IB(in_adc_clk_n), 
                    .O(adc_clk_periph)
                );
            // Use clock driver in the central region if the FPGA fabric
            BUFG inst_adc_clk_bufg
                (
                    .I(adc_clk_periph)
                    .O(adc_clk)
                );
            assign out_adc_clk = adc_clk;

        else
            // Single-ended Clock Capable peripheral pin, use clock driver in central region of the FPGA
            BUFG inst_adc_clk_bufg
                (
                    .I(in_adc_clk_p)
                    .O(adc_clk)
                );
            assign out_adc_clk = adc_clk;

    endgenerate


    // Process: 2-FF Synchronizer to stabilize data / prevent metastability at the input of the device
    assign out_adc_data_a = reg_adc_data_a2;
    assign out_adc_data_b = reg_adc_data_b2;
    always @(posedge adc_clk)
        reg_adc_data_a1 <= in_adc_data_a;
        reg_adc_data_b1 <= in_adc_data_b;
        reg_adc_data_a2 <= reg_adc_data_a1;
        reg_adc_data_b2 <= reg_adc_data_b1;


    // AXI Stream Handshake: Data always valid
    assign m_axis_valid = 1'b1;
    assign m_axis_data = {
        
    }

endmodule