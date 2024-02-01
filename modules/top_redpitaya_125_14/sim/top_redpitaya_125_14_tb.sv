// `timescale 1ps / 1ps  // time-unit = 1 ns, precision = 1 ps

    module top_redpitaya_125_14_tb;

        timeunit 1ps;
        timeprecision 1ps;

        // ------------------------------------------------
        // Simulation control
        // ------------------------------------------------
        integer ctrl_sim_ended = 0;
        parameter INT_TRIGGER1_REPETITIONS = 10; // Accumulator Rounds Count
        parameter INT_TRIGGER1_DELAY_BEFORE_REPETITIONS_NS = 452;
        parameter INT_TRIGGER1_HIGH_NS = 800;
        parameter INT_TRIGGER1_LOW_NS = 40;
        parameter INT_TRIGGER1_DELAY_AFTER_REPETITIONS_NS = 99;

        parameter INT_TRIGGER2_REPETITIONS = 2; // Accumulator Channels Count
        parameter INT_TRIGGER2_DELAY_BEFORE_REPETITIONS_NS = 452;
        parameter INT_TRIGGER2_HIGH_NS = 100;
        parameter INT_TRIGGER2_LOW_NS = 50;
        parameter INT_TRIGGER2_DELAY_AFTER_REPETITIONS_NS = 99;

        localparam INT_INPUT_TRANSACTIONS_CNT = 100000;
        integer i;


        // ------------------------------------------------
        // DUT Ports and Instance
        // ------------------------------------------------
        parameter INT_DIFF_ADC_CLK = 0;
        parameter INT_ADC_CHANNELS = 2;
        parameter INT_DAC_CHANNELS = 2;
        parameter INT_ADC_DATA_CH1_WIDTH = 14;
        parameter INT_ADC_DATA_CH2_WIDTH = 14;
        parameter INT_ADC_DATA_CH1_TRIM_BITS_RIGHT = 1;
        parameter INT_ADC_DATA_CH2_TRIM_BITS_RIGHT = 1;
        parameter INT_DAC_DATA_CH1_WIDTH = 14;
        parameter INT_DAC_DATA_CH2_WIDTH = 14;
        parameter INT_AXIS_DATA_WIDTH = 32;
        parameter INT_BYPASS_DSP = 0;

        // DDC
        parameter INT_DDC_NUMBER_OF_TAPS = 15;          // Max FIR Order + 1
        parameter INT_DDC_COEF_WIDTH = 15;              // Width of each FIR coefficient
        parameter REAL_DDC_LOCOSC_IN_FREQ_MHZ = 125.0;  // Sampling/Clock frequency the local oscillator is running on
        parameter REAL_DDC_LOCOSC_OUT_FREQ_MHZ = 25.0;  // The desired frequency of the local oscillator (sine + cosine)
        parameter INT_DDC_OUT_DATA_WIDTH = 20;          // Output data width of the digital downconversion
        parameter INT_DDC_DOWNSAMPLING = 1;             // The decimation value

        // Integration & averaging
        parameter INT_AVG_MAX_AVERAGE_BY = 3;      // Enter the number of how many data points are to be averaged
        parameter INT_AVG_DIVISOR_WIDTH = 28; 

        // Multichannel Accumulator
        parameter INT_MULTIACC_FIFO_WIDTH = 32;
        // parameter INT_MULTIACC_FIFO_DEPTH = 1024, // To be implemented
        parameter INT_MULTIACC_FIFO_DEPTH = 32; // Simulation
        parameter INT_MULTIACC_REPETITIONS = INT_TRIGGER1_REPETITIONS;
        parameter INT_MULTIACC_CHANNELS = INT_TRIGGER2_REPETITIONS;

        // RX Command Parser
        parameter CMD_OUTPUT_WIDTH = 5;
        parameter MODULE_SELECT_WIDTH = 5;
        parameter MODULES_CMD_CNT = 13;

        // Ports //
        logic in_adc_clk_p = 0;
        logic in_adc_clk_n = 0;
        logic[INT_ADC_DATA_CH1_WIDTH-1:0] in_data_ch1 = 0;
        logic[INT_ADC_DATA_CH2_WIDTH-1:0] in_data_ch2 = 0;

        // Peripheral Outputs
        logic[INT_DAC_DATA_CH1_WIDTH-1:0] dac_o_data;
        logic dac_o_iqsel;
        logic dac_o_iqclk;
        logic dac_o_iqwrt;
        logic dac_o_iqrst;
        logic adc_i_clkstb;

        logic[8-1:0] leds;

        // AXI4 Lite ports
        logic aclk = 0;

        // Accumulator Ready
        logic o_multiacc_o_acc_valid_i;

        // FIFO read ctrl
        logic[32-1:0] o_fifo_data_ch1;
        logic[32-1:0] o_fifo_data_ch2;
        logic o_fifo_data_ch1_valid;
        logic o_fifo_data_ch2_valid;
        logic i_fifo_rd_dready_ch1;
        logic i_fifo_rd_dready_ch2;

        // FIFO CMD
        logic [32-1:0] i_cmddata_axi_fifo_i_data;
        logic i_cmddata_axi_fifo_i_valid;
        logic o_cmddata_axi_fifo_o_ready;    // This FIFO ready
        logic [32-1:0] i_cmd_axi_fifo_i_data;
        logic i_cmd_axi_fifo_i_valid;
        logic o_cmd_axi_fifo_o_ready;    // This FIFO ready

        // Multichannel Read Control Command: Destination Ready
        logic o_multichrdctrl_cmd_dready_i;
        logic o_multichrdctrl_cmd_dready_q;

        // Triggers
        logic i_acc_trigger_1 = 0;
        logic i_acc_trigger_2 = 0;


        // DUT Instance
        top_redpitaya_125_14 #(
            .INT_DIFF_ADC_CLK(INT_DIFF_ADC_CLK),
            .INT_ADC_CHANNELS(INT_ADC_CHANNELS),
            .INT_DAC_CHANNELS(INT_DAC_CHANNELS),
            .INT_ADC_DATA_CH1_WIDTH(INT_ADC_DATA_CH1_WIDTH),
            .INT_ADC_DATA_CH2_WIDTH(INT_ADC_DATA_CH2_WIDTH),
            .INT_ADC_DATA_CH1_TRIM_BITS_RIGHT(INT_ADC_DATA_CH1_TRIM_BITS_RIGHT),
            .INT_ADC_DATA_CH2_TRIM_BITS_RIGHT(INT_ADC_DATA_CH2_TRIM_BITS_RIGHT),
            .INT_DAC_DATA_CH1_WIDTH(INT_DAC_DATA_CH1_WIDTH),
            .INT_DAC_DATA_CH2_WIDTH(INT_DAC_DATA_CH2_WIDTH),
            .INT_AXIS_DATA_WIDTH(INT_AXIS_DATA_WIDTH),
            .INT_BYPASS_DSP(INT_BYPASS_DSP),

            // DDC
            .INT_DDC_NUMBER_OF_TAPS(INT_DDC_NUMBER_OF_TAPS),
            .INT_DDC_COEF_WIDTH(INT_DDC_COEF_WIDTH),
            .REAL_DDC_LOCOSC_IN_FREQ_MHZ(REAL_DDC_LOCOSC_IN_FREQ_MHZ),
            .REAL_DDC_LOCOSC_OUT_FREQ_MHZ(REAL_DDC_LOCOSC_OUT_FREQ_MHZ),
            .INT_DDC_OUT_DATA_WIDTH(INT_DDC_OUT_DATA_WIDTH),
            .INT_DDC_DOWNSAMPLING(INT_DDC_DOWNSAMPLING),

            // Integration & averaging
            .INT_AVG_MAX_AVERAGE_BY(INT_AVG_MAX_AVERAGE_BY),
            .INT_AVG_DIVISOR_WIDTH(INT_AVG_DIVISOR_WIDTH),

            // Multichannel Accumulator
            .INT_MULTIACC_FIFO_WIDTH(INT_MULTIACC_FIFO_WIDTH),
            .INT_MULTIACC_FIFO_DEPTH(INT_MULTIACC_FIFO_DEPTH),
            .INT_MULTIACC_CHANNELS(INT_MULTIACC_CHANNELS),
            .INT_MULTIACC_REPETITIONS(INT_MULTIACC_REPETITIONS)

        ) inst_dut (
            // AXI4 Lite ports
            .aclk(aclk),

            // Peripheral Inputs
            .in_adc_clk_p(in_adc_clk_p),
            .in_adc_clk_n(in_adc_clk_n),
            .in_data_ch1(in_data_ch1),
            .in_data_ch2(in_data_ch2),

            // Peripheral Outputs
            .dac_o_data(dac_o_data),
            .dac_o_iqsel(dac_o_iqsel),
            .dac_o_iqclk(dac_o_iqclk),
            .dac_o_iqwrt(dac_o_iqwrt),
            .dac_o_iqrst(dac_o_iqrst),
            .adc_i_clkstb(adc_i_clkstb),
            .leds(leds),



            // Accumulator Ready
            .o_multiacc_o_acc_valid_i(o_multiacc_o_acc_valid_i),

            // FIFO read ctrl
            .o_fifo_data_ch1(o_fifo_data_ch1),
            .o_fifo_data_ch2(o_fifo_data_ch2),
            .o_fifo_data_ch1_valid(o_fifo_data_ch1_valid),
            .o_fifo_data_ch2_valid(o_fifo_data_ch2_valid),
            .i_fifo_rd_dready_ch1(i_fifo_rd_dready_ch1),
            .i_fifo_rd_dready_ch2(i_fifo_rd_dready_ch2),

            .i_cmddata_axi_fifo_i_data(i_cmddata_axi_fifo_i_data),
            .i_cmddata_axi_fifo_i_valid(i_cmddata_axi_fifo_i_valid),
            .o_cmddata_axi_fifo_o_ready(o_cmddata_axi_fifo_o_ready),    // This FIFO ready
            .i_cmd_axi_fifo_i_data(i_cmd_axi_fifo_i_data),
            .i_cmd_axi_fifo_i_valid(i_cmd_axi_fifo_i_valid),
            .o_cmd_axi_fifo_o_ready(o_cmd_axi_fifo_o_ready),    // This FIFO ready

            // Multichannel Read Control Command: Destination Ready
            .o_multichrdctrl_cmd_dready_i(o_multichrdctrl_cmd_dready_i),
            .o_multichrdctrl_cmd_dready_q(o_multichrdctrl_cmd_dready_q),

            .i_acc_trigger_1(i_acc_trigger_1),
            .i_acc_trigger_2(i_acc_trigger_2)
        );


        // Clocks
        parameter clk_period_ps = 1.0/REAL_DDC_LOCOSC_IN_FREQ_MHZ * 1000.0 * 1000.0;
        initial forever begin #(clk_period_ps/2.0) in_adc_clk_p = ~in_adc_clk_p; end

        parameter AXIS_CLK_FREQ_MHZ = 145.0;
        parameter axis_clk_period_ps = 1.0/AXIS_CLK_FREQ_MHZ * 1000.0 * 1000.0;
        initial forever begin #(axis_clk_period_ps/2.0) aclk = ~aclk; end


        // Input IQ modulated signal
        logic clk_iq = 0;
        parameter clk_iq_period_ps = 50;
        initial forever begin #(clk_iq_period_ps/2.0) clk_iq = ~clk_iq; end

        localparam IQ_REAL_SINCOS_OUT_FREQ_MHZ =25.0;
        localparam IQ_REAL_SINCOS_IN_FREQ_MHZ = 1000.0/(clk_iq_period_ps)*1000.0;
        localparam PI = 3.1415926535897932384626433832795;
        localparam IQ_NUMBER_OF_SAMPLES = (1.0*IQ_REAL_SINCOS_IN_FREQ_MHZ) / IQ_REAL_SINCOS_OUT_FREQ_MHZ;
        localparam IQ_INT_NUMBER_OF_SAMPLES = $rtoi(IQ_NUMBER_OF_SAMPLES);
        localparam IQ_ANGLE_INCREMENTS = 360.0/IQ_INT_NUMBER_OF_SAMPLES;
        logic signed [INT_ADC_DATA_CH1_WIDTH-2:0] cos_value;
        logic signed [INT_ADC_DATA_CH1_WIDTH-2:0] sin_value;
        logic signed [INT_ADC_DATA_CH1_WIDTH-1:0] iq_value;
        integer iq_increment = 0;

        initial forever begin
            @(posedge clk_iq);
            cos_value = (INT_ADC_DATA_CH1_WIDTH-1)'(
                //         Degrees to radians                  To data width scale
                $cos(iq_increment*IQ_ANGLE_INCREMENTS*PI/180.0) * (2.0**(INT_ADC_DATA_CH1_WIDTH-1)/2 - 1.0)
            );
            sin_value = (INT_ADC_DATA_CH1_WIDTH-1)'(
                //         Degrees to radians                  To data width scale
                $sin(iq_increment*IQ_ANGLE_INCREMENTS*PI/180.0) * (2.0**(INT_ADC_DATA_CH1_WIDTH-1)/2 - 1.0)
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



        // ------------------------------------------------
        // Stimulus
        // ------------------------------------------------
        // Channel 1 Input:  Open text file & use its content as input waveform
        // filename = "C:\\Git\zahapat\\FQEnv\outputs\\redpitaya\\0_25_0_15_15_20_5_5_______\\read_ch1_2023-07-05T083036UTC.txt"
        // string fpath_idata_ch1 = "C:/Git/zahapat/FQEnv/outputs/redpitaya/adc_raw_data_squarewave-50ohm/cout_fifo_ch1_0p5v.txt";
        // // string fpath_idata_ch1 = "C:/Git/zahapat/FQEnv/outputs/redpitaya/1_25_0_15_15_20_5_5_______/read_ch1.txt";
        // // string fpath_idata_ch1 = "C:/Git/zahapat/FQEnv/outputs/redpitaya/adc_raw_data_squarewave-50ohm/cout_fifo_ch1_0p1v.txt";
        // int f_idata_ch1 = 0;
        // logic [INT_AXIS_DATA_WIDTH-1:0] fitem_idata_ch1;
        // initial forever begin

        //     if (ctrl_sim_ended == 0) begin

        //         if (f_idata_ch1 == 0) begin
        //             f_idata_ch1 = $fopen(fpath_idata_ch1, "r");
        //         end

        //         if ($fscanf(f_idata_ch1, "%h", fitem_idata_ch1)) begin
        //             // EOF not reached
        //             in_data_ch1[INT_ADC_DATA_CH1_WIDTH-1:0] = fitem_idata_ch1[INT_ADC_DATA_CH1_WIDTH-1:0];
        //             // in_data_ch1[INT_ADC_DATA_CH1_WIDTH-2:0] = ~fitem_idata_ch1[INT_ADC_DATA_CH1_WIDTH-2:0]; // Converted to From Offset Binary
        //             @(posedge in_adc_clk_p);
        //         end else begin
        //             // EOF reached or encountered an error
        //             $fclose(f_idata_ch1);
        //             f_idata_ch1 = $fopen(fpath_idata_ch1, "r");
        //             break;
        //         end

        //     end else begin
        //         if (f_idata_ch1 != 0) begin
        //             $fclose(f_idata_ch1);
        //         end
        //     end
        // end
        // string fpath_idata_ch2 = "C:/Git/zahapat/FQEnv/outputs/redpitaya/adc_raw_data_squarewave-50ohm/cout_fifo_ch1_0p5v.txt";
        // int f_idata_ch2 = 0;
        // logic [INT_AXIS_DATA_WIDTH-1:0] fitem_idata_ch2;
        // initial forever begin

        //     if (ctrl_sim_ended == 0) begin

        //         if (f_idata_ch2 == 0) begin
        //             f_idata_ch2 = $fopen(fpath_idata_ch2, "r");
        //         end

        //         if ($fscanf(f_idata_ch2, "%h", fitem_idata_ch2)) begin
        //             // EOF not reached
        //             in_data_ch2[INT_ADC_DATA_CH2_WIDTH-1:0] = fitem_idata_ch2[INT_ADC_DATA_CH2_WIDTH-1:0];
        //             @(posedge in_adc_clk_p);
        //         end else begin
        //             // EOF reached or encountered an error
        //             $fclose(f_idata_ch2);
        //             f_idata_ch2 = $fopen(fpath_idata_ch2, "r");
        //             break;
        //         end

        //     end else begin
        //         if (f_idata_ch2 != 0) begin
        //             $fclose(f_idata_ch2); // Freezes here
        //         end
        //     end
        // end

        // Channel 2 Input
        initial begin
            force inst_dut.adc_i_dready_ch1 = 1'b0;
            force inst_dut.adc_i_dready_ch2 = 1'b0;
            $display($time, " << Starting the Simulation: Thread 1");

            #100ns;
            for (i = 0; i < INT_INPUT_TRANSACTIONS_CNT; i = i + 1) begin

                // Simulate the inverted input + offset binary data encoding on the input RF path
                in_data_ch1[INT_ADC_DATA_CH1_WIDTH-1] = iq_value[INT_ADC_DATA_CH1_WIDTH-1]; // inv + offset binary
                in_data_ch1[INT_ADC_DATA_CH1_WIDTH-2:0] = ~iq_value[INT_ADC_DATA_CH1_WIDTH-2:0]; // inv

                // // Simulate only the offset binary
                // in_data_ch1[INT_ADC_DATA_CH1_WIDTH-1] = iq_value[INT_ADC_DATA_CH1_WIDTH-1]; // inv + offset binary
                // in_data_ch1[INT_ADC_DATA_CH1_WIDTH-2:0] = ~iq_value[INT_ADC_DATA_CH1_WIDTH-2:0]; // inv

                @(posedge in_adc_clk_p);
            end

            // in_data_ch1 = 0;
            // in_data_ch1[INT_ADC_DATA_CH1_WIDTH-1] = 1'b1;
            // in_data_ch1[INT_ADC_DATA_CH1_WIDTH-2:0] = 0;

            // in_data_ch2 = 0;
            // in_data_ch2[INT_ADC_DATA_CH2_WIDTH-1] = 1'b1;
            // in_data_ch2[INT_ADC_DATA_CH2_WIDTH-2:0] = 0;
            @(posedge in_adc_clk_p);
            #100ns;
            @(posedge in_adc_clk_p);


            $display($time, " << Simulation Finished: Thread 1");
        end


        // Trigger 1 Driver
        initial begin
            i_acc_trigger_1 = 0;
            #((INT_TRIGGER1_DELAY_BEFORE_REPETITIONS_NS)*1ns); // Asynchronous Trigger

            for (int t2 = 0; t2 < INT_TRIGGER2_REPETITIONS; t2 = t2 + 1) begin
                for (int t1 = 0; t1 < INT_TRIGGER1_REPETITIONS; t1 = t1 + 1) begin
                    wait (i_acc_trigger_2 == 0);

                    // Trigger High
                    $display($time, " << Thread Trigger 1: Trigger HIGH");
                    i_acc_trigger_1 = 1'b1;
                    force inst_dut.adc_i_dready_ch1 = 1'b1;
                    force inst_dut.adc_i_dready_ch2 = 1'b1;
                    #((INT_TRIGGER1_HIGH_NS)*1ns);

                    // Trigger Low
                    $display($time, " << Thread Trigger 1: Trigger LOW");
                    i_acc_trigger_1 = 0;
                    #((INT_TRIGGER1_LOW_NS)*1ns);
                end
                wait (i_acc_trigger_2 == 1'b1);
                wait (i_acc_trigger_2 == 0);
            end


            $display($time, " << Thread Trigger 1: Repetitions Done");
            #((INT_TRIGGER1_DELAY_AFTER_REPETITIONS_NS)*1ns);
            $display($time, " << Simulation Finished: Thread Trigger 1");
        end


        // Trigger 2 Driver
        initial begin
            i_acc_trigger_2 = 0;

            for (int t2 = 0; t2 < INT_TRIGGER2_REPETITIONS; t2 = t2 + 1) begin
                for (int t1 = 0; t1 < INT_TRIGGER1_REPETITIONS; t1 = t1 + 1) begin
                    wait (i_acc_trigger_1 == 1'b1);
                    wait (i_acc_trigger_1 == 0);
                end

                // Trigger High
                $display($time, " << Thread Trigger 2: Trigger HIGH");
                i_acc_trigger_2 = 1'b1;
                #((INT_TRIGGER2_HIGH_NS)*1ns);

                // Trigger Low
                $display($time, " << Thread Trigger 2: Trigger LOW");
                i_acc_trigger_2 = 0;
                #((INT_TRIGGER2_LOW_NS)*1ns);

            end


            $display($time, " << Thread Trigger 2: Repetitions Done");
            #((INT_TRIGGER2_DELAY_AFTER_REPETITIONS_NS)*1ns);
            $display($time, " << Simulation Finished: Thread Trigger 2");
        end


        // Ouptut
        initial begin
            $display($time, " << Starting the Simulation: Thread 2");

            // Read some data
            i_fifo_rd_dready_ch1 = 0;
            i_fifo_rd_dready_ch2 = 0;
            #1000ns;
            @(posedge aclk);
            for (i = 0; i < INT_INPUT_TRANSACTIONS_CNT; i = i + 1) begin

                // Perform readout from CDCC FIFO Ch1 and CH2
                if (o_fifo_data_ch1_valid == 1'b1) begin
                    i_fifo_rd_dready_ch1 = 1'b1;
                    // #1;
                    $display($time, " ps    FIFO CH1 DATA: ", o_fifo_data_ch1);
                end else begin
                    i_fifo_rd_dready_ch1 = 0;
                end

                if (o_fifo_data_ch2_valid == 1'b1) begin
                    i_fifo_rd_dready_ch2 = 1'b1;
                    // #1;
                    $display($time, " ps    FIFO CH2 DATA: ", o_fifo_data_ch2);
                end else begin
                    i_fifo_rd_dready_ch2 = 0;
                end
                @(posedge aclk);
                // The FIFO needs 1 clk to update the output value
                i_fifo_rd_dready_ch1 = 0;
                i_fifo_rd_dready_ch2 = 0;
                @(posedge aclk);
            end
            i_fifo_rd_dready_ch1 = 0;
            i_fifo_rd_dready_ch2 = 0;
            @(posedge aclk);
            #100ns;
            @(posedge aclk);

            $display($time, " << Simulation Finished: Thread 2");
        end


        // Fill out the multichannel fifo
        initial begin
            i_cmddata_axi_fifo_i_data = 0;
            i_cmddata_axi_fifo_i_valid = 0;
            i_cmd_axi_fifo_i_data = 0;
            i_cmd_axi_fifo_i_valid = 0;
            wait (o_multiacc_o_acc_valid_i == 1'b1);
            $display($time, " << Accumulation Done  : Thread CMD");
            @(posedge aclk);
            #100ns;
            @(posedge aclk);

            // The Command:
            // Example: FIFO_CMD_WIDTH     = 32 bit CMD Transaction
            // Example: CMD_DESTADDR_WIDTH = 5
            // -------------------------------------------------------------------------------------------------
            // |31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0|
            // |                                     COMMAND                                  |MODULE_SELECT|RW|
            // -------------------------------------------------------------------------------------------------

            // -----------------------------------------------------------
            // |         Write CMD         |          Read CMD           |
            // -----------------------------------------------------------
            // |  ... To write somewhere   |  ... To read from somwhere  |
            // |    / update write ptr     |      / update read ptr      |
            // -----------------------------------------------------------

            for (int i = 0; i < INT_MULTIACC_CHANNELS; i = i + 1) begin
                wait (o_multichrdctrl_cmd_dready_i == 1'b1);
                // [Write]-Type Command Transaction:
                //     1) RW
                i_cmd_axi_fifo_i_data[0]
                    = 1'b1;                                                                             // 0 = read, 1 = write (nened to send also data transaction)
                //     2) Select Module
                i_cmd_axi_fifo_i_data[MODULE_SELECT_WIDTH:1]                                             // Deliver the command to the respective module address
                    = MODULE_SELECT_WIDTH'(1);                                                          // Select module addr from 1, 2 ... ; 0 is invalid
                //     3) Command
                i_cmd_axi_fifo_i_data[CMD_OUTPUT_WIDTH + MODULE_SELECT_WIDTH+1:MODULE_SELECT_WIDTH+1]    // 
                    = CMD_OUTPUT_WIDTH'(i);                                                             // For module on addr 1, this is the Channel Select command
                i_cmd_axi_fifo_i_valid = 1'b1;                                                           // Validate 'i_cmd_axi_fifo_i_data' content

                // [Write]-Type Command Data Complement:
                i_cmddata_axi_fifo_i_data = INT_MULTIACC_FIFO_DEPTH;
                i_cmddata_axi_fifo_i_valid = 1'b1;

                $display($time, " <<         TX CMD      : i_cmd_axi_fifo_i_data     = %b", i_cmd_axi_fifo_i_data);
                $display($time, " <<         TX CMD DATA : i_cmddata_axi_fifo_i_data = %b", i_cmddata_axi_fifo_i_data);
                @(posedge aclk);
                i_cmddata_axi_fifo_i_data = 0;
                i_cmddata_axi_fifo_i_valid = 0;
                i_cmd_axi_fifo_i_data = 0;
                i_cmd_axi_fifo_i_valid = 0;
                wait (o_multichrdctrl_cmd_dready_i == 0);
                @(posedge aclk);
                #100ns;
                @(posedge aclk);
            end

            



            @(posedge aclk);
            wait (o_multiacc_o_acc_valid_i == 1'b0);
            @(posedge aclk);
            #1000ns;
            @(posedge aclk);
            ctrl_sim_ended = 1;
            $finish; // End of Simulation
        end


    endmodule