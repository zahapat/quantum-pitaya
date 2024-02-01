`timescale 1ns / 1ns

    module dsp_path #(
            // DDC
            parameter INT_DDC_NUMBER_OF_TAPS = 15,           // Max FIR Order + 1
            parameter INT_DDC_IN_DATA_WIDTH = 10,           // 
            parameter INT_DDC_DOWNSAMPLING = 5,            // The decimation value
            parameter INT_DDC_COEF_WIDTH = 15,              // Width of each FIR coefficient
            parameter INT_DDC_OUT_DATA_WIDTH = 20,          // Output data width of the digital downconversion
            parameter REAL_DDC_LOCOSC_IN_FREQ_MHZ = 125.0,  // Clock frequency the local oscillator is running on
            parameter REAL_DDC_LOCOSC_OUT_FREQ_MHZ = 25.0,  // The desired frequency of the local oscillator (sine + cosine)

            // Integration & averaging
            parameter INT_MAX_AVERAGE_BY = 5,      // Enter the number of how many data points are to be averaged
            parameter INT_AVG_DIVISOR_WIDTH = 28    // Set the resolution of the divisor. Config INT_IN_DATA_WIDTH=14 & INT_DIVISOR_WIDTH=28 (total 42 bits) implements 1x DSP block for the division
        )(
            // Inputs
            input  logic clk,
            input  logic rst,
            input  logic i_valid,
            input  logic signed [INT_DDC_IN_DATA_WIDTH-1:0] i_data,

            // Ports to configure DOWNSAMPLING
            input  logic i_deci_cmd_valid,
            input  logic [$clog2(INT_DDC_DOWNSAMPLING)-1:0] i_deci_cmd_data, // i_deci_cmd_data = 5 means Decimation = 6, thus, one needs to decrement the value by 1

            // Ports to configure FIR
            input  logic i_fir_cmd_valid,
            input  logic [$clog2(INT_DDC_NUMBER_OF_TAPS)-1:0] i_fir_cmd_coeffsel,
            input  logic signed [INT_DDC_COEF_WIDTH-1:0] i_fir_cmd_data,

            // Ports to configure AVERAGER
            input  logic i_avg_cmd_valid,
            input  logic [$clog2(INT_MAX_AVERAGE_BY)-1:0] i_avg_cmd_data,

            // Outputs
            output logic o_valid,
            output logic signed [INT_DDC_OUT_DATA_WIDTH + $clog2(INT_MAX_AVERAGE_BY)-1:0] o_data_i,
            output logic signed [INT_DDC_OUT_DATA_WIDTH + $clog2(INT_MAX_AVERAGE_BY)-1:0] o_data_q
        );

        // Signals for modules interconnection
        logic [INT_DDC_OUT_DATA_WIDTH-1:0] conn_data_i_ddc; // In-phase data form DDC do Averager
        logic [INT_DDC_OUT_DATA_WIDTH-1:0] conn_data_q_ddc; // Quadrature data form DDC do Averager
        logic conn_valid_ddc;
        logic o_valid_i;
        logic o_valid_q;

        // DDC Instance
        ddc #(
            .INT_NUMBER_OF_TAPS(INT_DDC_NUMBER_OF_TAPS),
            .INT_IN_DATA_WIDTH(INT_DDC_IN_DATA_WIDTH),
            .INT_DOWNSAMPLING(INT_DDC_DOWNSAMPLING),
            .INT_COEF_WIDTH(INT_DDC_COEF_WIDTH),
            .INT_OUT_DATA_WIDTH(INT_DDC_OUT_DATA_WIDTH),
            .REAL_LOCOSC_IN_FREQ_MHZ(REAL_DDC_LOCOSC_IN_FREQ_MHZ),
            .REAL_LOCOSC_OUT_FREQ_MHZ(REAL_DDC_LOCOSC_OUT_FREQ_MHZ)
        ) inst_ddc (
            // Inputs
            .clk(clk),
            .rst(rst),
            .i_valid(i_valid),
            .i_data(i_data),

            // Ports to configure DOWNSAMPLING
            .i_deci_cmd_valid(i_deci_cmd_valid),
            .i_deci_cmd_data(i_deci_cmd_data), // i_deci_cmd_data = 5 means Decimation = 6, thus, one needs to decrement the value by 1

            // Ports to Update FIR Coeffitients
            .i_fir_cmd_valid(i_fir_cmd_valid),
            .i_fir_cmd_coeffsel(i_fir_cmd_coeffsel),
            .i_fir_cmd_data(i_fir_cmd_data),

            .o_valid(conn_valid_ddc),
            .o_data_i(conn_data_i_ddc),
            .o_data_q(conn_data_q_ddc)
        );

        generate
            // Instantiate Averaging Instance
            if (INT_MAX_AVERAGE_BY > 1) begin
                assign o_valid = o_valid_i & o_valid_q;

                // (In-Phase)
                averager #(
                    .INT_MAX_AVERAGE_BY(INT_MAX_AVERAGE_BY),
                    .INT_IN_DATA_WIDTH(INT_DDC_OUT_DATA_WIDTH),
                    .INT_DIVISOR_WIDTH(INT_AVG_DIVISOR_WIDTH)
                ) inst_averager_i (
                    .clk(clk),
                    .rst(rst),
                    .i_valid(conn_valid_ddc),
                    .i_data(conn_data_i_ddc),

                    .i_avg_cmd_valid(i_avg_cmd_valid),
                    .i_avg_cmd_data(i_avg_cmd_data),

                    .o_valid_integrated(o_valid_i),
                    .o_data_integrated(o_data_i),

                    .o_valid_averaged(),
                    .o_data_averaged_guotient(),
                    .o_data_averaged_remainder()
                );

                // (Qudrature)
                averager #(
                    .INT_MAX_AVERAGE_BY(INT_MAX_AVERAGE_BY),
                    .INT_IN_DATA_WIDTH(INT_DDC_OUT_DATA_WIDTH),
                    .INT_DIVISOR_WIDTH(INT_AVG_DIVISOR_WIDTH)
                ) inst_averager_q (
                    .clk(clk),
                    .rst(rst),
                    .i_valid(conn_valid_ddc),
                    .i_data(conn_data_q_ddc),

                    .i_avg_cmd_valid(i_avg_cmd_valid),
                    .i_avg_cmd_data(i_avg_cmd_data),

                    .o_valid_integrated(o_valid_q),
                    .o_data_integrated(o_data_q),

                    .o_valid_averaged(),
                    .o_data_averaged_guotient(),
                    .o_data_averaged_remainder()
                );
            end


            // Do not Instantiate Averaging Instance as log2(0) is undefined and log2(1) does not require averaging instance
            if (INT_MAX_AVERAGE_BY <= 1) begin
                assign o_valid = conn_valid_ddc;
                assign o_data_i[INT_DDC_OUT_DATA_WIDTH-1:0] = conn_data_i_ddc;
                assign o_data_q[INT_DDC_OUT_DATA_WIDTH-1:0] = conn_data_q_ddc;
            end
        endgenerate

    endmodule