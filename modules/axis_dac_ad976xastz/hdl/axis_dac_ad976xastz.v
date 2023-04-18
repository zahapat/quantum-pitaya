// Description: This module performs the write operation to one channel of the on-board dac
// Note #1: This module supports only sigle-ended data signals
// Note #2: Supports separate write inputs and Interleaved Mode:
//          "In interleaving mode, the input data stream is demuxed into 
//          its original I and Q data and then latched. The I and Q data 
//          is then converted by the two DACs and updated at half the 
//          input data rate."
// Note #3: "Separate write inputs allow data to be written to
//          the two DAC ports independent of one another. Separate clocks
//          control the update rate of the DACs."
// Note #4: Originally designed for "ad9767astz DAC"
// 
// Generic Parameters Ranges:
//      - INT_DAC_INPUT_CHANNELS: 1 (Independent / Interleaved Mode) or 
//                                2 (Independent Mode)
//      - BIT_INTERLEAVED_MODE: 1'b0 (false, Enable Interleaved Mode) or
//                              1'b1 (true, Disable Interleaved Mode/Enable Independent Mode)
//      - INT_DAC_DATA_WIDTH: Enter the number of DAC data bits
//      - INT_AXIS_DATA_WIDTH: 32 bits typically, must be divisible by INT_DAC_INPUT_CHANNELS, all parts must be symmetric
// 
// 1) Independent DAC Channels (BIT_INTERLEAVED_MODE = 1'b0)
// Latches control: - Both CLK and WRT line latches are updated on the 
//                    rising edge of their respective control signals.
//                  - The rising edge of CLK must occur before or 
//                    simultaneously with the rising edge of WRT. 
//                    If the rising edge of CLK occurs
//                    after the rising edge of WRT, a minimum delay 
//                    of 2 ns must be maintained from the rising edge 
//                    of WRT to the rising edge of CLK.
//                  - On falling edge of the data clock, the DDR WR+CLK clock
//                    switches to 1. After the
//                  - The clock duty cycle, setup and hold times
//                    can also be varied within the clock cycle as long as 
//                    the specified minimum times are met, although the 
//                    !! location of these transition edges may affect digital 
//                    feedthrough and distortion performance.
//                  - Best performance is typically achieved when the input 
//                    data transitions on the falling edge of a 50% duty 
//                    cycle clock. 
// Example Waveform :    D1     D2     D3     D4     D5     D6
//          DATA    :   ‾‾‾‾‾\______/‾‾‾‾‾‾\______/‾‾‾‾‾‾\______/
//          DATA CLK:   ‾‾\__/‾‾‾\__/‾‾‾\__/‾‾‾\__/‾‾‾\__/‾‾‾\__/
// 
//          WRITE   :   \__/‾‾‾\__/‾‾‾\__/‾‾‾\__/‾‾‾\__/‾‾‾\__/‾‾
//          CLOCK   :   \__/‾‾‾\__/‾‾‾\__/‾‾‾\__/‾‾‾\__/‾‾‾\__/‾‾
//          OUTPUT  :             D1     D2     D3     D4     D5
// 
// 2) Interleaved IQ DAC Channels (BIT_INTERLEAVED_MODE = 1'b1)
// Function: - Data enters the device on the rising edge of IQWRT:
//                          IQDAT:   ____/‾‾‾‾‾‾\______/‾‾‾‾‾‾\______/‾‾
//                          IQWRT:   ‾‾\___/‾‾\___/‾‾\___/‾‾\___/‾‾\___/
// 
//           - IQSEL sends data to either Channel 1 (IQSEL = 1) or Channel 2 (IQSEL = 0)
//           - IQSEL must change state only when IQWRT and IQCLK are low
//                          IQWRT:   ‾‾\___/‾‾\___/‾‾\___/‾‾\___/‾‾\___/ must be 0 to update a channel
//                          IQCLK:   ‾‾\___/‾‾\___/‾‾\___/‾‾\___/‾‾\___/ must be 0 to update a channel
//                          IQSEL:   ____/‾‾‾‾‾‾\______/‾‾‾‾‾‾\______/‾‾
//                          IQSEL:   Ch2   Ch1    Ch2    Ch1    Ch2   Ch1
// 
//           - When IQRESET is high, IQCLK is disabled
//                          IQRESET: _______/‾‾‾‾‾
//                          IQCLK:   ‾‾‾‾‾‾‾\_____ goes to 0 when rst
// 
//           - When IQRESET goes low, the next rising edge on IQCLK updates 
//             both DAC latches with the data present at their inputs
//                          IQRESET: ‾‾‾‾‾‾‾\________________
//                          IQCLK:   ___________/‾‾‾‾‾‾‾\____
//                          IQDAT:   ___________/‾‾‾‾‾‾‾\____
//                          
//           - !! In the interleaved mode, IQCLK is divided by 2 internally
//                          IQCLK:              /‾‾‾‾‾‾\______/‾‾‾‾‾‾\______/
//                          IQCLK (internal):   /‾‾‾‾‾‾‾‾‾‾‾‾‾\_____________/
//           - Following this first rising edge, the DAC latches are only 
//             updated on every other rising edge of IQCLK
//           - !! IQRESET can be used to synchronize the routing of the data 
//             to the DACs.



`timescale 1 ns / 1 ps

module axis_dac_ad976xastz
    #(
        parameter INT_DAC_INPUT_CHANNELS = 1,
        parameter INT_DAC_OUTPUT_CHANNELS = 2,
        parameter BIT_INTERLEAVED_MODE = 1'b0,
        parameter INT_DAC_DATA_WIDTH = 10,
        parameter INT_AXIS_DATA_WIDTH = 32
    )(
        // Inputs
        input   wire[INT_DAC_INPUT_CHANNELS-1:0] aclk,          // Example: 60 MHz
        input   wire[INT_DAC_INPUT_CHANNELS-1:0] in_ddr_clk,    // Interleaved mode: 60*2 MHz
        input   wire[INT_DAC_INPUT_CHANNELS-1:0] in_dac_valid,
        input   wire[INT_DAC_DATA_WIDTH-1:0] in_dac_data_a,
        input   wire[INT_DAC_DATA_WIDTH-1:0] in_dac_data_b,     // Not connect or zeros if 1 channel or interleaved DAC mode used only
        input   wire in_iqsel_ch_a_select,                      // For interleaved IQ mode only
        input   wire in_iqsel_ch_b_select,                      // For interleaved IQ mode only
        input   wire in_dac_rst,

        input   wire s_axis_valid,
        input   wire[INT_AXIS_DATA_WIDTH-1:0] s_axis_data,

        // Outputs
        output  wire s_axis_ready,

        output  wire[INT_DAC_DATA_WIDTH-1:0] out_dac_data_a,
        output  wire[INT_DAC_DATA_WIDTH-1:0] out_dac_data_b,  // Not connect or zeros if 1 channel or interleaved DAC mode used only
        output  wire out_dac_clk_a_or_iqclk,
        output  wire out_dac_clk_b_or_iqrst,
        output  wire out_dac_wrt_a_or_iqwrt,
        output  wire out_dac_wrt_b_or_iqsel
    );


    // Declare constants
    localparam AXIS_DATA_WIDTH_ONE_DAC_CHANNEL = INT_AXIS_DATA_WIDTH/INT_DAC_OUTPUT_CHANNELS;
    localparam AXIS_DATA_WIDTH_UNOCCUPIED_BITS = AXIS_DATA_WIDTH_ONE_DAC_CHANNEL - INT_DAC_DATA_WIDTH;


    // Declare registers
    reg[INT_DAC_DATA_WIDTH-1:0] reg_dac_data_a = {(INT_DAC_DATA_WIDTH){1'b0}};
    reg[INT_DAC_DATA_WIDTH-1:0] reg_dac_data_b = {(INT_DAC_DATA_WIDTH){1'b0}};
    reg reg_iqsel_ch_a_select = 1'b0;
    reg reg_iqsel_ch_b_select = 1'b0;
    reg reg_dac_rst = 1'b0;
    reg reg_iqsel_oddr_d12 = 2'b00;


    // Generate the core
    generate
        // Check for invalid generic parameters
        if ((AXIS_DATA_WIDTH_UNOCCUPIED_BITS <= 0) | (INT_DAC_INPUT_CHANNELS < 1) | (INT_DAC_INPUT_CHANNELS > 2)) begin
            $error(1, "ERROR: Invalid parameters. Check the documentation for this module for the correct configuration.");
        end

        // Generate the core with correct parameters
        else begin

            // AXIStream Handshake: Module is always ready to process new data
            assign m_axis_valid = 1'b1;
            assign m_axis_ready = 1'b1;

            if (BIT_INTERLEAVED_MODE == 1'b0) begin
                // DAC Ch1 DAC latch control
                assign out_dac_clk_a_or_iqclk = in_ddr_clk[0];
                assign out_dac_wrt_a_or_iqwrt = in_ddr_clk[0];

                // Sending registered data to the Ch1 DAC
                assign out_dac_data_a = reg_dac_data_a;
                always @(posedge aclk[0]) begin
                    if(in_dac_valid[0] == 0'b1) begin
                        reg_dac_data_a <= 
                            in_dac_data_a | s_axis_data[INT_AXIS_DATA_WIDTH/2-AXIS_DATA_WIDTH_UNOCCUPIED_BITS-1:
                                                        INT_AXIS_DATA_WIDTH/2-AXIS_DATA_WIDTH_UNOCCUPIED_BITS-INT_DAC_DATA_WIDTH];
                    end
                end

                // 1.1) Control 2 ADC channels (channel a and b)
                if (INT_DAC_INPUT_CHANNELS == 2) begin
                    assign out_dac_clk_b_or_iqrst = in_ddr_clk[1];
                    assign out_dac_wrt_b_or_iqsel = in_ddr_clk[1];

                    // Sending registered data to the Ch2 DAC
                    always @(posedge aclk[1]) begin
                        if(in_dac_valid[1] == 0'b1) begin
                            reg_dac_data_b <= 
                                in_dac_data_b | s_axis_data[INT_AXIS_DATA_WIDTH/1-AXIS_DATA_WIDTH_UNOCCUPIED_BITS-1:
                                                            INT_AXIS_DATA_WIDTH/1-AXIS_DATA_WIDTH_UNOCCUPIED_BITS-INT_DAC_DATA_WIDTH];
                        end
                    end
                end
            end

            else begin
                if (INT_DAC_INPUT_CHANNELS == 1 & INT_DAC_OUTPUT_CHANNELS == 2) begin
                    // DAC IQ Clk:
                    ODDR #(
                        .DDR_CLK_EDGE("OPPOSITE_EDGE"),
                        .INIT(1'b0),
                        .SRTYPE("SYNC")
                    ) inst_dac_clk_oddr (
                        .D1(1'b0),
                        .D2(1'b1),
                        .C(in_ddr_clk[0]),
                        .CE(1'b1),
                        .R(1'b0),
                        .S(1'b0),
                        .Q(out_dac_clk_a_or_iqclk)
                    );

                    // DAC IQ Write: 
                    ODDR #(
                        .DDR_CLK_EDGE("OPPOSITE_EDGE"),
                        .INIT(1'b0),
                        .SRTYPE("SYNC")
                    ) inst_dac_wrt_oddr (
                        .D1(1'b0),
                        .D2(1'b1),
                        .C(in_ddr_clk[0]),
                        .CE(1'b1),
                        .R(1'b0),
                        .S(1'b0),
                        .Q(out_dac_wrt_a_or_iqwrt)
                    );

                    // DAC IQ Reset:
                    always @(posedge aclk[0]) begin
                        reg_dac_rst <= in_dac_rst;
                    end
                    ODDR #(
                        .DDR_CLK_EDGE("OPPOSITE_EDGE"),
                        .INIT(1'b0),
                        .SRTYPE("SYNC")
                    ) inst_dac_rst_oddr (
                        .D1(1'b0),
                        .D2(1'b0),
                        .C(aclk[0]),
                        .CE(1'b1),
                        .R(1'b0),
                        .S(1'b0),
                        .Q(out_dac_clk_b_or_iqrst)
                    );

                    // DAC IQ Channel Select: 
                    always @(posedge aclk[0]) begin
                        case ({reg_iqsel_ch_b_select, reg_iqsel_ch_a_select})
                            2'b00 : reg_iqsel_oddr_d12 = 2'b10; // Switch between channel 1 and channel 2
                            2'b01 : reg_iqsel_oddr_d12 = 2'b11; // Both DAC transactions go to channel 1
                            2'b10 : reg_iqsel_oddr_d12 = 2'b00; // Both DAC transactions go to channel 2
                            2'b11 : reg_iqsel_oddr_d12 = 2'b10; // Switch between channel 1 and channel 2
                        endcase
                    end
                    ODDR #(
                        .DDR_CLK_EDGE("OPPOSITE_EDGE"),
                        .INIT(1'b0),
                        .SRTYPE("SYNC")
                    ) inst_dac_sel_oddr (
                        .D1(1'b0),
                        .D2(1'b1),
                        .C(aclk[0]),
                        .CE(1'b1),
                        .R(1'b0),
                        .S(1'b0),
                        .Q(out_dac_wrt_b_or_iqsel)
                    );

                    // Regardless on which ports are connected, register the output data before sending to the output
                    always @(posedge aclk[0]) begin
                        if((in_dac_valid[0] | s_axis_valid) == 1'b1) begin
                            // Use reg
                            reg_dac_data_a <= 
                                in_dac_data_a | s_axis_data[INT_AXIS_DATA_WIDTH/2-AXIS_DATA_WIDTH_UNOCCUPIED_BITS-1:
                                                            INT_AXIS_DATA_WIDTH/2-AXIS_DATA_WIDTH_UNOCCUPIED_BITS-INT_DAC_DATA_WIDTH];
                            reg_dac_data_b <= 
                                in_dac_data_b | s_axis_data[INT_AXIS_DATA_WIDTH/1-AXIS_DATA_WIDTH_UNOCCUPIED_BITS-1:
                                                            INT_AXIS_DATA_WIDTH/1-AXIS_DATA_WIDTH_UNOCCUPIED_BITS-INT_DAC_DATA_WIDTH];
                        end
                    end

                    // Update data signals using DDR buffers to output data twice per one clock cycle
                    for(genvar i = 0; i < INT_DAC_DATA_WIDTH; i = i + 1) begin
                    ODDR #(
                        .DDR_CLK_EDGE("OPPOSITE_EDGE"),
                        .INIT(1'b0),
                        .SRTYPE("SYNC")
                    ) inst_data_oddr (
                        .D1(reg_dac_data_a[i]),
                        .D2(reg_dac_data_b[i]),
                        .C(aclk[0]),
                        .CE(1'b1),
                        .R(1'b0),
                        .S(1'b0),
                        .Q(out_dac_data_a[i])
                    );
                    end
                end
            end
        end
    endgenerate

endmodule