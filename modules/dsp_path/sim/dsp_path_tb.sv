`timescale 1ps / 1ps  // time-unit = 1 ns, precision = 10 ps

    module dsp_path_tb;

        // ------------------------------------------------
        // DUT Ports and Instance
        // ------------------------------------------------
        // Generics //
        parameter INT_DDC_IN_DATA_WIDTH = 10;           // 
        parameter INT_DDC_OUT_DATA_WIDTH = 20;          // Output data width of the digital downconversion

        // DDC
        parameter INT_DDC_NUMBER_OF_TAPS = 15;          // Max FIR Order + 1
        parameter INT_DDC_COEF_WIDTH = 15;              // Width of each FIR coefficient
        parameter REAL_DDC_LOCOSC_IN_FREQ_MHZ = 125.0;  // Clock frequency of the local oscillator clock domain
        parameter REAL_DDC_LOCOSC_OUT_FREQ_MHZ = 25.0;  // The desired frequency of the local oscillator (sine + cosine)
        parameter INT_DDC_DOWNSAMPLING = 5;             // The decimation value

        // Integration & averaging
        parameter INT_AVG_AVERAGE_BY = 5;      // Enter the number of how many data points are to be averaged
        parameter INT_AVG_DIVISOR_WIDTH = 28;    // Set the resolution of the divisor. Config INT_IN_DATA_WIDTH=14 & INT_DIVISOR_WIDTH=28 (total 42 bits) implements 1x DSP block for the division

        // Ports //
        // Inputs
        logic clk = 0;
        logic rst;
        logic i_valid;
        logic signed [INT_DDC_IN_DATA_WIDTH-1:0] i_data;

        logic i_deci_cmd_valid = 0;
        logic [$clog2(INT_DDC_DOWNSAMPLING)-1:0] i_deci_cmd_data = 0; // i_deci_cmd_data = 5 means Decimation = 6, thus, one needs to decrement the value by 1

        logic i_fir_cmd_valid;
        logic [$clog2(INT_DDC_NUMBER_OF_TAPS)-1:0] i_fir_cmd_coeffsel;
        logic signed [INT_DDC_COEF_WIDTH-1:0] i_fir_cmd_data;

        // Ports to configure AVERAGER
        logic i_avg_cmd_valid = 0;
        logic [$clog2(INT_MAX_AVERAGE_BY)-1:0] i_avg_cmd_data = 0;

        // Outputs
        logic o_valid;
        logic signed [INT_DDC_OUT_DATA_WIDTH + $clog2(INT_AVG_AVERAGE_BY)-1:0] o_data_i;
        logic signed [INT_DDC_OUT_DATA_WIDTH + $clog2(INT_AVG_AVERAGE_BY)-1:0] o_data_q;

        // DUT Instance
        dsp_path #(
            // DDC
            .INT_DDC_NUMBER_OF_TAPS(INT_DDC_NUMBER_OF_TAPS),                // Max FIR Order + 1
            .INT_DDC_IN_DATA_WIDTH(INT_DDC_IN_DATA_WIDTH),                  // ADC data width
            .INT_DDC_DOWNSAMPLING(INT_DDC_DOWNSAMPLING),                    // The decimation value
            .INT_DDC_COEF_WIDTH(INT_DDC_COEF_WIDTH),                        // Width of each FIR coefficient
            .INT_DDC_OUT_DATA_WIDTH(INT_DDC_OUT_DATA_WIDTH),                // Output data width of the digital downconversion
            .REAL_DDC_LOCOSC_IN_FREQ_MHZ(REAL_DDC_LOCOSC_IN_FREQ_MHZ),      // Clock frequency the local oscillator is running on
            .REAL_DDC_LOCOSC_OUT_FREQ_MHZ(REAL_DDC_LOCOSC_OUT_FREQ_MHZ),    // The desired frequency of the local oscillator (sine + cosine)

            // Integration & averaging
            .INT_AVG_AVERAGE_BY(INT_AVG_AVERAGE_BY),        // Enter the number of how many data points are to be averaged
            .INT_AVG_DIVISOR_WIDTH(INT_AVG_DIVISOR_WIDTH)      // Set the resolution of the divisor. Config INT_IN_DATA_WIDTH=14 & INT_DIVISOR_WIDTH=28 (total 42 bits) implements 1x DSP block for the division
        ) inst_dsp_path_dut (
            // Inputs
            .clk(clk),
            .rst(rst),
            .i_valid(i_valid),
            .i_data(i_data),

            .i_deci_cmd_valid(i_deci_cmd_valid),
            .i_deci_cmd_data(i_deci_cmd_data), // i_deci_cmd_data = 5 means Decimation = 6, thus, one needs to decrement the value by 1

            .i_fir_cmd_valid(i_fir_cmd_valid),
            .i_fir_cmd_coeffsel(i_fir_cmd_coeffsel),
            .i_fir_cmd_data(i_fir_cmd_data),

            // Ports to configure AVERAGER
            .i_avg_cmd_valid(i_avg_cmd_valid),
            .i_avg_cmd_data(i_avg_cmd_data),

            // Outputs
            .o_valid(o_valid),
            .o_data_i(o_data_i),
            .o_data_q(o_data_q)
        );

        // Clocks
        parameter clk_period_ps = 1.0/REAL_DDC_LOCOSC_IN_FREQ_MHZ * 1000.0 * 1000.0;
        initial forever begin #(clk_period_ps/2.0) clk = ~clk; end

        // Input IQ modulated signal
        logic clk_iq = 0;
        parameter clk_iq_period_ps = 50;
        initial forever begin #(clk_iq_period_ps/2.0) clk_iq = ~clk_iq; end

        localparam IQ_REAL_SINCOS_OUT_FREQ_MHZ = 50.0;
        localparam IQ_REAL_SINCOS_IN_FREQ_MHZ = 1000.0/(clk_iq_period_ps)*1000.0;
        localparam PI = 3.1415926535897932384626433832795;
        localparam IQ_NUMBER_OF_SAMPLES = (1.0*IQ_REAL_SINCOS_IN_FREQ_MHZ) / IQ_REAL_SINCOS_OUT_FREQ_MHZ;
        localparam IQ_INT_NUMBER_OF_SAMPLES = $rtoi(IQ_NUMBER_OF_SAMPLES);
        localparam IQ_ANGLE_INCREMENTS = 360.0/IQ_INT_NUMBER_OF_SAMPLES;
        logic signed [INT_DDC_IN_DATA_WIDTH-2:0] cos_value;
        logic signed [INT_DDC_IN_DATA_WIDTH-2:0] sin_value;
        logic signed [INT_DDC_IN_DATA_WIDTH-1:0] iq_value;
        integer iq_increment = 0;

        initial forever begin
            @(posedge clk_iq);
            cos_value = (INT_DDC_IN_DATA_WIDTH-1)'(
                //         Degrees to radians                  To data width scale
                $cos(iq_increment*IQ_ANGLE_INCREMENTS*PI/180.0) * (2.0**(INT_DDC_IN_DATA_WIDTH-1)/2 - 1.0)
            );
            sin_value = (INT_DDC_IN_DATA_WIDTH-1)'(
                //         Degrees to radians                  To data width scale
                $sin(iq_increment*IQ_ANGLE_INCREMENTS*PI/180.0) * (2.0**(INT_DDC_IN_DATA_WIDTH-1)/2 - 1.0)
            );
            iq_value = cos_value + sin_value;

            iq_increment = iq_increment + 1;
            if (iq_increment == IQ_NUMBER_OF_SAMPLES-1) begin
                iq_increment = 0;
            end
        end


        // ------------------------------------------------
        // Tasks
        // ------------------------------------------------
        localparam INT_TRANSACTIONS_CNT = 1000;
        integer i;
        // task task_ ();
        // endtask


        // ------------------------------------------------
        // Stimulus
        // ------------------------------------------------
        initial begin
            i_valid = 1'b0;
            $display($time, " << Starting the Simulation");

            // Find Sine and Cosine of variable 'i'
            #100ns;
            for (i = 0; i < INT_TRANSACTIONS_CNT; i = i + 1) begin
                i_valid = 1'b1;
                i_data = iq_value;
                @(posedge clk);
            end
            i_valid = 1'b0;
            i_data = 0;
            @(posedge clk);
            #100ns;
            @(posedge clk);


            $display($time, " << Simulation Finished");
            $finish; // End of Simulation
        end


    endmodule