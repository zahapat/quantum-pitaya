`timescale 1 ns / 1 ns  // time-unit = 1 ns, precision = 10 ps

    module adc_read_tb;

        // ------------------------------------------------
        // DUT Ports and Instance
        // ------------------------------------------------
        // Generics 
        localparam INT_ADC_DATA_WIDTH = 10;
        localparam INT_ADC_DATA_IS_INVERTED = 1; // 1 If RF ADC gives inverted values
        localparam INT_IDATA_ENC_OFFSETBIN = 1;  // 1 If input ADC data is encoded in 'Offset Binary', else 0
        localparam INT_IDATA_ENC_TWOSCOMPL = 0;  // 1 If input ADC data is encoded in 'Two's Complement', else 0
        localparam INT_ODATA_ENC_OFFSETBIN = 1;  // 1 To convert data into 'Offset Binary' encoding, else 0
        localparam INT_ODATA_ENC_TWOSCOMPL = 0;  // 1 To convert data into 'Two's Complement' encoding, else 0

        // Ports
        logic in_clk = 0;
        logic i_valid;
        logic in_dready;
        logic [INT_ADC_DATA_WIDTH-1:0] in_data;
        logic out_valid;
        logic [INT_ADC_DATA_WIDTH-1:0] out_data;

        // DUT Instance
        adc_read #(
            // Check ADC Documentation and configure how data should be interpreted in the FPGA
            .INT_ADC_DATA_WIDTH(INT_ADC_DATA_WIDTH),
            .INT_ADC_DATA_IS_INVERTED(INT_ADC_DATA_IS_INVERTED),
            .INT_IDATA_ENC_OFFSETBIN(INT_IDATA_ENC_OFFSETBIN),
            .INT_IDATA_ENC_TWOSCOMPL(INT_IDATA_ENC_TWOSCOMPL),
            .INT_ODATA_ENC_OFFSETBIN(INT_ODATA_ENC_OFFSETBIN),
            .INT_ODATA_ENC_TWOSCOMPL(INT_ODATA_ENC_TWOSCOMPL)
        ) inst_adc_read_dut (
            .in_clk(in_clk),
            .in_data(in_data),
            .in_dready(in_dready),
            .out_data(out_data),
            .out_valid(out_valid)
        );

        // Clocks
        parameter clk_period_ns = 8; // * 1 ns on timescale
        initial forever begin #(clk_period_ns/2) in_clk = ~in_clk; end

        // ------------------------------------------------
        // Tasks
        // ------------------------------------------------
        integer i;
        // task task_ ();
        // endtask


        // ------------------------------------------------
        // Stimulus
        // ------------------------------------------------
        initial begin
            i_valid = 1'b0;
            $display($time, " << Starting the Simulation");

            // Send some data
            #100ns;
            for (i = -100; i <= 100; i = i + 1) begin
                i_valid = 1'b1;
                in_data = INT_ADC_DATA_WIDTH'(signed'(i));
                @(posedge in_clk);
            end
            i_valid = 1'b0;
            in_data = INT_ADC_DATA_WIDTH'(signed'(0));
            @(posedge in_clk);
            #100ns;


            $display($time, " << Simulation Finished");
            $finish; // End of Simulation
        end


    endmodule