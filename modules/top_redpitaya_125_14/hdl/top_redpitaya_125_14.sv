// To set parameters to set up this core according to your
// specifications, it is possible to use the "mmcm_analysis.py"
// script. This script will generate set of parameters to set
// up this core as possible to your output clock requirements

`timescale 1 ns / 1 ps

module top_redpitaya_125_14
    #(
        parameter INT_DIFF_ADC_CLK = 0,
        parameter INT_ADC_CHANNELS = 2,
        parameter INT_DAC_CHANNELS = 2,
        parameter INT_ADC_DATA_CH1_WIDTH = 14,
        parameter INT_ADC_DATA_CH2_WIDTH = 14,
        parameter INT_ADC_DATA_CH1_TRIM_BITS_RIGHT = 1,
        parameter INT_ADC_DATA_CH2_TRIM_BITS_RIGHT = 1,
        parameter INT_DAC_DATA_CH1_WIDTH = 10,
        parameter INT_DAC_DATA_CH2_WIDTH = 10,
        parameter INT_AXIS_DATA_WIDTH = 32,
        parameter INT_BYPASS_DSP = 1,

        // DDC
        parameter INT_DDC_NUMBER_OF_TAPS = 15,          // Max FIR Order + 1
        parameter INT_DDC_COEF_WIDTH = 15,              // Width of each FIR coefficient
        parameter REAL_DDC_LOCOSC_IN_FREQ_MHZ = 125.0,  // Sampling/Clock frequency the local oscillator is running on
        parameter REAL_DDC_LOCOSC_OUT_FREQ_MHZ = 25.0,  // The desired frequency of the local oscillator (sine + cosine)
        parameter INT_DDC_OUT_DATA_WIDTH = 20,          // Output data width of the digital downconversion
        parameter INT_DDC_MAX_DOWNSAMPLING = 5,             // The decimation value

        // Integration & averaging
        parameter INT_AVG_MAX_AVERAGE_BY = 5,      // Enter the number of how many data points are to be averaged
        parameter INT_AVG_DIVISOR_WIDTH = 28,      // Set the resolution of the divisor. Config INT_IN_DATA_WIDTH=14 & INT_DIVISOR_WIDTH=28 (total 42 bits) implements 1x DSP block for the division

        // Multichannel Accumulator
        parameter INT_MULTIACC_FIFO_WIDTH = 32,
        // parameter INT_MULTIACC_FIFO_DEPTH = 1024, // To be implemented
        parameter INT_MULTIACC_FIFO_DEPTH = 32, // Simulation
        parameter INT_MULTIACC_CHANNELS = 10,
        parameter INT_MULTIACC_REPETITIONS = 10,

        // RX Command Parser
        parameter INT_CMD_OUTPUT_WIDTH = 5,
        parameter INT_MODULE_SELECT_WIDTH = 5,
        parameter INT_MODULES_CMD_CNT = 13,

        // Output FIFO Buffer 1, 2 Depth
        parameter INT_OUT_FIFO_BUFFER1_DEPTH = 1024, // Must be a multiple of 2 (because of Gray counter width)
        parameter INT_OUT_FIFO_BUFFER2_DEPTH = 1024 // Must be a multiple of 2 (because of Gray counter width)
    )(
        // AXI4 Lite ports
        input  logic aclk,

        // Peripheral Inputs
        input  logic in_adc_clk_p,
        input  logic in_adc_clk_n,
        input  logic[INT_ADC_DATA_CH1_WIDTH-1:0] in_data_ch1,
        input  logic[INT_ADC_DATA_CH2_WIDTH-1:0] in_data_ch2,

        // Peripheral Outputs
        output logic[INT_DAC_DATA_CH1_WIDTH-1:0] dac_o_data,
        output logic dac_o_iqsel,
        output logic dac_o_iqclk,
        output logic dac_o_iqwrt,
        output logic dac_o_iqrst,
        output logic adc_i_clkstb,

        output logic[8-1:0] leds,

        // Accumulator Ready
        output  logic o_multiacc_o_acc_valid_i,

        // Output CDCC FIFO Read Signals
        output logic[INT_AXIS_DATA_WIDTH-1:0] o_fifo_data_ch1,
        output logic[INT_AXIS_DATA_WIDTH-1:0] o_fifo_data_ch2,
        output logic o_fifo_data_ch1_valid,
        output logic o_fifo_data_ch2_valid,
        input  logic i_fifo_rd_dready_ch1,
        input  logic i_fifo_rd_dready_ch2,

        // Input CDCC FIFO CMD Signals
        input  logic [INT_AXIS_DATA_WIDTH-1:0] i_cmddata_axi_fifo_i_data,
        input  logic i_cmddata_axi_fifo_i_valid,
        output logic o_cmddata_axi_fifo_o_ready,    // This FIFO ready
        input  logic [INT_AXIS_DATA_WIDTH-1:0] i_cmd_axi_fifo_i_data, // TEST THIS NOW
        input  logic i_cmd_axi_fifo_i_valid,
        output logic o_cmd_axi_fifo_o_ready,    // This FIFO ready

        // Multichannel Read Control: Next Read Command Ready Flag
        output logic o_multichrdctrl_cmd_dready_i,
        output logic o_multichrdctrl_cmd_dready_q,

        // External Analog Trigger
        input  logic i_acc_trigger_1,
        input  logic i_acc_trigger_2

);


    // Clock
    logic adc_clk_buf;
    logic dac_iqclk_mmcm;
    logic dac_iqwrt_mmcm;
    logic adc_clk_mmcm;
    logic locked_mmcm1;

    // ADC Channel 1,2
    localparam INT_ADC_DATA_CH1_WIDTH_TRIMMED = INT_ADC_DATA_CH1_WIDTH - INT_ADC_DATA_CH1_TRIM_BITS_RIGHT;
    localparam INT_ADC_DATA_CH2_WIDTH_TRIMMED = INT_ADC_DATA_CH2_WIDTH - INT_ADC_DATA_CH2_TRIM_BITS_RIGHT;

    logic [INT_ADC_DATA_CH1_WIDTH_TRIMMED-1:0] adc_i_data_ch1;
    logic [INT_ADC_DATA_CH1_WIDTH_TRIMMED-1:0] adc_o_data_ch1;
    logic adc_i_dready_ch1;       // Destination ready
    logic adc_o_data_valid_ch1;   // Data valid
    logic [INT_ADC_DATA_CH1_WIDTH_TRIMMED-1:0] adc_i_data_ch2;
    logic [INT_ADC_DATA_CH1_WIDTH_TRIMMED-1:0] adc_o_data_ch2;
    logic adc_i_dready_ch2;       // Destination ready
    logic adc_o_data_valid_ch2;   // Data valid

    // DAC
    logic [INT_ADC_DATA_CH1_WIDTH_TRIMMED-1:0] dac_i_data_ch1;
    logic [INT_ADC_DATA_CH1_WIDTH_TRIMMED-1:0] dac_i_data_ch2;
    (* DONT_TOUCH = "yes" *) logic dac_i_rst;
    logic dac_i_valid_ch1;
    logic dac_i_valid_ch2;

    // DSP
    logic dsp_o_valid;
    logic [INT_DDC_OUT_DATA_WIDTH + $clog2(INT_AVG_MAX_AVERAGE_BY)-1:0] dsp_o_data_i;
    logic [INT_DDC_OUT_DATA_WIDTH + $clog2(INT_AVG_MAX_AVERAGE_BY)-1:0] dsp_o_data_q;

    // MULTIACC
    logic multiacc_o_acc_valid_i;
    assign o_multiacc_o_acc_valid_i = multiacc_o_acc_valid_i;
    logic [INT_MULTIACC_CHANNELS-1:0] multiacc_i_rd_en_channels_i;
    logic [INT_MULTIACC_CHANNELS-1:0] multiacc_o_rd_valid_channels_i;
    logic [INT_MULTIACC_CHANNELS-1:0] [INT_MULTIACC_FIFO_WIDTH-1:0] multiacc_o_rd_data_channels_i;
    logic [INT_MULTIACC_CHANNELS-1:0] multiacc_o_ready_channels_i;
    logic [INT_MULTIACC_CHANNELS-1:0] multiacc_o_empty_channels_i;
    logic [INT_MULTIACC_CHANNELS-1:0] multiacc_o_empty_next_channels_i;
    logic [INT_MULTIACC_CHANNELS-1:0] multiacc_o_full_channels_i;
    logic [INT_MULTIACC_CHANNELS-1:0] multiacc_o_full_next_channels_i;
    logic [INT_MULTIACC_CHANNELS-1:0] [$clog2(INT_MULTIACC_FIFO_DEPTH):0] multiacc_o_fill_count_channels_i;

    logic multiacc_o_acc_valid_q;
    logic [INT_MULTIACC_CHANNELS-1:0] multiacc_i_rd_en_channels_q;
    logic [INT_MULTIACC_CHANNELS-1:0] multiacc_o_rd_valid_channels_q;
    logic [INT_MULTIACC_CHANNELS-1:0] [INT_MULTIACC_FIFO_WIDTH-1:0] multiacc_o_rd_data_channels_q;
    logic [INT_MULTIACC_CHANNELS-1:0] multiacc_o_ready_channels_q;
    logic [INT_MULTIACC_CHANNELS-1:0] multiacc_o_empty_channels_q;
    logic [INT_MULTIACC_CHANNELS-1:0] multiacc_o_empty_next_channels_q;
    logic [INT_MULTIACC_CHANNELS-1:0] multiacc_o_full_channels_q;
    logic [INT_MULTIACC_CHANNELS-1:0] multiacc_o_full_next_channels_q;
    logic [INT_MULTIACC_CHANNELS-1:0] [$clog2(INT_MULTIACC_FIFO_DEPTH):0] multiacc_o_fill_count_channels_q;
    

    // MEMRDSEL
    logic memrdsel_i_rd_en_i;
    logic [$clog2(INT_MULTIACC_CHANNELS)-1:0] memrdsel_i_channel_rd_select_i; // Actual channel selected
    logic [$clog2(INT_MULTIACC_CHANNELS)-1:0] memrdsel_o_channel_rd_select_i;
    logic [INT_MULTIACC_FIFO_WIDTH-1:0] memrdsel_o_rd_data_i;
    logic memrdsel_o_rd_valid_i;
    logic [$clog2(INT_MULTIACC_FIFO_DEPTH):0] memrdsel_o_fill_count_i;

    logic memrdsel_i_rd_en_q;
    logic [$clog2(INT_MULTIACC_CHANNELS)-1:0] memrdsel_i_channel_rd_select_q; // Actual channel selected
    logic [$clog2(INT_MULTIACC_CHANNELS)-1:0] memrdsel_o_channel_rd_select_q;
    logic [INT_MULTIACC_FIFO_WIDTH-1:0] memrdsel_o_rd_data_q;
    logic memrdsel_o_rd_valid_q;
    logic [$clog2(INT_MULTIACC_FIFO_DEPTH):0] memrdsel_o_fill_count_q;


    // MULTI CH RD CTRL aka multichrdctrl
    logic multichrdctrl_cmd_dready_i;
    assign o_multichrdctrl_cmd_dready_i = multichrdctrl_cmd_dready_i;
    logic multichrdctrl_o_single_wr_valid_i;
    logic [INT_MULTIACC_FIFO_WIDTH-1:0] multichrdctrl_o_single_wr_data_i;

    logic multichrdctrl_cmd_dready_q;
    assign o_multichrdctrl_cmd_dready_q = multichrdctrl_cmd_dready_q;
    logic multichrdctrl_o_single_wr_valid_q;
    logic [INT_MULTIACC_FIFO_WIDTH-1:0] multichrdctrl_o_single_wr_data_q;


    // FIFO: DSP i & q
    localparam INT_FIFO_WIDTH = INT_AXIS_DATA_WIDTH;
    logic fifo_wr_ready_ch1;
    logic fifo_wr_ready_ch2;
    logic [INT_FIFO_WIDTH-1:0] data_i_dsp_fifowidth;
    logic [INT_FIFO_WIDTH-1:0] data_q_dsp_fifowidth;
    logic data_i_dsp_fifowidth_valid;
    logic data_q_dsp_fifowidth_valid;

    // FIFO: cmd & cmd data
    logic [INT_AXIS_DATA_WIDTH-1:0] cmd_axi_fifo_o_data;
    logic cmd_axi_fifo_o_data_valid;
    logic cmd_axi_fifo_i_dready;

    logic [INT_AXIS_DATA_WIDTH-1:0] cmddata_axi_fifo_o_data;
    logic cmddata_axi_fifo_o_data_valid;
    logic cmddata_axi_fifo_i_dready;


    // RX Command Parser: Cmd bus pipeline
    logic [INT_MODULES_CMD_CNT-1:0] rxcmd_pipeline_read_valid;
    logic [INT_MODULES_CMD_CNT-1:0] rxcmd_pipeline_write_valid;
    logic [INT_MODULES_CMD_CNT-1:0] [INT_MODULE_SELECT_WIDTH-1:0] rxcmd_pipeline_addr;
    logic [INT_MODULES_CMD_CNT-1:0] [INT_CMD_OUTPUT_WIDTH-1:0] rxcmd_pipeline_cmd;
    logic [INT_MODULES_CMD_CNT-1:0] [INT_AXIS_DATA_WIDTH-1:0] rxcmd_pipeline_data;


    // Triggers
    logic acc_trigger_1_synchronized;
    logic acc_trigger_1_synchronized_posedge;
    logic acc_trigger_2_synchronized;
    logic acc_trigger_2_synchronized_posedge;


    // leds: for debugging
    assign leds[0] = locked_mmcm1; // Clock synthesizer is locked
    assign leds[1] = 1'b0; // Unused
    assign leds[2] = 1'b0; // Unused
    assign leds[3] = adc_o_data_valid_ch1 | adc_o_data_valid_ch2;
    assign leds[4] = 1'b0; // Unused
    assign leds[5] = i_fifo_rd_dready_ch1 | i_fifo_rd_dready_ch2;
    assign leds[6] = ~fifo_wr_ready_ch1; // Full indicator: Ready is asserted if fifo is not full
    assign leds[7] = ~fifo_wr_ready_ch2; // Full indicator: Ready is asserted if fifo is not full



    // -----------------------------------------------------
    // Clock
    // -----------------------------------------------------
    // Clock driver and Differential -> Single-ended converter or Single-ended Clock Buffer

    generate
        if (INT_DIFF_ADC_CLK == 1) begin
            IBUFDS #() inst_adc_clk_ibufds
            (
                .I(in_adc_clk_p),
                .IB(in_adc_clk_n),
                .O(adc_clk_buf)
            );
        end else begin
            BUFG inst_adc_clk_bufg1
            (
                .I(in_adc_clk_p),
                .O(adc_clk_buf)
            );
        end
    endgenerate


    // Clock synthesis: Creates an MMCM component
    // Waveform:
    //          adc_clk:            {0.000 4.000}
    //          mmcm_out_clk[0]:    {2.000 6.000}
    //          mmcm_out_clk[1]:    {2.511 6.511} ... 500 ps delay
    //          mmcm_out_feedback:  {0.000 4.000}
    clock_synthesizer #(
        .REAL_CLKIN1_MHZ(125.0),
        .INT_OUT_CLOCKS(3),
        .INT_VCO_DIVIDE(1),
        .REAL_VCO_MULTIPLY(8.000),
        .REAL_DIVIDE_OUT0(4.000),
        .INT_DIVIDE_OUT1(4),
        .INT_DIVIDE_OUT2(8),
        .REAL_PHASE_OUT0(45.000),
        .REAL_PHASE_OUT1(0.000),
        .REAL_PHASE_OUT2(0.000)
    ) inst_clock_synthesizer1 (
        .in_clk0(adc_clk_buf),       // 125 MHz single-ended
        .in_fineps_clk(),
        .in_fineps_incr(),
        .in_fineps_decr(),
        .in_fineps_valid(),
        .out_fineps_dready(),
        .out_clk0(dac_iqclk_mmcm),    // 125 MHz, Shifted by 90 Deg
        .out_clk1(dac_iqwrt_mmcm),    // 125 MHz, Shifted by 90 Deg + 500 ps delay
        .out_clk2(adc_clk_mmcm),
        .out_clk3(),
        .out_clk4(),
        .out_clk5(),
        .out_clk6(),
        .locked(locked_mmcm1)
    );



    // -----------------------------------------------------
    // Triggers
    // -----------------------------------------------------
    // Instantiate Analog Signal Synchronizer (Pattern Detector): Trigger 1 and 2
    async_patterndetect #(
        .NATURAL_INPUT_IS_INVERTED(0),
        .POSITIVE_DOWNSAMPLING(1),     // 1 = No downsampling
        .POSITIVE_PATTERN_WIDTH(3),    // Record 3 samples into a buffer
        .NATURAL_PATTERN(7),           // 3 samples = 3'b111 = 7 -> out_sync_pattern_present = 1

        // Delay Control
        .STATIC_DELAY_CYCLES(INT_DDC_NUMBER_OF_TAPS
            - 3*1   // POSITIVE_PATTERN_WIDTH * POSITIVE_DOWNSAMPLING
            - 1     // Fine-tune the final (static) delay
        ),
        .VARIABLE_DELAY_CYCLES_1(INT_AVG_MAX_AVERAGE_BY),
        .VARIABLE_DELAY_CYCLES_2(INT_DDC_MAX_DOWNSAMPLING)
    ) inst_async_patterndetect_tr1 (
        .clk(adc_clk_mmcm),
        .in_async_sig(i_acc_trigger_1),
        .out_sync_pattern_present(acc_trigger_1_synchronized),
        .out_sync_pattern_posedge(),
        .out_sync_pattern_negedge(),
        .out_sync_event_posedge(),
        .out_sync_event_negedge(),
        .out_sync_pattern_posedge_delayed(acc_trigger_1_synchronized_posedge),
        .out_sync_pattern_posedge_delayed_latched(),
        .in_sync_pattern_posedge_delayed_latched_pulldown(),

        // Update the delay due to the changes on variables, such as updated INT_DDC_MAX_DOWNSAMPLING
        .in_delay_cycles_1_valid(rxcmd_pipeline_read_valid[2]),
        .in_delay_cycles_1_data(rxcmd_pipeline_data[2][$clog2(INT_AVG_MAX_AVERAGE_BY)-1:0])
        .in_delay_cycles_2_valid(rxcmd_pipeline_read_valid[3]),
        .in_delay_cycles_2_data(rxcmd_pipeline_data[3][$clog2(INT_DDC_MAX_DOWNSAMPLING)-1:0]) // i_deci_cmd_data = 5 means Decimation = 6, thus, one needs to decrement the value by 1; i_deci_cmd_data = 0 is no decimation
    );

    async_patterndetect #(
        .NATURAL_INPUT_IS_INVERTED(0),
        .POSITIVE_DOWNSAMPLING(1),     // 1 = No downsampling
        .POSITIVE_PATTERN_WIDTH(3),    // Record 3 samples into a buffer
        .NATURAL_PATTERN(7),           // 3 samples = 3'b111 = 7 -> out_sync_pattern_present = 1

        // Delay Control
        .STATIC_DELAY_CYCLES(INT_DDC_NUMBER_OF_TAPS
            - 3*1   // POSITIVE_PATTERN_WIDTH * POSITIVE_DOWNSAMPLING
            - 1     // Fine-tune the final (static) delay
        ),
        .VARIABLE_DELAY_CYCLES_1(INT_AVG_MAX_AVERAGE_BY),  // Added to STATIC_DELAY_CYCLES, Set (Maximal & Initial) Delay Value after device programming - can be changed by in_update_variable_delay_cycles_X port
        .VARIABLE_DELAY_CYCLES_2(INT_DDC_MAX_DOWNSAMPLING) // Added to STATIC_DELAY_CYCLES, Set (Maximal & Initial) Delay Value after device programming - can be changed by in_update_variable_delay_cycles_X port
    ) inst_async_patterndetect_tr2 (
        .clk(adc_clk_mmcm),
        .in_async_sig(i_acc_trigger_2),
        .out_sync_pattern_present(acc_trigger_2_synchronized),
        .out_sync_pattern_posedge(),
        .out_sync_pattern_negedge(),
        .out_sync_event_posedge(acc_trigger_2_synchronized_posedge),
        .out_sync_event_negedge(),
        .out_sync_pattern_posedge_delayed(),
        .out_sync_pattern_posedge_delayed_latched(),
        .in_sync_pattern_posedge_delayed_latched_pulldown(),

        // Update the delay due to the changes on variables, such as updated INT_DDC_MAX_DOWNSAMPLING
        .in_update_variable_delay_cycles_1_valid(rxcmd_pipeline_read_valid[2]),
        .in_update_variable_delay_cycles_1_data(rxcmd_pipeline_data[2][$clog2(INT_AVG_MAX_AVERAGE_BY)-1:0])
        .in_update_variable_delay_cycles_2_valid(rxcmd_pipeline_read_valid[3]),
        .in_update_variable_delay_cycles_2_data(rxcmd_pipeline_data[3][$clog2(INT_DDC_MAX_DOWNSAMPLING)-1:0]) // i_deci_cmd_data = 5 means Decimation = 6, thus, one needs to decrement the value by 1; i_deci_cmd_data = 0 is no decimation
    );



    // -----------------------------------------------------
    // ADC
    // -----------------------------------------------------
    // ADC Core Instantiation: Channel 1, 2; Enable Clock Cycle Stabilizer
    assign adc_i_clkstb = 1'b1;
    assign adc_i_data_ch1 = in_data_ch1[INT_ADC_DATA_CH1_WIDTH-1:INT_ADC_DATA_CH1_TRIM_BITS_RIGHT];
    adc_read #(
        .INT_ADC_DATA_WIDTH(INT_ADC_DATA_CH1_WIDTH_TRIMMED),
        .INT_ADC_DATA_IS_INVERTED(1), // 1 If RF ADC gives inverted values
        .INT_IDATA_ENC_OFFSETBIN(1),  // 1 If input ADC data is encoded in 'Offset Binary', else 0
        .INT_IDATA_ENC_TWOSCOMPL(0),  // 1 If input ADC data is encoded in 'Two's Complement', else 0
        .INT_ODATA_ENC_OFFSETBIN(0),  // 1 To convert data into 'Offset Binary' encoding, else 0
        .INT_ODATA_ENC_TWOSCOMPL(1)  
    ) inst_adc_read_ch1 (
        .in_clk(adc_clk_mmcm),
        .in_data(adc_i_data_ch1),
        .in_dready(adc_i_dready_ch1),

        .out_data(adc_o_data_ch1),
        .out_valid(adc_o_data_valid_ch1)
    );

    assign adc_i_data_ch2 = in_data_ch2[INT_ADC_DATA_CH2_WIDTH-1:INT_ADC_DATA_CH2_TRIM_BITS_RIGHT];
    adc_read #(
        .INT_ADC_DATA_WIDTH(INT_ADC_DATA_CH2_WIDTH_TRIMMED),
        .INT_ADC_DATA_IS_INVERTED(1), // 1 If RF ADC gives inverted values
        .INT_IDATA_ENC_OFFSETBIN(1),  // 1 If input ADC data is encoded in 'Offset Binary', else 0
        .INT_IDATA_ENC_TWOSCOMPL(0),  // 1 If input ADC data is encoded in 'Two's Complement', else 0
        .INT_ODATA_ENC_OFFSETBIN(0),  // 1 To convert data into 'Offset Binary' encoding, else 0
        .INT_ODATA_ENC_TWOSCOMPL(1)
    ) inst_adc_read_ch2 (
        .in_clk(adc_clk_mmcm),
        .in_data(adc_i_data_ch2),
        .in_dready(adc_i_dready_ch2),

        .out_data(adc_o_data_ch2),
        .out_valid(adc_o_data_valid_ch2)
    );



    // -----------------------------------------------------
    // DSP
    // -----------------------------------------------------
    // Instantiate the DSP Path
    dsp_path #(
        // DDC
        .INT_DDC_NUMBER_OF_TAPS(INT_DDC_NUMBER_OF_TAPS),                // Max FIR Order + 1
        .INT_DDC_MAX_DOWNSAMPLING(INT_DDC_MAX_DOWNSAMPLING),                    // The decimation value
        .INT_DDC_COEF_WIDTH(INT_DDC_COEF_WIDTH),                        // Width of each FIR coefficient
        .REAL_DDC_LOCOSC_IN_FREQ_MHZ(REAL_DDC_LOCOSC_IN_FREQ_MHZ),      // Clock frequency the local oscillator is running on
        .REAL_DDC_LOCOSC_OUT_FREQ_MHZ(REAL_DDC_LOCOSC_OUT_FREQ_MHZ),    // The desired frequency of the local oscillator (sine + cosine)
        .INT_DDC_IN_DATA_WIDTH(INT_ADC_DATA_CH1_WIDTH_TRIMMED),                     // 
        .INT_DDC_OUT_DATA_WIDTH(INT_DDC_OUT_DATA_WIDTH),                // Output data width of the digital downconversion

        // Integration & averaging
        .INT_MAX_AVERAGE_BY(INT_AVG_MAX_AVERAGE_BY),   // Enter the number of how many data points are to be averaged
        .INT_AVG_DIVISOR_WIDTH(INT_AVG_DIVISOR_WIDTH)      // Set the resolution of the divisor. Config INT_IN_DATA_WIDTH=14 & INT_DIVISOR_WIDTH=28 (total 42 bits) implements 1x DSP block for the division
    ) inst_dsp_path (
        // Inputs
        .clk(adc_clk_mmcm),
        .rst(1'b0),
        .i_data(adc_o_data_ch1),
        .i_valid(adc_o_data_valid_ch1),

        // Ports to configure modules inside
        //    DOWNSAMPLING
        .i_deci_cmd_valid(rxcmd_pipeline_read_valid[3]),
        .i_deci_cmd_data(rxcmd_pipeline_data[3][$clog2(INT_DDC_MAX_DOWNSAMPLING)-1:0]), // i_deci_cmd_data = 5 means Decimation = 6, thus, one needs to decrement the value by 1; i_deci_cmd_data = 0 is no decimation

        //    FIR
        .i_fir_cmd_valid(rxcmd_pipeline_read_valid[1]),
        .i_fir_cmd_coeffsel(rxcmd_pipeline_cmd[1][$clog2(INT_DDC_NUMBER_OF_TAPS)-1:0]),
        .i_fir_cmd_data(rxcmd_pipeline_data[1][INT_DDC_COEF_WIDTH-1:0]),

        //    Averager
        .i_avg_cmd_valid(rxcmd_pipeline_read_valid[2]),
        .i_avg_cmd_data(rxcmd_pipeline_data[2][$clog2(INT_AVG_MAX_AVERAGE_BY)-1:0]),

        // Outputs
        .o_data_i(dsp_o_data_i),
        .o_data_q(dsp_o_data_q),
        .o_valid(dsp_o_valid)
    );

    // DSP Bypass Control
    generate
        // ADC Ch1 -> DAC Ch1 IQ Passthrough
        assign adc_i_dready_ch1 = 1'b1; // Channel 1 accept data trigger
        assign dac_i_data_ch1 = adc_o_data_ch1; // Passthrough
        assign dac_i_valid_ch1 = adc_o_data_valid_ch1;

        // ADC Ch2 -> DAC Ch1 IQ Passthrough
        assign adc_i_dready_ch2 = 1'b1; // Channel 1 accept data trigger
        assign dac_i_data_ch2 = adc_o_data_ch2; // Passthrough
        assign dac_i_valid_ch2 = adc_o_data_valid_ch2;

        if (INT_BYPASS_DSP == 1) begin
            assign data_i_dsp_fifowidth[INT_FIFO_WIDTH-1:INT_ADC_DATA_CH1_WIDTH_TRIMMED] = 0;
            assign data_i_dsp_fifowidth[INT_ADC_DATA_CH1_WIDTH_TRIMMED-1:0] = adc_o_data_ch1;
            assign data_i_dsp_fifowidth_valid = adc_o_data_valid_ch1;

            assign data_q_dsp_fifowidth[INT_FIFO_WIDTH-1:INT_ADC_DATA_CH1_WIDTH_TRIMMED] = 0;
            assign data_q_dsp_fifowidth[INT_ADC_DATA_CH1_WIDTH_TRIMMED-1:0] = adc_o_data_ch2;
            assign data_q_dsp_fifowidth_valid = adc_o_data_valid_ch2;
        end

        if (INT_BYPASS_DSP == 0) begin
            assign data_i_dsp_fifowidth[INT_FIFO_WIDTH-1:INT_DDC_OUT_DATA_WIDTH + $clog2(INT_AVG_MAX_AVERAGE_BY)] = 0; // possible correction
            assign data_i_dsp_fifowidth[INT_DDC_OUT_DATA_WIDTH + $clog2(INT_AVG_MAX_AVERAGE_BY)-1:0] = dsp_o_data_i;
            assign data_i_dsp_fifowidth_valid = dsp_o_valid;

            assign data_q_dsp_fifowidth[INT_FIFO_WIDTH-1:INT_DDC_OUT_DATA_WIDTH + $clog2(INT_AVG_MAX_AVERAGE_BY)] = 0; // possible correction
            assign data_q_dsp_fifowidth[INT_DDC_OUT_DATA_WIDTH + $clog2(INT_AVG_MAX_AVERAGE_BY)-1:0] = dsp_o_data_q;
            assign data_q_dsp_fifowidth_valid = dsp_o_valid;
        end

    endgenerate


    // Instantiate the multichannel accumulator
    fifo_accumulator #(
        .CHANNEL_WIDTH(INT_MULTIACC_FIFO_WIDTH),
        .CHANNEL_DEPTH(INT_MULTIACC_FIFO_DEPTH),
        .CHANNELS_CNT(INT_MULTIACC_CHANNELS),
        .CHANNEL_ACC_ROUNDS(INT_MULTIACC_REPETITIONS)
    ) inst_fifo_accumulator_i (
        .clk(adc_clk_mmcm),
        .i_rst(1'b0),

        // Write port (of the respective FIFO channel)
        .i_acc_trigger(acc_trigger_1_synchronized_posedge), // TO BE DELAYED?
        .i_data_valid(data_i_dsp_fifowidth_valid),
        .i_data(data_i_dsp_fifowidth),

        .o_acc_valid(multiacc_o_acc_valid_i),

        // Read port (of all FIFO channels)
        .i_rd_en_channels(multiacc_i_rd_en_channels_i),
        .o_rd_valid_channels(multiacc_o_rd_valid_channels_i),
        .o_rd_data_channels(multiacc_o_rd_data_channels_i),
        .o_ready_channels(multiacc_o_ready_channels_i),
        .o_empty_channels(multiacc_o_empty_channels_i),
        .o_empty_next_channels(multiacc_o_empty_next_channels_i),
        .o_full_channels(multiacc_o_full_channels_i),
        .o_full_next_channels(multiacc_o_full_next_channels_i),

        // The number of elements in the FIFO (of the respective FIFO channel)
        .o_fill_count_channels(multiacc_o_fill_count_channels_i)
    );

    fifo_accumulator #(
        .CHANNEL_WIDTH(INT_MULTIACC_FIFO_WIDTH),
        .CHANNEL_DEPTH(INT_MULTIACC_FIFO_DEPTH),
        .CHANNELS_CNT(INT_MULTIACC_CHANNELS),
        .CHANNEL_ACC_ROUNDS(INT_MULTIACC_REPETITIONS)
    ) inst_fifo_accumulator_q (
        .clk(adc_clk_mmcm),
        .i_rst(1'b0),

        // Write port (of the respective FIFO channel)
        .i_acc_trigger(acc_trigger_1_synchronized_posedge), // TO BE DELAYED?
        .i_data_valid(data_q_dsp_fifowidth_valid),
        .i_data(data_q_dsp_fifowidth),

        .o_acc_valid(multiacc_o_acc_valid_q),

        // Read port (of all FIFO channels)
        .i_rd_en_channels(multiacc_i_rd_en_channels_q),
        .o_rd_valid_channels(multiacc_o_rd_valid_channels_q),
        .o_rd_data_channels(multiacc_o_rd_data_channels_q),
        .o_ready_channels(multiacc_o_ready_channels_q),
        .o_empty_channels(multiacc_o_empty_channels_q),
        .o_empty_next_channels(multiacc_o_empty_next_channels_q),
        .o_full_channels(multiacc_o_full_channels_q),
        .o_full_next_channels(multiacc_o_full_next_channels_q),

        // The number of elements in the FIFO (of the respective FIFO channel)
        .o_fill_count_channels(multiacc_o_fill_count_channels_q)
    );



    // -----------------------------------------------------
    // Accumulator Readout
    // -----------------------------------------------------
    // FIFO Read Selector
    fifo_rdselector #(
        .CHANNEL_WIDTH(INT_MULTIACC_FIFO_WIDTH),
        .CHANNEL_DEPTH(INT_MULTIACC_FIFO_DEPTH),
        .CHANNELS_CNT(INT_MULTIACC_CHANNELS)
    ) inst_fifo_rdselector_i (
        .clk(adc_clk_mmcm),
        .rst(1'b0),

        // Read port
        .i_rd_en(memrdsel_i_rd_en_i), // 1 CLK long pulse
        .i_channel_rd_select(memrdsel_i_channel_rd_select_i), // Must be used to retreive data from the desired channel, then read the data

        .o_channel_rd_select(memrdsel_o_channel_rd_select_i), // Actual channel selected
        .o_rd_data(memrdsel_o_rd_data_i),
        .o_rd_valid(memrdsel_o_rd_valid_i),
        .o_fill_count(memrdsel_o_fill_count_i),

        // Multichannel FIFO Signals (source)
        .i_rd_data_channels(multiacc_o_rd_data_channels_i),   // No delay
        .o_rd_en_channels(multiacc_i_rd_en_channels_i),
        .i_rd_valid_channels(multiacc_o_rd_valid_channels_i), // ~empty_next & ~empty;
        .i_ready_channels(multiacc_o_ready_channels_i),       // ~full;
        .i_empty_channels(multiacc_o_empty_channels_i),
        .i_empty_next_channels(multiacc_o_empty_next_channels_i),
        .i_full_channels(multiacc_o_full_channels_i),
        .i_full_next_channels(multiacc_o_full_next_channels_i),

        .i_fill_count_channels(multiacc_o_fill_count_channels_i),

        // Passthrough FIFO flags
        .o_rd_valid_channels(), // ~empty_next & ~empty;
        .o_ready_channels(),       // ~full;
        .o_empty_channels(),
        .o_empty_next_channels(),
        .o_full_channels(),
        .o_full_next_channels(),

        .o_fill_count_channels()
    );

    fifo_rdselector #(
        .CHANNEL_WIDTH(INT_MULTIACC_FIFO_WIDTH),
        .CHANNEL_DEPTH(INT_MULTIACC_FIFO_DEPTH),
        .CHANNELS_CNT(INT_MULTIACC_CHANNELS)
    ) inst_fifo_rdselector_q (
        .clk(adc_clk_mmcm),
        .rst(1'b0),

        // Read port
        .i_rd_en(memrdsel_i_rd_en_q), // 1 CLK
        .i_channel_rd_select(memrdsel_i_channel_rd_select_q), // Must be used to retreive data from the desired channel, then read the data

        .o_channel_rd_select(memrdsel_o_channel_rd_select_q), // Actual channel selected
        .o_rd_data(memrdsel_o_rd_data_q),
        .o_rd_valid(memrdsel_o_rd_valid_q),
        .o_fill_count(memrdsel_o_fill_count_q),

        // Multichannel FIFO Signals (source)
        .i_rd_data_channels(multiacc_o_rd_data_channels_q),   // No delay
        .o_rd_en_channels(multiacc_i_rd_en_channels_q),
        .i_rd_valid_channels(multiacc_o_rd_valid_channels_q), // ~empty_next & ~empty;
        .i_ready_channels(multiacc_o_ready_channels_q),       // ~full;
        .i_empty_channels(multiacc_o_empty_channels_q),
        .i_empty_next_channels(multiacc_o_empty_next_channels_q),
        .i_full_channels(multiacc_o_full_channels_q),
        .i_full_next_channels(multiacc_o_full_next_channels_q),

        .i_fill_count_channels(multiacc_o_fill_count_channels_q),

        // Passthrough FIFO flags
        .o_rd_valid_channels(), // ~empty_next & ~empty;
        .o_ready_channels(),       // ~full;
        .o_empty_channels(),
        .o_empty_next_channels(),
        .o_full_channels(),
        .o_full_next_channels(),

        .o_fill_count_channels()
    );


    // To send transfer sizes from multichannel fifo to singlechannel CDCC bffer
    fifo_multichrdctrl #(
        .CHANNEL_WIDTH(INT_MULTIACC_FIFO_WIDTH),
        .RD_CHANNEL_CNT(INT_MULTIACC_CHANNELS),
        .RD_CHANNEL_DEPTH(INT_MULTIACC_FIFO_DEPTH),
        .RD_DELAY_CYCLES(5) // Waits for data to update, slows down read
    ) inst_fifo_multichrdctrl_buffer1 (
        .clk(adc_clk_mmcm),
        .rst(1'b0), // No logic for reset present
        .i_cmd_valid(rxcmd_pipeline_read_valid[0] | rxcmd_pipeline_write_valid[0]),
        .i_cmd_rdchsel(rxcmd_pipeline_cmd[0][$clog2(INT_MULTIACC_CHANNELS)-1:0]),
        .i_cmd_rdcnt(rxcmd_pipeline_data[0][$clog2(INT_MULTIACC_FIFO_DEPTH):0]),
        .o_cmd_ready(multichrdctrl_cmd_dready_i), // Can be ignored - indicates when busy and ready to accept new cmd; new cmd will override the ongoing one
        .o_multichannel_rd_en(memrdsel_i_rd_en_i),
        .i_multichannel_rd_select(memrdsel_o_channel_rd_select_i), // Selected channel in memrdsel
        .o_multichannel_rd_select(memrdsel_i_channel_rd_select_i), // Selected channel in multichrdctrl
        // TODO: Add the "o_channel_rd_select" port and logic
        .i_multichannel_rd_valid(memrdsel_o_rd_valid_i),
        .i_multichannel_rd_data(memrdsel_o_rd_data_i),
        .o_singlechannel_wr_valid(multichrdctrl_o_single_wr_valid_i),
        .o_singlechannel_wr_data(multichrdctrl_o_single_wr_data_i),
        .i_singlechannel_wr_dready(fifo_wr_ready_ch1)
    );

    // To send transfer sizes from multichannel fifo to singlechannel CDCC bffer
    fifo_multichrdctrl #(
        .CHANNEL_WIDTH(INT_MULTIACC_FIFO_WIDTH),
        .RD_CHANNEL_CNT(INT_MULTIACC_CHANNELS),
        .RD_CHANNEL_DEPTH(INT_MULTIACC_FIFO_DEPTH),
        .RD_DELAY_CYCLES(5) // Waits for data to update, slows down read
    ) inst_fifo_multichrdctrl_buffer2 (
        .clk(adc_clk_mmcm),
        .rst(1'b0), // No logic for reset present
        .i_cmd_valid(rxcmd_pipeline_read_valid[0] | rxcmd_pipeline_write_valid[0]),
        .i_cmd_rdchsel(rxcmd_pipeline_cmd[0][$clog2(INT_MULTIACC_CHANNELS)-1:0]),
        .i_cmd_rdcnt(rxcmd_pipeline_data[0][$clog2(INT_MULTIACC_FIFO_DEPTH):0]),
        .o_cmd_ready(multichrdctrl_cmd_dready_q), // Can be ignored - indicates when busy and ready to accept new cmd; new cmd will override the ongoing one
        .o_multichannel_rd_en(memrdsel_i_rd_en_q),
        .i_multichannel_rd_select(memrdsel_o_channel_rd_select_q), // Selected channel in memrdsel
        .o_multichannel_rd_select(memrdsel_i_channel_rd_select_q), // Selected channel in multichrdctrl
        // TODO: Add the "o_channel_rd_select" port and logic
        .i_multichannel_rd_valid(memrdsel_o_rd_valid_q),
        .i_multichannel_rd_data(memrdsel_o_rd_data_q),
        .o_singlechannel_wr_valid(multichrdctrl_o_single_wr_valid_q),
        .o_singlechannel_wr_data(multichrdctrl_o_single_wr_data_q),
        .i_singlechannel_wr_dready(fifo_wr_ready_ch2)
    );



    // -----------------------------------------------------
    // Control
    // -----------------------------------------------------
    // FIFO Command Parser
    fsm_rxcmdparser #(
        .FIFO_DATA_WIDTH(INT_AXIS_DATA_WIDTH),
        .FIFO_CMD_WIDTH(INT_AXIS_DATA_WIDTH),
        .CMD_OUTPUT_WIDTH(INT_CMD_OUTPUT_WIDTH),
        .MODULE_SELECT_WIDTH(INT_MODULE_SELECT_WIDTH),
        .MODULES_CNT(INT_MODULES_CMD_CNT)
    ) inst_fsm_rxcmdparser (
        .clk(adc_clk_mmcm),
        .rst(1'b0),

        // Cmd FIFO
        .i_cmd(cmd_axi_fifo_o_data),
        .i_cmd_valid(cmd_axi_fifo_o_data_valid),
        .o_cmd_rd_en(cmd_axi_fifo_i_dready),

        // Data FIFO
        .i_data(cmddata_axi_fifo_o_data),
        .i_data_valid(cmddata_axi_fifo_o_data_valid),
        .o_data_rd_en(cmddata_axi_fifo_i_dready),

        // Outputs
        .o_pipeline_read_valid(rxcmd_pipeline_read_valid),   // Performs no set operation
        .o_pipeline_write_valid(rxcmd_pipeline_write_valid), // Performs set operation - updates a register
        .o_pipeline_addr(rxcmd_pipeline_addr),
        .o_pipeline_cmd(rxcmd_pipeline_cmd),
        .o_pipeline_data(rxcmd_pipeline_data)
    );




    // -----------------------------------------------------
    // Cross-Domain FIFOs
    // -----------------------------------------------------
    // RX Command FIFO
    fifo_cdcc #(
        .INT_FIFO_WIDTH(INT_AXIS_DATA_WIDTH),
        .INT_FIFO_DEPTH(1024) // Must be a multiple of 2 (because of Gray counter width)
    ) inst_fifo_cdcc_cmd (
        // Write Signals: in axi
        .wr_clk(aclk),
        .wr_rst(1'b0),

        // Read Signals: in fpga
        .rd_clk(adc_clk_mmcm),
        .rd_rst(1'b0),

        // AXI Input Ports
        .i_data(i_cmd_axi_fifo_i_data),
        .i_valid(i_cmd_axi_fifo_i_valid),
        .o_ready(o_cmd_axi_fifo_o_ready),    // This module ready

        // AXI Output Ports
        .o_data(cmd_axi_fifo_o_data),
        .o_data_valid(cmd_axi_fifo_o_data_valid),
        .i_dready(cmd_axi_fifo_i_dready)    // Destinantion ready
    );

    // RX Command Data FIFO
    fifo_cdcc #(
        .INT_FIFO_WIDTH(INT_AXIS_DATA_WIDTH),
        .INT_FIFO_DEPTH(1024) // Must be a multiple of 2 (because of Gray counter width)
    ) inst_fifo_cdcc_cmddata (
        // Write Signals: in axi
        .wr_clk(aclk),
        .wr_rst(1'b0),

        // Read Signals: in fpga
        .rd_clk(adc_clk_mmcm),
        .rd_rst(1'b0),

        // AXI Input Ports
        .i_data(i_cmddata_axi_fifo_i_data),
        .i_valid(i_cmddata_axi_fifo_i_valid),
        .o_ready(o_cmddata_axi_fifo_o_ready),    // This module ready

        // AXI Output Ports
        .o_data(cmddata_axi_fifo_o_data),
        .o_data_valid(cmddata_axi_fifo_o_data_valid),
        .i_dready(cmddata_axi_fifo_i_dready)    // Destinantion ready
    );





    // // In-phase Asynchronous CDCC FIFO
    // fifo_cdcc #(
    //     .INT_FIFO_WIDTH(INT_FIFO_WIDTH),
    //     .INT_FIFO_DEPTH(INT_FIFO_DEPTH) // Must be a multiple of 2 (because of Gray counter width)
    // ) inst_fifo_cdcc_i (
    //     // Write Signals
    //     .wr_clk(adc_clk_buf),
    //     .wr_rst(dac_i_rst),

    //     // Read Signals
    //     .rd_clk(aclk),
    //     .rd_rst(1'b0),

    //     // AXI Input Ports
    //     .i_data(data_i_dsp_fifowidth),
    //     .i_valid(data_i_dsp_fifowidth_valid),
    //     .o_ready(fifo_wr_ready_ch1),    // This module ready

    //     // AXI Output Ports
    //     .o_data(o_fifo_data_ch1),
    //     .o_data_valid(o_fifo_data_ch1_valid),
    //     .i_dready(i_fifo_rd_dready_ch1)    // Destinantion ready
    // );

    // // Quadrature Asynchronous CDCC FIFO
    // fifo_cdcc #(
    //     .INT_FIFO_WIDTH(INT_FIFO_WIDTH),
    //     .INT_FIFO_DEPTH(INT_FIFO_DEPTH) // Must be a multiple of 2 (because of Gray counter width)
    // ) inst_fifo_cdcc_q (
    //     // Write Signals
    //     .wr_clk(adc_clk_buf),
    //     .wr_rst(dac_i_rst),

    //     // Read Signals
    //     .rd_clk(aclk),
    //     .rd_rst(1'b0),

    //     // AXI Input Ports
    //     .i_data(data_q_dsp_fifowidth),
    //     .i_valid(data_q_dsp_fifowidth_valid),
    //     .o_ready(fifo_wr_ready_ch2),    // This module ready

    //     // AXI Output Ports
    //     .o_data(o_fifo_data_ch2),
    //     .o_data_valid(o_fifo_data_ch2_valid),
    //     .i_dready(i_fifo_rd_dready_ch2)    // Destinantion ready
    // );


    // CDCC FIFO Buffer 1
    fifo_cdcc #(
        .INT_FIFO_WIDTH(INT_FIFO_WIDTH),
        .INT_FIFO_DEPTH(INT_OUT_FIFO_BUFFER1_DEPTH) // Must be a multiple of 2 (because of Gray counter width)
    ) inst_fifo_cdcc_buffer1 (
        // Write Signals
        .wr_clk(adc_clk_mmcm),
        .wr_rst(1'b0),

        // Read Signals
        .rd_clk(aclk),
        .rd_rst(1'b0),

        // AXI Input Ports
        .i_data(multichrdctrl_o_single_wr_data_i),  // TODO
        .i_valid(multichrdctrl_o_single_wr_valid_i), // TODO
        .o_ready(fifo_wr_ready_ch1),    // This module ready

        // AXI Output Ports
        .o_data(o_fifo_data_ch1),
        .o_data_valid(o_fifo_data_ch1_valid),
        .i_dready(i_fifo_rd_dready_ch1)    // Destinantion ready
    );

    // CDCC FIFO Buffer 2
    fifo_cdcc #(
        .INT_FIFO_WIDTH(INT_FIFO_WIDTH),
        .INT_FIFO_DEPTH(INT_OUT_FIFO_BUFFER2_DEPTH) // Must be a multiple of 2 (because of Gray counter width)
    ) inst_fifo_cdcc_buffer2 (
        // Write Signals
        .wr_clk(adc_clk_mmcm),
        .wr_rst(1'b0),

        // Read Signals
        .rd_clk(aclk),
        .rd_rst(1'b0),

        // AXI Input Ports
        .i_data(multichrdctrl_o_single_wr_data_q),  // TODO
        .i_valid(multichrdctrl_o_single_wr_valid_q), // TODO
        .o_ready(fifo_wr_ready_ch2),    // This module ready

        // AXI Output Ports
        .o_data(o_fifo_data_ch2),
        .o_data_valid(o_fifo_data_ch2_valid),
        .i_dready(i_fifo_rd_dready_ch2)    // Destinantion ready
    );



    // -----------------------------------------------------
    // DAC AD976XASTZ
    // -----------------------------------------------------
    // [DRC AVAL-139] Phase shift check: The MMCME2_ADV cell 
    // inst_clock_synthesizer/MMCME2_ADV_inst has a CLKOUT1_PHASE value (113.000)  
    // with CLKOUT1_USE_FINE_PS set to FALSE. 
    // It should be a multiple of [45 / CLKOUT1_DIVIDE] = [45 / 9] = 5.000.
    // DAC reset (active high)
    assign dac_i_rst = 1'b0;
    dac_dual_iq #(
        .INT_DAC_DATA_WIDTH(INT_DAC_DATA_CH1_WIDTH),
        .INT_INVERT_ODATA(0),         // 1 to invert data values to be sent to DAC, else 0
        .INT_IDATA_ENC_OFFSETBIN(0),  // 1 If input DAC data is encoded in 'Offset Binary', else 0
        .INT_IDATA_ENC_TWOSCOMPL(1),  // 1 If input DAC data is encoded in 'Two's Complement', else 0
        .INT_ODATA_ENC_OFFSETBIN(1),  // 1 To convert data into 'Offset Binary' encoding, else 0
        .INT_ODATA_ENC_TWOSCOMPL(0)   // 1 To convert data into 'Two's Complement' encoding, else 0
    ) inst_dac_dual_iq (
        .in_clk_data(adc_clk_mmcm),
        .in_clk_iqclk(dac_iqclk_mmcm),
        .in_clk_iqwrt(dac_iqwrt_mmcm),
        .in_dac_data_ch1(dac_i_data_ch1),
        .in_dac_data_ch2(dac_i_data_ch2),
        .in_dac_rst(dac_i_rst),
        .in_valid_ch1(dac_i_valid_ch1),
        .in_valid_ch2(dac_i_valid_ch2),
        .out_dac_data(dac_o_data),
        .out_iqclk(dac_o_iqclk),
        .out_iqrst(dac_o_iqrst),
        .out_iqwrt(dac_o_iqwrt),
        .out_iqsel(dac_o_iqsel),
        .out_ready(dac_o_ready),
        .out_valid_ch1(dac_o_valid_ch1),    // For Simulation only
        .out_valid_ch2(dac_o_valid_ch2)     // For Simulation only
    );

endmodule