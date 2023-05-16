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

module dac_dual_iq
    #(
        parameter INT_DAC_DATA_WIDTH = 10
    )(
        // Inputs
        input  wire in_clk_data,        // Example: 125 MSPs -> 125 MHz
        input  wire in_clk_iqclk,       // Is 2x slower than datafreq, but shifted in time
        input  wire in_clk_iqwrt,       // Is 2x slower than datafreq, but shifted in time + 500 ps (For interleaved mode)
        input  wire[INT_DAC_DATA_WIDTH-1:0] in_dac_data_ch1,
        input  wire[INT_DAC_DATA_WIDTH-1:0] in_dac_data_ch2,   // Not connect or zeros if 1 channel or interleaved DAC mode used only
        input  wire in_dac_rst,

        input  wire in_valid_ch1,
        input  wire in_valid_ch2,

        // Outputs
        output wire[INT_DAC_DATA_WIDTH-1:0] out_dac_data,
        output wire out_iqclk,  // Controlled outside this module using clock_synthesizer
        output wire out_iqrst,
        output wire out_iqwrt,  
        output wire out_iqsel,

        output wire out_ready,      // Ready once the controller successfuly outputted the transaction

        // Simulation only
        output wire out_valid_ch1,  // For simulation only
        output wire out_valid_ch2   // For simulation only
    );

    // Declare registers and wires
    reg[INT_DAC_DATA_WIDTH-1:0] reg_dac_data_ch1 = {(INT_DAC_DATA_WIDTH){1'b0}};
    reg[INT_DAC_DATA_WIDTH-1:0] reg_dac_data_ch2 = {(INT_DAC_DATA_WIDTH){1'b0}};

    // Generate the core
    // Stream Handshake: Module is always ready to process new data on in_clk_data domain
    assign out_ready = 1'b1;

    // Clock and write signals
    // assign out_iqclk = in_clk_iqclk;
    // assign out_iqwrt = in_clk_iqwrt;

    // DAC IQ Reset: Resets both channels
    // assign out_valid_ch1 = in_valid_ch1;
    // assign out_valid_ch2 = in_valid_ch2;

    // Send data for both channels in a single clk cycle
    for(genvar j = 0; j < INT_DAC_DATA_WIDTH; j = j + 1) begin
        ODDR inst_data_oddr (
            .Q(out_dac_data[j]),
            .D1(in_dac_data_ch2[j]),    // Data for Ch2 appear on output each Positive edge
            .D2(in_dac_data_ch1[j]),    // Data for Ch1 appear on output each Negative edge
            .C(in_clk_data),
            .CE(1'b1),
            .R(1'b0),
            .S(1'b0)
        );
    end

    // Both channels are enabled, DDR assures that both SMA channels are
    // updated in one clk cycle in the in_clk_data domain
    ODDR inst_sel_oddr (
        .Q(out_iqsel),
        .D1(1'b1),          // Ch2 Select: Positive Edge
        .D2(1'b0),          // Ch1 Select: Negative edge
        .C(in_clk_data),
        .CE(1'b1),
        .R(1'b0),
        .S(1'b0)
    );

    // Update Rst signal the fastest way possible
    ODDR inst_rst_oddr (
        .Q(out_iqrst),
        .D1(in_dac_rst),
        .D2(in_dac_rst),
        .C(in_clk_data),
        .CE(1'b1),
        .R(1'b0),
        .S(1'b0)
    );


    // Use forwarded (source-synchronous) clock signals to prevent delay on the clock path
    // and allow for overall faster design
    ODDR inst_clk_oddr (
        .Q(out_iqclk),
        .D1(1'b0), // Positive edge sampling
        .D2(1'b1), // Negative edge sampling
        .C(in_clk_iqclk),
        .CE(1'b1),
        .R(1'b0),
        .S(1'b0)
    );
    ODDR inst_wrt_oddr (
        .Q(out_iqwrt),
        .D1(1'b0),
        .D2(1'b1),
        .C(in_clk_iqwrt),
        .CE(1'b1),
        .R(1'b0),
        .S(1'b0)
    );



    // For Simulation Only:
    ODDR inst_valid_ch1_oddr (
        .Q(out_valid_ch1),
        .D1(in_valid_ch1),
        .D2(1'b0),
        .C(in_clk_data),
        .CE(1'b1),
        .R(1'b0),
        .S(1'b0)
    );
    ODDR inst_valid_ch2_oddr (
        .Q(out_valid_ch2),
        .D1(1'b0),
        .D2(in_valid_ch2),
        .C(in_clk_data),
        .CE(1'b1),
        .R(1'b0),
        .S(1'b0)
    );

    // // DAC IQ Channel Control: 
    // assign out_iqsel = reg_dac_wrt_ch2_or_iqsel;
    // assign out_dac_data = reg_dac_data_ch1;

    // // Error flag
    // assign out_error_double_write = reg_error_double_write;
    // always @(posedge in_clk_data) begin
    //     case ({in_valid_ch1, in_valid_ch2})
    //         // Entire DAC bandwidth used for channel 1 only
    //         2'b01 : begin
    //             // Send Output 1 Select Signal
    //             reg_dac_wrt_ch2_or_iqsel <= 1'b1;

    //             // Update the ADC data A bus
    //             reg_dac_data_ch1 <= in_dac_data_ch1;
    //         end

    //         // Entire DAC bandwidth used for channel 2 only
    //         2'b10 : begin
    //             // Send Output 2 Select Signal
    //             reg_dac_wrt_ch2_or_iqsel <= 1'b0;

    //             // Update the ADC data A bus
    //             reg_dac_data_ch1 <= in_dac_data_ch2;
    //         end

    //         //  2x write at once: invalid combination, notify the system about this event
    //         2'b11 : reg_error_double_write <= 1'b1;

    //         // Idle: do nothing
    //         default : begin end
    //     endcase
        // end
endmodule