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



`timescale 1 ns / 1 ns

module dac_write
    #(
        // Check ADC Documentation and configure how data should be interpreted in the FPGA
        parameter INT_DAC_DATA_WIDTH = 10,
        parameter INT_INVERT_ODATA = 0,         // 1 to invert data values to be sent to DAC, else 0
        parameter INT_IDATA_ENC_OFFSETBIN = 0,  // 1 If input DAC data is encoded in 'Offset Binary', else 0
        parameter INT_IDATA_ENC_TWOSCOMPL = 1,  // 1 If input DAC data is encoded in 'Two's Complement', else 0
        parameter INT_ODATA_ENC_OFFSETBIN = 1,  // 1 To convert data into 'Offset Binary' encoding, else 0
        parameter INT_ODATA_ENC_TWOSCOMPL = 0   // 1 To convert data into 'Two's Complement' encoding, else 0
    )(
        // Inputs
        input   wire in_clk_data,                       // Example: 125 MSPs -> 125 MHz
        input   wire in_clk_clk,                        // Is 2x slower than datafreq, but shifted in time
        input   wire in_clk_wrt,                        // Is 2x slower than datafreq, but shifted in time + 500 ps (For interleaved mode)
        input   wire[INT_DAC_DATA_WIDTH-1:0] in_data,   // Not connect or zeros if 1 channel or interleaved DAC mode used only

        input   wire in_rst,
        input   wire in_valid,

        // Outputs
        output  wire[INT_DAC_DATA_WIDTH-1:0] out_data,
        output  wire out_clk,
        output  wire out_wrt,
        output  wire out_rst,

        output  wire out_ready    // Ready once the controller successfuly outputted the transaction
    );


    // Declare registers, wires
    wire [INT_DAC_DATA_WIDTH-1:0] in_dac_data_converted;
    reg [INT_DAC_DATA_WIDTH-1:0] reg_dac_data_ff;

    // Always pass the data from outside of the FPGA through a Flip-Flop (Optionally apply asynchronous data encoding conversion)
    generate
        // Output data with specific encoding
        if ((INT_IDATA_ENC_OFFSETBIN == 1 && INT_ODATA_ENC_OFFSETBIN == 0) || 
            (INT_IDATA_ENC_TWOSCOMPL == 0 && INT_ODATA_ENC_TWOSCOMPL == 1)) begin

            // Revert the inverted signal in the RF path
            if (INT_INVERT_ODATA == 1) begin
                // If inversion is required, it is only needed to invert bits lower than MSB to get Two's Complement value
                assign in_dac_data_converted[INT_DAC_DATA_WIDTH-1] = in_data[INT_DAC_DATA_WIDTH-1];
                assign in_dac_data_converted[INT_DAC_DATA_WIDTH-2:0] = ~in_data[INT_DAC_DATA_WIDTH-2:0];
            end else begin
                // If not invert, it is only needed invert the MSB to get Two's Complement value
                assign in_dac_data_converted[INT_DAC_DATA_WIDTH-1] = ~in_data[INT_DAC_DATA_WIDTH-1];
                assign in_dac_data_converted[INT_DAC_DATA_WIDTH-2:0] = in_data[INT_DAC_DATA_WIDTH-2:0];
            end

        // Convert Two's Complement encoding into Offset Binary
        end else if ((INT_IDATA_ENC_OFFSETBIN == 0 && INT_ODATA_ENC_OFFSETBIN == 1) || 
                     (INT_IDATA_ENC_TWOSCOMPL == 1 && INT_ODATA_ENC_TWOSCOMPL == 0)) begin

            // Revert the inverted signal in the RF path
            if (INT_INVERT_ODATA == 1) begin
                // If invert is required, it is only needed to invert the MSB to get the Offset Binary value
                assign in_dac_data_converted[INT_DAC_DATA_WIDTH-1] = ~in_data[INT_DAC_DATA_WIDTH-1];
                assign in_dac_data_converted[INT_DAC_DATA_WIDTH-2:0] = in_data[INT_DAC_DATA_WIDTH-2:0];
            end else begin
                // If not invert, it is only needed to invert bits lower than MSB to get the Offset Binary value
                assign in_dac_data_converted[INT_DAC_DATA_WIDTH-1] = in_data[INT_DAC_DATA_WIDTH-1];
                assign in_dac_data_converted[INT_DAC_DATA_WIDTH-2:0] = ~in_data[INT_DAC_DATA_WIDTH-2:0];
            end

        end else begin

            // Perform no converion, revert the inverted signal in the RF path
            if (INT_INVERT_ODATA == 1) begin
                assign in_dac_data_converted = ~in_data;
            end else begin
                assign in_dac_data_converted = in_data;
            end
        end

    endgenerate



    // Stream Handshake: Module is always ready to process new data
    assign out_ready = 1'b1;

    // DAC Clock and write signals (must originate in a mmcm/pll to comply with the timing requirements)
    assign out_clk = in_clk_clk;
    assign out_wrt = in_clk_wrt;

    // Sending registered data to the DAC channel
    assign out_data = reg_dac_data_ff;
    always @(posedge in_clk_data) begin
        if(in_valid == 1'b1) begin
            reg_dac_data_ff <= in_dac_data_converted;
        end
    end

endmodule