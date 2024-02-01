`timescale 1 ns/100 ps

    module averager #(
            parameter INT_MAX_AVERAGE_BY = 10,      // Enter the number of how many data points are to be averaged
            parameter INT_IN_DATA_WIDTH = 14,   // Set the width of the input. Config INT_IN_DATA_WIDTH=14 & INT_DIVISOR_WIDTH=28 (total 42 bits) implements 1x DSP block for multiplication/accumulation
            parameter INT_DIVISOR_WIDTH = 28    // Set the resolution of the divisor. Config INT_IN_DATA_WIDTH=14 & INT_DIVISOR_WIDTH=28 (total 42 bits) implements 1x DSP block for division
        )(
            // Inputs
            input  logic clk,
            input  logic rst,
            input  logic i_valid,
            input  logic signed [INT_IN_DATA_WIDTH-1:0] i_data,

            input  logic i_avg_cmd_valid,
            input  logic [$clog2(INT_MAX_AVERAGE_BY)-1:0] i_avg_cmd_data,

            // Outputs
            output logic o_valid_integrated,
            output logic o_valid_averaged,
            output logic signed [INT_IN_DATA_WIDTH + $clog2(INT_MAX_AVERAGE_BY)-1:0] o_data_integrated,
            output logic signed [INT_IN_DATA_WIDTH-1:0] o_data_averaged_guotient,
            output logic signed [INT_DIVISOR_WIDTH-1:0] o_data_averaged_remainder
        );


        // Declare Constants
        localparam ACC_WIDTH = $clog2(INT_MAX_AVERAGE_BY) + INT_IN_DATA_WIDTH;

        // Declare signals
        logic valid_dsp_ipipe;
        logic signed [ACC_WIDTH-1:0] data_dsp_ipipe;

        logic valid_integrated;
        logic valid_averaged;
        logic increment_allowed = 1'b1;
        logic [$clog2(INT_MAX_AVERAGE_BY)-1:0] counter_averaging_valid = 0;
        logic i_valid_delayed;
        logic [INT_MAX_AVERAGE_BY-1:0] valid_buffer = 0;
        logic signed [INT_IN_DATA_WIDTH-1:0] reg_i_data_splitted [INT_MAX_AVERAGE_BY-1:0]; // reduce fanout and supports better placement
        logic [INT_MAX_AVERAGE_BY-1:0] reg_i_valid_splitted;
        logic signed [ACC_WIDTH-1:0] reg_added_accumulated [INT_MAX_AVERAGE_BY-1:0]; // Add & accumulate for signal integration
        (* USE_DSP = "YES" *) logic signed [ACC_WIDTH-1:0] reg_dsp_accumulator;
        (* USE_DSP = "YES" *) logic signed [INT_IN_DATA_WIDTH + INT_DIVISOR_WIDTH-1:0] reg_dsp_integrated_data_divided; // Stores divided data after integration

        logic [$clog2(INT_MAX_AVERAGE_BY)-1:0] avg_cmd_data_sampled = 0;
        logic [$clog2(INT_MAX_AVERAGE_BY)-1:0] actual_accumulate_max_value = ($clog2(INT_MAX_AVERAGE_BY))'(INT_MAX_AVERAGE_BY-1);

        // Division using DSP48E1: Find the reciprocal of the divisor
        logic signed [INT_DIVISOR_WIDTH-1:0] divisor = INT_DIVISOR_WIDTH'(
            (1.0/INT_MAX_AVERAGE_BY) * (2.0**(INT_DIVISOR_WIDTH) -1.0)
        );


        // Integration
        // Indicator of when to output averaged data
        assign o_valid_integrated = valid_integrated;
        assign o_data_integrated = reg_dsp_accumulator;

        always_ff @(posedge clk) begin

            // Delay the latched input signel
            // avg_cmd_data_sampled <= i_avg_cmd_data;
            // actual_accumulate_max_value <= avg_cmd_data_sampled;

            // Update the accumulate value
            if (i_avg_cmd_valid == 1'b1) begin
                counter_averaging_valid <= 0; // Reset the cntr when update is requested
                increment_allowed <= 0;
                // avg_cmd_data_sampled <= i_avg_cmd_data;
                actual_accumulate_max_value <= i_avg_cmd_data;

                valid_dsp_ipipe <= 0;
                data_dsp_ipipe <= 0;
                valid_integrated <= 0;

                // This is to prevent incrementation when no averaging (actual_accumulate_max_value == 0) is to be performed
                if (i_avg_cmd_data == 0) begin
                    increment_allowed <= 0;
                end else begin
                    increment_allowed <= 1'b1;
                end

            end else begin

                // Start counting until the element before the last one will be processed indicating the next i_valid will be the valid_averaged
                valid_integrated <= 1'b0;

                // Send data from a register to the DSP block, thus delay them by 1 clk
                valid_dsp_ipipe <= i_valid;
                data_dsp_ipipe <= {{(ACC_WIDTH+1-INT_IN_DATA_WIDTH){i_data[INT_IN_DATA_WIDTH-1]}}, i_data[INT_IN_DATA_WIDTH-2:0]};

                if (valid_dsp_ipipe == 1'b1) begin
                    counter_averaging_valid <= counter_averaging_valid + increment_allowed;
                    // if (counter_averaging_valid == ($clog2(INT_MAX_AVERAGE_BY))'(INT_MAX_AVERAGE_BY-1)) begin
                    if (counter_averaging_valid == actual_accumulate_max_value) begin
                        counter_averaging_valid <= 0;
                        valid_integrated <= 1'b1;
                    end
                end

            end
        end

        // Accumulate
        always @(posedge clk) begin
            if (valid_dsp_ipipe == 1'b1) begin
                if (counter_averaging_valid == 0) begin
                    reg_dsp_accumulator <= data_dsp_ipipe;
                end else begin
                    reg_dsp_accumulator <= reg_dsp_accumulator + data_dsp_ipipe;
                end
            end
        end

        // Averaging
        // Perform coherent integration: add all samples together and then divide them by "INT_MAX_AVERAGE_BY"
        assign o_data_averaged_guotient = reg_dsp_integrated_data_divided[INT_IN_DATA_WIDTH + INT_DIVISOR_WIDTH-1 : INT_DIVISOR_WIDTH];
        assign o_data_averaged_remainder = reg_dsp_integrated_data_divided[INT_DIVISOR_WIDTH-1 : 0];
        assign o_valid_averaged = valid_averaged;
        always_ff @(posedge clk) begin
            valid_averaged <= valid_integrated;
            reg_dsp_integrated_data_divided <= reg_dsp_accumulator * divisor;
        end



        // *** Uncomment the lines below for Pipelined version ***
        // // Indictor of when to output averaged data
        // assign o_valid_integrated = valid_integrated;
        // always_ff @(posedge clk) begin

        //     // Always shift the valid_buffer flag on valid
        //     i_valid_delayed <= i_valid;

        //     if (i_valid_delayed == 1'b1) begin
        //         valid_buffer[0] <= ~valid_buffer[INT_MAX_AVERAGE_BY-1]; // Johnson counter, goes together with data integration pipelines
        //         for (int i = 0; i < INT_MAX_AVERAGE_BY; i = i + 1) begin
        //             valid_buffer[i+1] <= valid_buffer[i];
        //         end
        //         o_valid_lock <= 1'b1;
        //     end


        //     // Output valid logic
        //     valid_integrated <= 1'b0;

        //     // Output pulsed valid signal
        //     if ((valid_buffer[INT_MAX_AVERAGE_BY-1]) == (valid_buffer[0])) begin
        //         o_valid_pulse_lock <= 1'b1;
        //         if ((o_valid_lock == 1'b1) && (o_valid_pulse_lock == 1'b0)) begin
        //             valid_integrated <= 1'b1;
        //         end
        //     end else begin
        //         // Release pulse lock
        //         o_valid_pulse_lock <= 1'b0;
        //     end
        // end

        // Transposed Pipelined Add and Accumulate: Too resource intensive
        // assign o_valid_integrated = valid_buffer[INT_MAX_AVERAGE_BY+1];
        // always_ff @(posedge clk) begin

        //     // Version 1
        //     for (int i = 0; i < INT_MAX_AVERAGE_BY; i = i + 1) begin
        //         reg_i_data_splitted[i] <= i_data;
        //         reg_i_valid_splitted[i] <= i_valid;
        //     end


        //     // Orders less than N have accumulators // APPLY VALID ALSO HERE!!
        //     for (int i = 0; i < INT_MAX_AVERAGE_BY-1; i = i + 1) begin
        //         if (reg_i_valid_splitted[i] == 1'b1) begin
        //             reg_added_accumulated[i] <= reg_i_data_splitted[i] + reg_added_accumulated[i+1];
        //         end
        //     end

        //     // Highest order does not have an accumulator
        //     if (reg_i_valid_splitted[INT_MAX_AVERAGE_BY-1] == 1'b1) begin
        //         reg_added_accumulated[INT_MAX_AVERAGE_BY-1] <= reg_i_data_splitted[INT_MAX_AVERAGE_BY-1];
        //     end
        // end


        // Perform coherent integration: add all samples together and divide them by "INT_MAX_AVERAGE_BY"
        // assign o_data = reg_dsp_integrated_data_divided;
        // always_ff @(posedge clk) begin
            // reg_dsp_integrated_data_divided[$clog2((2**INT_IN_DATA_WIDTH)/INT_MAX_AVERAGE_BY)-1:0] <= reg_added_accumulated[0][$clog2((2**INT_IN_DATA_WIDTH)/INT_MAX_AVERAGE_BY)-1:0] / INT_MAX_AVERAGE_BY;
        // end


    endmodule