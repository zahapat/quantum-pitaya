`timescale 1 ns / 1 ns  // time-unit = 1 ns, precision = 10 ps

module clock_synthesizer_tb;

    // ------------------------------------------------
    // DUT IO Signals and Instance
    // ------------------------------------------------
    // Generics
    // Set input clk parameters
    localparam REAL_CLKIN1_MHZ = 125.0;
    localparam INT_OUT_CLOCKS = 4;

    // Setup the VCO frequency for the entire device
    localparam INT_VCO_DIVIDE = 1;
    localparam REAL_VCO_MULTIPLY = 9.000;
    localparam REAL_DIVIDE_OUT0 = 9.000;

    localparam INT_DIVIDE_OUT1 = 9;
    localparam INT_DIVIDE_OUT2 = 9;
    localparam INT_DIVIDE_OUT3 = 9;
    localparam INT_DIVIDE_OUT4 = 1;
    localparam INT_DIVIDE_OUT5 = 1;
    localparam INT_DIVIDE_OUT6 = 1;

    localparam REAL_DUTY_OUT0 = 0.500;
    localparam REAL_DUTY_OUT1 = 0.500;
    localparam REAL_DUTY_OUT2 = 0.500;
    localparam REAL_DUTY_OUT3 = 0.500;
    localparam REAL_DUTY_OUT4 = 0.500;
    localparam REAL_DUTY_OUT5 = 0.500;
    localparam REAL_DUTY_OUT6 = 0.500;

    localparam REAL_PHASE_OUT0 = 90.000;
    localparam REAL_PHASE_OUT1 = 115.000;
    localparam REAL_PHASE_OUT2 = 0.000;
    localparam REAL_PHASE_OUT3 = 0.000;
    localparam REAL_PHASE_OUT4 = 0.000;
    localparam REAL_PHASE_OUT5 = 0.000;
    localparam REAL_PHASE_OUT6 = 0.00;

    // Inputs
    logic in_clk0 = 1'b0;

    // Fine Phase Shift
    logic in_fineps_clk = 1'b0;

    logic in_fineps_incr;
    logic in_fineps_decr;
    logic in_fineps_valid;
    logic out_fineps_dready;

    // Outputs
    logic out_clk0;
    logic out_clk1;
    logic out_clk2;
    logic out_clk3;
    logic out_clk4;
    logic out_clk5;
    logic out_clk6;
    logic locked;

    // DUT Instance
    clock_synthesizer #(
        // Set input clk parameters
        .REAL_CLKIN1_MHZ(REAL_CLKIN1_MHZ),
        .INT_OUT_CLOCKS(INT_OUT_CLOCKS),

        // Setup the VCO frequency for the entire device
        .INT_VCO_DIVIDE(INT_VCO_DIVIDE),
        .REAL_VCO_MULTIPLY(REAL_VCO_MULTIPLY),

        .REAL_DIVIDE_OUT0(REAL_DIVIDE_OUT0),
        .INT_DIVIDE_OUT1(INT_DIVIDE_OUT1),
        .INT_DIVIDE_OUT2(INT_DIVIDE_OUT2),
        .INT_DIVIDE_OUT3(INT_DIVIDE_OUT3),
        .INT_DIVIDE_OUT4(INT_DIVIDE_OUT4),
        .INT_DIVIDE_OUT5(INT_DIVIDE_OUT5),
        .INT_DIVIDE_OUT6(INT_DIVIDE_OUT6),

        .REAL_DUTY_OUT0(REAL_DUTY_OUT0),
        .REAL_DUTY_OUT1(REAL_DUTY_OUT1),
        .REAL_DUTY_OUT2(REAL_DUTY_OUT2),
        .REAL_DUTY_OUT3(REAL_DUTY_OUT3),
        .REAL_DUTY_OUT4(REAL_DUTY_OUT4),
        .REAL_DUTY_OUT5(REAL_DUTY_OUT5),
        .REAL_DUTY_OUT6(REAL_DUTY_OUT6),

        .REAL_PHASE_OUT0(REAL_PHASE_OUT0),
        .REAL_PHASE_OUT1(REAL_PHASE_OUT1),
        .REAL_PHASE_OUT2(REAL_PHASE_OUT2),
        .REAL_PHASE_OUT3(REAL_PHASE_OUT3),
        .REAL_PHASE_OUT4(REAL_PHASE_OUT4),
        .REAL_PHASE_OUT5(REAL_PHASE_OUT5),
        .REAL_PHASE_OUT6(REAL_PHASE_OUT6)
    ) dut (
        // Inputs
        .in_clk0(in_clk0),

        // Fine Phase Shift
        .in_fineps_clk(in_fineps_clk),
        .in_fineps_incr(in_fineps_incr),
        .in_fineps_decr(in_fineps_decr),
        .in_fineps_valid(in_fineps_valid),
        .out_fineps_dready(out_fineps_dready),
        // .out_ps_done(out_ps_done),

        // Outputs
        .out_clk0(out_clk0),
        .out_clk1(out_clk1),
        .out_clk2(out_clk2),
        .out_clk3(out_clk3),
        .out_clk4(out_clk4),
        .out_clk5(out_clk5),
        .out_clk6(out_clk6),
        .locked(locked)
    );

    // Clocks
    parameter clk_period_ns = 8; // * 1 ns on timescale
    initial forever begin #(clk_period_ns/2) in_clk0 = ~in_clk0; end

    parameter fineps_clk_period_ns = 8; // * 1 ns on timescale
    initial forever begin #(fineps_clk_period_ns/2) in_fineps_clk = ~in_fineps_clk; end

    // ------------------------------------------------
    // Tasks
    // ------------------------------------------------
    

    // ------------------------------------------------
    // Stimulus
    // ------------------------------------------------
    
    initial begin
        in_fineps_incr = 0;
        in_fineps_decr = 0;
        // in_fineps_valid = 0; // uncomment if valid mode, comment in constant valid mode
        in_fineps_valid = 1'b1;// Constant valid mode, use only incr and decr

        // Wait until Fine PS is controllable
        wait (out_fineps_dready == 1'b1);

        // Wait until all clocks are running
        @(posedge in_clk0);
        @(posedge in_fineps_clk);
        @(posedge out_clk0);
        @(posedge out_clk1);
        @(posedge out_clk2);
        @(posedge out_clk3);

        // Test delimiter
        #100ns;
        @(posedge in_fineps_clk);


        // Controlling the Fine Phase Shift: Increment
        for (int i = 0; i < 360; i = i + 1) begin
            // Prepare values
            if (out_fineps_dready == 1'b1) begin
                in_fineps_incr = 1'b1;
                in_fineps_decr = 0;
                // in_fineps_valid = 1'b1; // comment in constant valid mode
            end
            @(posedge in_fineps_clk);
            $display($time, "                       in_fineps_incr  = ", in_fineps_incr);
            $display($time, "                       in_fineps_decr  = ", in_fineps_decr);
            $display($time, "                       in_fineps_valid  = ", in_fineps_valid);

            // Pull down
            in_fineps_incr = 0;
            in_fineps_decr = 0;
            // in_fineps_valid = 0; // uncomment if valid mode, comment in constant valid mode
            wait (out_fineps_dready == 1'b1);
            @(posedge in_fineps_clk);
        end

        #1000ns;
        @(posedge in_fineps_clk);

        // Controlling the Fine Phase Shift: Decrement
        for (int i = 0; i < 360; i = i + 1) begin
            // Prepare values
            if (out_fineps_dready == 1'b1) begin
                in_fineps_incr = 0;
                in_fineps_decr = 1'b1;
                // in_fineps_valid = 1'b1; // comment in constant valid mode
            end
            @(posedge in_fineps_clk);
            $display($time, "                       in_fineps_incr  = ", in_fineps_incr);
            $display($time, "                       in_fineps_decr  = ", in_fineps_decr);
            $display($time, "                       in_fineps_valid  = ", in_fineps_valid);

            // Pull down
            in_fineps_incr = 0;
            in_fineps_decr = 0;
            // in_fineps_valid = 0; // uncomment if valid mode, comment in constant valid mode
            wait (out_fineps_dready == 1'b1);
            @(posedge in_fineps_clk);
        end

        
        @(posedge in_clk0);
        #100ns;

        $finish; // End of Simulation
    end


endmodule