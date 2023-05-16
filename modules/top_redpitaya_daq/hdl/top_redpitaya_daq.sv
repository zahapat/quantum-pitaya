// To set parameters to set up this core according to your
// specifications, it is possible to use the "mmcm_analysis.py"
// script. This script will generate set of parameters to set
// up this core as possible to your output clock requirements

`timescale 1 ns / 1 ps

module top_redpitaya_daq
    #(
        int unsigned INT_DSP_BYPASS = 1'b1,
        int unsigned INT_ADC_CHANNELS = 2,
        int unsigned INT_DAC_CHANNELS = 2,
        int unsigned INT_DATA_CH1_WIDTH = 10,
        int unsigned INT_DATA_CH2_WIDTH = 10,
        int unsigned INT_OUT_DATA_CH1_WIDTH = 10,
        int unsigned INT_OUT_DATA_CH2_WIDTH = 10,
        int unsigned INT_AXIS_DATA_WIDTH = 32
    )(
        // // Essential Component: Processing System 7Series
        // inout logic[54-1:0] FIXED_IO_mio,
        // inout logic FIXED_IO_ps_clk,
        // inout logic FIXED_IO_ps_porb,
        // inout logic FIXED_IO_ps_srstb,
        // inout logic FIXED_IO_ddr_vrn,
        // inout logic FIXED_IO_ddr_vrp,

        // // Essential Component: DDR
        // inout logic[15-1:0] DDR_addr,
        // inout logic[3-1:0] DDR_ba,
        // inout logic DDR_cas_n,
        // inout logic DDR_ck_n,
        // inout logic DDR_ck_p,
        // inout logic DDR_cke,
        // inout logic DDR_cs_n,
        // inout logic[4-1:0] DDR_dm,
        // inout logic[32-1:0] DDR_dq,
        // inout logic[4-1:0] DDR_dqs_n,
        // inout logic[4-1:0] DDR_dqs_p,
        // inout logic DDR_odt,
        // inout logic DDR_ras_n,
        // inout logic DDR_reset_n,
        // inout logic DDR_we_n,

        // Peripheral Inputs
        // input  wire in_adc_clk_p,
        // input  wire in_adc_clk_n,
        input  wire in_adc_clk,
        input  wire[INT_DATA_CH1_WIDTH-1:0] in_data_ch1,
        input  wire[INT_DATA_CH2_WIDTH-1:0] in_data_ch2,

        // Peripheral Outputs
        output wire[INT_OUT_DATA_CH1_WIDTH-1:0] dac_o_data,
        output wire dac_o_iqsel,
        output wire dac_o_iqclk,
        output wire dac_o_iqwrt,
        output wire dac_o_iqrst,
        output wire adc_i_clkstb,

        output wire[8-1:0] leds,

        // output wire dac_o_ready,
        // output wire dac_o_valid_ch1,
        // output wire dac_o_valid_ch2

        // AXI4 Lite ports
        input wire aclk,

        // FIFO read ctrl
        output wire[INT_DATA_CH1_WIDTH-1:0] o_fifo_data_ch1,
        output wire o_fifo_data_ch1_valid,
        input wire i_fifo_rd_dready
);

    // Declare Constants


    // Declare Signals
    // Clock
    wire adc_clk_bufg;
    wire dac_iqclk_mmcm;
    wire dac_iqwrt_mmcm;
    wire locked_mmcm;

    // ADC Channel 1,2
    wire [INT_DATA_CH1_WIDTH-1:0] adc_i_data_ch1;
    wire [INT_DATA_CH1_WIDTH-1:0] adc_o_data_ch1;
    wire adc_i_dready_ch1;       // Destination ready
    wire adc_o_data_valid_ch1;   // Data valid
    wire [INT_DATA_CH1_WIDTH-1:0] adc_i_data_ch2;
    wire [INT_DATA_CH1_WIDTH-1:0] adc_o_data_ch2;
    wire adc_i_dready_ch2;       // Destination ready
    wire adc_o_data_valid_ch2;   // Data valid

    // DAC
    wire [INT_DATA_CH1_WIDTH-1:0] dac_i_data_ch1;
    wire [INT_DATA_CH1_WIDTH-1:0] dac_i_data_ch2;

    wire dac_i_clk_data;
    wire dac_i_clk_iqclk;
    wire dac_i_clk_iqwrt;
    (* DONT_TOUCH = "yes" *) wire dac_i_rst;
    wire dac_i_valid_ch1;
    wire dac_i_valid_ch2;

    // FIFO
    wire fifo_wr_ready;

    // DSP Control
    (* DONT_TOUCH = "yes" *) wire dsp_o_rst;


    // leds: for debugging
    assign leds[0] = 1'b1;
    assign leds[1] = 1'b0;
    assign leds[2] = locked_mmcm;
    assign leds[3] = 1'b0;
    assign leds[4] = adc_o_data_valid_ch1;
    assign leds[5] = 1'b0;
    assign leds[6] = ~fifo_wr_ready; // Full indicator: Ready is asserted if fifo is not full
    assign leds[7] = 1'b0;


    // Clock driver and Differential -> Single-ended converter
    // IBUFDS #() inst_adc_clk_ibufds
    // (
    //     .I(in_adc_clk_p),
    //     .IB(in_adc_clk_n),
    //     .O(in_adc_clk)
    // );
    BUFG inst_adc_clk_bufg
    (
        .I(in_adc_clk),
        .O(adc_clk_bufg)
    );

    // Clock synthesis: Creates an MMCM component
    // Waveform:
    //          adc_clk:            {0.000 4.000}
    //          mmcm_out_clk[0]:    {2.000 6.000}
    //          mmcm_out_clk[1]:    {2.511 6.511} ... 500 ps delay
    //          mmcm_out_feedback:  {0.000 4.000}
    clock_synthesizer #(
        .REAL_CLKIN1_MHZ(125.0),
        .INT_OUT_CLOCKS(2),
        .INT_VCO_DIVIDE(1),
        .REAL_VCO_MULTIPLY(8.000),
        .REAL_DIVIDE_OUT0(4.000),
        .INT_DIVIDE_OUT1(4),
        .REAL_PHASE_OUT0(45.000),
        .REAL_PHASE_OUT1(0.000)
    ) inst_clock_synthesizer (
        .in_clk0(adc_clk_bufg),       // 125 MHz
        .out_clk0(dac_iqclk_mmcm),    // 125 MHz, Shifted by 90 Deg
        .out_clk1(dac_iqwrt_mmcm),    // 125 MHz, Shifted by 90 Deg + 500 ps delay
        .out_clk2(),
        .out_clk3(),
        .out_clk4(),
        .out_clk5(),
        .out_clk6(),
        .locked(locked_mmcm)
    );

    // ADC Core Instantiation: Channel 1, 2; Enable Clock Cycle Stabilizer
    assign adc_i_data_ch1 = in_data_ch1;
    assign adc_i_clkstb = 1'b1;
    // adc_read #(
    //     .INT_ADC_DATA_WIDTH(INT_DATA_CH1_WIDTH)
    // ) inst_adc_read_ch1 (
    //     .in_clk(adc_clk_bufg),
    //     .in_data(adc_i_data_ch1),
    //     .in_dready(adc_i_dready_ch1),

    //     .out_data(adc_o_data_ch1),
    //     .out_valid(adc_o_data_valid_ch1)
    // );

    assign adc_i_data_ch2 = in_data_ch2;
    adc_read #(
        .INT_ADC_DATA_WIDTH(INT_DATA_CH2_WIDTH)
    ) inst_adc_read_ch2 (
        .in_clk(adc_clk_bufg),
        .in_data(adc_i_data_ch2),
        .in_dready(adc_i_dready_ch2),

        .out_data(adc_o_data_ch2),
        .out_valid(adc_o_data_valid_ch2)
    );


    // Instantiate the DAQ Control
    // DDR outputs
    // ODDR oddr_dac_clk          (.Q(dac_clk_o), .D1(1'b0     ), .D2(1'b1     ), .C(dac_clk_2p), .CE(1'b1), .R(1'b0   ), .S(1'b0));
    // ODDR oddr_dac_wrt          (.Q(dac_wrt_o), .D1(1'b0     ), .D2(1'b1     ), .C(dac_clk_2x), .CE(1'b1), .R(1'b0   ), .S(1'b0));
    // ODDR oddr_dac_sel          (.Q(dac_sel_o), .D1(1'b1     ), .D2(1'b0     ), .C(dac_clk_1x), .CE(1'b1), .R(dac_rst), .S(1'b0));
    // ODDR oddr_dac_rst          (.Q(dac_rst_o), .D1(dac_rst  ), .D2(dac_rst  ), .C(dac_clk_1x), .CE(1'b1), .R(1'b0   ), .S(1'b0));
    // ODDR oddr_dac_dat [14-1:0] (.Q(dac_dat_o), .D1(dac_dat_b), .D2(dac_dat_a), .C(dac_clk_1x), .CE(1'b1), .R(dac_rst), .S(1'b0));
    // Counters for data emulation
    reg [INT_DATA_CH1_WIDTH-1:0] reg_emul_adc_o_data_ch1 = {{INT_DATA_CH1_WIDTH}{1'b0}};
    reg [INT_DATA_CH1_WIDTH-1:0] reg_emul_adc_o_data_ch2 = {{INT_DATA_CH2_WIDTH}{1'b0}};
    generate
        if (INT_DSP_BYPASS == 1) begin
            always @(posedge adc_clk_bufg) begin
                reg_emul_adc_o_data_ch1 = reg_emul_adc_o_data_ch1 + 1;
                reg_emul_adc_o_data_ch2 = reg_emul_adc_o_data_ch2 + 1;
            end

            // ADC Ch1 -> DAC Ch1 IQ Passthrough
            assign adc_i_dready_ch1 = fifo_wr_ready; // Channel 1 accept data trigger
            // assign dac_i_data_ch1 = adc_o_data_ch1; // Passthrough
            assign dac_i_data_ch1 = reg_emul_adc_o_data_ch1; // Counter
            // assign dac_i_valid_ch1 = adc_o_data_valid_ch1;
            assign adc_o_data_valid_ch1 = 1'b1;
            assign dac_i_valid_ch1 = 1'b1;



            // ADC Ch2 -> DAC Ch1 IQ Passthrough
            assign adc_i_dready_ch2 = fifo_wr_ready; // Channel 1 accept data trigger
            assign dac_i_data_ch2 = adc_o_data_ch2; // Passthrough
            // assign dac_i_data_ch2 = reg_emul_adc_o_data_ch2; // Counter
            assign dac_i_valid_ch2 = adc_o_data_valid_ch2;
            // assign dac_i_valid_ch2 = 1'b1;
        end
    endgenerate


    // DAC AD976XASTZ
    // [DRC AVAL-139] Phase shift check: The MMCME2_ADV cell 
    // inst_clock_synthesizer/MMCME2_ADV_inst has a CLKOUT1_PHASE value (113.000)  
    // with CLKOUT1_USE_FINE_PS set to FALSE. 
    // It should be a multiple of [45 / CLKOUT1_DIVIDE] = [45 / 9] = 5.000.
    // DAC reset (active high)
    // assign dac_i_rst = ~dsp_o_rst | ~locked_mmcm;
    assign dac_i_rst = 1'b0;
    dac_dual_iq #(
        .INT_DAC_DATA_WIDTH(INT_DATA_CH1_WIDTH)
    ) inst_dac_dual_iq (
        .in_clk_data(adc_clk_bufg),
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


    // AXI Asynchronous FIFO
    fifo_cdcc #(
        .INT_FIFO_WIDTH(32),
        .INT_FIFO_DEPTH(1024) // Must be a multiple of 2 (because of Gray counter width)
    ) inst_fifo_cdcc (
        // Write Signals
        .wr_clk(adc_clk_bufg),
        .wr_rst(dac_i_rst),

        // Read Signals
        .rd_clk(aclk),
        .rd_rst(1'b0),

        // AXI Input Ports
        // .i_data(adc_o_data_ch1),
        .i_data(reg_emul_adc_o_data_ch1),
        .i_valid(adc_o_data_valid_ch1),
        .o_ready(fifo_wr_ready),    // This module ready

        // AXI Output Ports
        .o_data(o_fifo_data_ch1),
        .o_data_valid(o_fifo_data_ch1_valid),
        .i_dready(i_fifo_rd_dready)    // Destinantion ready
    );

endmodule