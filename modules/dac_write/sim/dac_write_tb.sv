`timescale 1 ns / 1 ns  // time-unit = 1 ns, precision = 10 ps

    module dac_write_tb;

        // ------------------------------------------------
        // DUT Ports and Instance
        // ------------------------------------------------
        // Generics 
        localparam INT_DAC_DATA_WIDTH = 10,
        localparam INT_INVERT_ODATA = 0, // 1 If RF ADC gives inverted values
        localparam INT_IDATA_ENC_OFFSETBIN = 1,  // 1 If input ADC data is encoded in 'Offset Binary', else 0
        localparam INT_IDATA_ENC_TWOSCOMPL = 0,  // 1 If input ADC data is encoded in 'Two's Complement', else 0
        localparam INT_ODATA_ENC_OFFSETBIN = 1,  // 1 To convert data into 'Offset Binary' encoding, else 0
        localparam INT_ODATA_ENC_TWOSCOMPL = 0   // 1 To convert data into 'Two's Complement' encoding, else 0

        // Ports
        logic in_clk = 0;
        logic i_valid;
        logic in_dready;
        logic [INT_DAC_DATA_WIDTH-1:0] in_data;
        logic out_valid;
        logic [INT_DAC_DATA_WIDTH-1:0] out_data;

        // DUT Instance
        dac_write #(
            // Check ADC Documentation and configure how data should be interpreted in the FPGA
            .INT_DAC_DATA_WIDTH(INT_DAC_DATA_WIDTH),
            .INT_INVERT_ODATA(INT_INVERT_ODATA),
            .INT_IDATA_ENC_OFFSETBIN(INT_IDATA_ENC_OFFSETBIN),
            .INT_IDATA_ENC_TWOSCOMPL(INT_IDATA_ENC_TWOSCOMPL),
            .INT_ODATA_ENC_OFFSETBIN(INT_ODATA_ENC_OFFSETBIN),
            .INT_ODATA_ENC_TWOSCOMPL(INT_ODATA_ENC_TWOSCOMPL)
        ) inst_dac_write_dut (
            .in_clk_data(in_clk_data),
            .in_clk_clk(in_clk_clk),
            .in_clk_wrt(in_clk_wrt),
            .in_data(in_data),
            .in_rst(in_rst),
            .in_valid(in_valid),
            .out_data(out_data),
            .out_clk(out_clk),
            .out_wrt(out_wrt),
            .out_rst(out_rst),
            .out_ready(out_ready)
        );

        // Clocks
        parameter clk_period_ns = 8.0; // * 1 ns on timescale
        initial forever begin #(clk_period_ns/2.0) clk = ~clk; end

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
                in_data = INT_DAC_DATA_WIDTH'(signed'(i));
                @(posedge clk);
            end
            i_valid = 1'b0;
            in_data = INT_DAC_DATA_WIDTH'(signed'(0));
            @(posedge clk);
            #100ns;


            $display($time, " << Simulation Finished");
            $finish; // End of Simulation
        end


    endmodule