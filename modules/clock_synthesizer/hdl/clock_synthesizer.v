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
        input  wire in_clk0,

        // Outputs
        output wire out_clk0,
        output wire out_clk1,
        output wire out_clk2,
        output wire out_clk3,
        output wire out_clk4,
        output wire out_clk5,
        output wire out_clk6,
        output wire locked
);

    // Constants
    localparam CLKIN1_PERIOD_NS = 1.0/REAL_CLKIN1_MHZ * 1000.0;

    // Signals
    wire mmcm_out_feedback;
    wire mmcm_out_feedback_bufg;
    wire[6:0] mmcm_out_clk;
    wire[INT_OUT_CLOCKS-1:0] mmcm_out_clk_bufg;

    // Place BUFG behind all outputs, including the feedback clock
    BUFG mmcm_out_bufg
    (
        .I(mmcm_out_feedback),
        .O(mmcm_out_feedback_bufg)
    );
    for(genvar i = 0; i < INT_OUT_CLOCKS; i = i + 1) begin
        BUFG mmcm_out_bufg
        (
            .I(mmcm_out_clk[i]),
            .O(mmcm_out_clk_bufg[i])
        );
    end

    generate
        if (INT_OUT_CLOCKS >= 1) assign out_clk0 = mmcm_out_clk_bufg[0];
        if (INT_OUT_CLOCKS >= 2) assign out_clk1 = mmcm_out_clk_bufg[1];
        if (INT_OUT_CLOCKS >= 3) assign out_clk2 = mmcm_out_clk_bufg[2];
        if (INT_OUT_CLOCKS >= 4) assign out_clk3 = mmcm_out_clk_bufg[3];
        if (INT_OUT_CLOCKS >= 5) assign out_clk4 = mmcm_out_clk_bufg[4];
        if (INT_OUT_CLOCKS >= 6) assign out_clk5 = mmcm_out_clk_bufg[5];
        if (INT_OUT_CLOCKS >= 7) assign out_clk6 = mmcm_out_clk_bufg[6];
    endgenerate
    // assign out_clk[INT_OUT_CLOCKS-1:0] = mmcm_out_clk_bufg[INT_OUT_CLOCKS-1:0];

    // MMCME2_ADV: Advanced Mixed Mode Clock Manager
    //             7 Series
    // Xilinx HDL Language Template, version 2021.2
    MMCME2_ADV #(
        .BANDWIDTH("OPTIMIZED"),                     // Jitter programming (OPTIMIZED, HIGH, LOW)
        .CLKFBOUT_MULT_F(REAL_VCO_MULTIPLY),         // Multiply value for all CLKOUT (2.000-64.000).
        .CLKFBOUT_PHASE(0.0),                        // Phase offset in degrees of CLKFB (-360.000-360.000).
                                                    // CLKIN_PERIOD: Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
        .CLKIN1_PERIOD(CLKIN1_PERIOD_NS),
        .CLKIN2_PERIOD(0.0),
                                                    // CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for CLKOUT (1-128)
        .CLKOUT0_DIVIDE_F(REAL_DIVIDE_OUT0),         // Divide amount for CLKOUT0 (1.000-128.000).
        .CLKOUT1_DIVIDE(INT_DIVIDE_OUT1),
        .CLKOUT2_DIVIDE(INT_DIVIDE_OUT2),
        .CLKOUT3_DIVIDE(INT_DIVIDE_OUT3),
        .CLKOUT4_DIVIDE(INT_DIVIDE_OUT4),
        .CLKOUT5_DIVIDE(INT_DIVIDE_OUT5),
        .CLKOUT6_DIVIDE(INT_DIVIDE_OUT6),
                                                    // CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for CLKOUT outputs (0.01-0.99).
        .CLKOUT0_DUTY_CYCLE(REAL_DUTY_OUT0),
        .CLKOUT1_DUTY_CYCLE(REAL_DUTY_OUT1),
        .CLKOUT2_DUTY_CYCLE(REAL_DUTY_OUT2),
        .CLKOUT3_DUTY_CYCLE(REAL_DUTY_OUT3),
        .CLKOUT4_DUTY_CYCLE(REAL_DUTY_OUT4),
        .CLKOUT5_DUTY_CYCLE(REAL_DUTY_OUT5),
        .CLKOUT6_DUTY_CYCLE(REAL_DUTY_OUT6),
                                                    // CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for CLKOUT outputs (-360.000-360.000).
                                                    // Specifies the phase offset in degrees of the clock feedback output. Shifting the feedback clock results in a negative phase shift of all output clocks to the MMCM.
        .CLKOUT0_PHASE(REAL_PHASE_OUT0),
        .CLKOUT1_PHASE(REAL_PHASE_OUT1),
        .CLKOUT2_PHASE(REAL_PHASE_OUT2),
        .CLKOUT3_PHASE(REAL_PHASE_OUT3),
        .CLKOUT4_PHASE(REAL_PHASE_OUT4),
        .CLKOUT5_PHASE(REAL_PHASE_OUT5),
        .CLKOUT6_PHASE(REAL_PHASE_OUT6),
        .CLKOUT4_CASCADE("FALSE"),                   // Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
        .COMPENSATION("ZHOLD"),                      // ZHOLD, BUF_IN, EXTERNAL, INTERNAL
        .DIVCLK_DIVIDE(INT_VCO_DIVIDE),              // Master division value (1-106)
                                                    // REF_JITTER: Reference input jitter in UI (0.000-0.999).
        .REF_JITTER1(0.010),
        .REF_JITTER2(0.010),
        .STARTUP_WAIT("FALSE"),                      // Delays DONE until MMCM is locked (FALSE, TRUE)
                                                    // Spread Spectrum: Spread Spectrum Attributes
        .SS_EN("FALSE"),                             // Enables spread spectrum (FALSE, TRUE)
        .SS_MODE("CENTER_HIGH"),                     // CENTER_HIGH, CENTER_LOW, DOWN_HIGH, DOWN_LOW
        .SS_MOD_PERIOD(10000),                       // Spread spectrum modulation period (ns) (VALUES)
                                                    // USE_FINE_PS: Fine phase shift enable (TRUE/FALSE)
        .CLKFBOUT_USE_FINE_PS("FALSE"),
        .CLKOUT0_USE_FINE_PS("FALSE"),
        .CLKOUT1_USE_FINE_PS("FALSE"),
        .CLKOUT2_USE_FINE_PS("FALSE"),
        .CLKOUT3_USE_FINE_PS("FALSE"),
        .CLKOUT4_USE_FINE_PS("FALSE"),
        .CLKOUT5_USE_FINE_PS("FALSE"),
        .CLKOUT6_USE_FINE_PS("FALSE")
    ) MMCME2_ADV_inst (
                                            // Clock Outputs: 1-bit (each) output: User configurable clock outputs
        .CLKOUT0(mmcm_out_clk[0]),          // 1-bit output: CLKOUT0
        .CLKOUT0B(),                        // 1-bit output: Inverted CLKOUT0
        .CLKOUT1(mmcm_out_clk[1]),          // 1-bit output: CLKOUT1
        .CLKOUT1B(),                        // 1-bit output: Inverted CLKOUT1
        .CLKOUT2(mmcm_out_clk[2]),          // 1-bit output: CLKOUT2
        .CLKOUT2B(),                        // 1-bit output: Inverted CLKOUT2
        .CLKOUT3(mmcm_out_clk[3]),          // 1-bit output: CLKOUT3
        .CLKOUT3B(),                        // 1-bit output: Inverted CLKOUT3
        .CLKOUT4(mmcm_out_clk[4]),          // 1-bit output: CLKOUT4
        .CLKOUT5(mmcm_out_clk[5]),          // 1-bit output: CLKOUT5
        .CLKOUT6(mmcm_out_clk[6]),          // 1-bit output: CLKOUT6
                                            // DRP Ports: 16-bit (each) output: Dynamic reconfiguration ports
        .DO(),                              // 16-bit output: DRP data
        .DRDY(),                            // 1-bit output: DRP ready
                                            // Dynamic Phase Shift Ports: 1-bit (each) output: Ports used for dynamic phase shifting of the outputs
        .PSDONE(),                          // 1-bit output: Phase shift done
                                            // Feedback Clocks: 1-bit (each) output: Clock feedback ports
        .CLKFBOUT(mmcm_out_feedback),       // 1-bit output: Feedback clock
        .CLKFBOUTB(),                       // 1-bit output: Inverted CLKFBOUT
                                            // Status Ports: 1-bit (each) output: MMCM status ports
        .CLKFBSTOPPED(),                    // 1-bit output: Feedback clock stopped
        .CLKINSTOPPED(),                    // 1-bit output: Input clock stopped
        .LOCKED(locked),                    // 1-bit output: LOCK
                                            // Clock Inputs: 1-bit (each) input: Clock inputs
        .CLKIN1(in_clk0),                    // 1-bit input: Primary clock
        .CLKIN2(),                          // 1-bit input: Secondary clock
                                            // Control Ports: 1-bit (each) input: MMCM control ports
        .CLKINSEL(),                        // 1-bit input: Clock select, High=CLKIN1 Low=CLKIN2
        .PWRDWN(),                          // 1-bit input: Power-down
        .RST(),                             // 1-bit input: Reset
                                            // DRP Ports: 7-bit (each) input: Dynamic reconfiguration ports
        .DADDR(),                           // 7-bit input: DRP address
        .DCLK(),                            // 1-bit input: DRP clock
        .DEN(),                             // 1-bit input: DRP enable
        .DI(),                              // 16-bit input: DRP data
        .DWE(),                             // 1-bit input: DRP write enable
                                            // Dynamic Phase Shift Ports: 1-bit (each) input: Ports used for dynamic phase shifting of the outputs
        .PSCLK(),                           // 1-bit input: Phase shift clock
        .PSEN(),                            // 1-bit input: Phase shift enable
        .PSINCDEC(),                        // 1-bit input: Phase shift increment/decrement
                                            // Feedback Clocks: 1-bit (each) input: Clock feedback ports
        .CLKFBIN(mmcm_out_feedback_bufg)    // 1-bit input: Feedback clock
    );

endmodule