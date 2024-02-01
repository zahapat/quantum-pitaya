    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    library work;
    use work.generics.all;

    entity top_redpitaya_125_14_wrapper is
        generic (
            -- Don't touch:
            -- AXI4 Lite Generics
            C_S00_AXI_DATA_WIDTH : integer := 32;
            C_S00_AXI_ADDR_WIDTH : integer := 4;

            -- User:
            -- General IO setup of the module
            INT_DIFF_ADC_CLK       : natural := 0;
            INT_ADC_CHANNELS       : natural := 2;  -- FIXED for this project
            INT_DAC_CHANNELS       : natural := 2;  -- FIXED for this project
            INT_ADC_DATA_CH1_WIDTH : natural := 14; -- FIXED for this project
            INT_ADC_DATA_CH2_WIDTH : natural := 14; -- FIXED for this project
            INT_ADC_DATA_CH1_TRIM_BITS_RIGHT : natural := 1; -- FIXED for this project: Reduce the resolution of the ADC to save resources
            INT_ADC_DATA_CH2_TRIM_BITS_RIGHT : natural := 1; -- FIXED for this project: Reduce the resolution of the ADC to save resources
            INT_DAC_DATA_CH1_WIDTH : natural := 14; -- FIXED for this project
            INT_DAC_DATA_CH2_WIDTH : natural := 14; -- FIXED for this project
            INT_BYPASS_DSP         : natural := INT_BYPASS_DSP;

            -- DDC
            -- Real numbers are not supported by IP packager!
            INT_DDC_NUMBER_OF_TAPS              : natural := INT_DDC_NUMBER_OF_TAPS;  -- Max FIR Order + 1
            INT_DDC_COEF_WIDTH                  : natural := INT_DDC_COEF_WIDTH;          -- Width of each FIR coefficient
            INT_WHOLE_DDC_LOCOSC_IN_FREQ_MHZ    : natural := 125;  -- (e.g. 125) Sampling/Clock frequency the local oscillator is running on
            INT_DECIMAL_DDC_LOCOSC_IN_FREQ_MHZ  : natural := 0;  -- (e.g. 0) Sampling/Clock frequency the local oscillator is running on
            INT_WHOLE_DDC_LOCOSC_OUT_FREQ_MHZ   : natural := INT_WHOLE_DDC_LOCOSC_OUT_FREQ_MHZ;  -- (e.g. 25)  The desired frequency of the local oscillator (sine + cosine)
            INT_DECIMAL_DDC_LOCOSC_OUT_FREQ_MHZ : natural := INT_DECIMAL_DDC_LOCOSC_OUT_FREQ_MHZ;  -- (e.g. 0) The desired frequency of the local oscillator (sine + cosine)

            INT_DDC_OUT_DATA_WIDTH : natural := INT_DDC_OUT_DATA_WIDTH;  -- (e.g. 20) Output data width of the digital downconversion module
            INT_DDC_MAX_DECIMATION : natural := INT_DDC_MAX_DECIMATION;          -- (e.g. 5) The decimation value

            -- Integration & averaging
            INT_AVG_MAX_AVERAGE_BY : natural := INT_AVG_MAX_AVERAGE_BY;     -- (e.g. 5) Enter the number of how many data points are to be averaged
            INT_AVG_DIVISOR_WIDTH  : natural := 28;                  -- (e.g. 28) Set the resolution of the divisor. Config INT_IN_DATA_WIDTH=14 & INT_DIVISOR_WIDTH=28 (total 42 bits) implements 1x DSP block for the division

            -- Multichannel Accumulator
            INT_MULTIACC_FIFO_WIDTH  : natural := 32;
            INT_MULTIACC_FIFO_DEPTH  : natural := INT_MULTIACC_FIFO_DEPTH;
            INT_MULTIACC_CHANNELS    : natural := INT_MULTIACC_CHANNELS;
            INT_MULTIACC_REPETITIONS : natural := INT_MULTIACC_REPETITIONS;

            -- RX Command Parser
            INT_CMD_OUTPUT_WIDTH    : natural := 5;
            INT_MODULE_SELECT_WIDTH : natural := 5;
            INT_MODULES_CMD_CNT     : natural := 13;

            -- Output FIFO Buffer 1, 2 Depth
            INT_OUT_FIFO_BUFFERS_DEPTH : natural := INT_OUT_FIFO_BUFFERS_DEPTH -- Must be a multiple of 2 (because of Gray counter width)
        );
        port (
            -- User:
            -- Peripheral Inputs
            in_adc_clk_p : in std_logic;
            in_adc_clk_n : in std_logic;
            in_data_ch1  : in std_logic_vector(INT_ADC_DATA_CH1_WIDTH-1 downto 0);
            in_data_ch2  : in std_logic_vector(INT_ADC_DATA_CH2_WIDTH-1 downto 0);

            -- Peripheral Outputs
            dac_o_data  : out std_logic_vector(INT_DAC_DATA_CH1_WIDTH-1 downto 0);
            dac_o_iqsel : out std_logic;

            dac_o_iqclk  : out std_logic;
            dac_o_iqwrt  : out std_logic;
            dac_o_iqrst  : out std_logic;
            adc_i_clkstb : out std_logic;

            leds : out std_logic_vector(8-1 downto 0);

            -- External Analog Trigger
            i_acc_trigger_1 : in std_logic;
            i_acc_trigger_2 : in std_logic;


            -- Don't touch:
            -- Ports of Axi Slave Bus Interface S00_AXI
            s00_axi_aclk	: in std_logic;
            s00_axi_aresetn	: in std_logic;
            s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
            s00_axi_awprot	: in std_logic_vector(2 downto 0);
            s00_axi_awvalid	: in std_logic;
            s00_axi_awready	: out std_logic;
            s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
            s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
            s00_axi_wvalid	: in std_logic;
            s00_axi_wready	: out std_logic;
            s00_axi_bresp	: out std_logic_vector(1 downto 0);
            s00_axi_bvalid	: out std_logic;
            s00_axi_bready	: in std_logic;
            s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
            s00_axi_arprot	: in std_logic_vector(2 downto 0);
            s00_axi_arvalid	: in std_logic;
            s00_axi_arready	: out std_logic;
            s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
            s00_axi_rresp	: out std_logic_vector(1 downto 0);
            s00_axi_rvalid	: out std_logic;
            s00_axi_rready	: in std_logic
        );
    end entity top_redpitaya_125_14_wrapper;

    architecture str of top_redpitaya_125_14_wrapper is

        -- Output CDCC FIFO Read Signals
        signal slv_fifo_data_ch1      : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        signal slv_fifo_data_ch2      : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        signal sl_fifo_data_ch1_valid : std_logic;
        signal sl_fifo_data_ch2_valid : std_logic;
        signal sl_fifo_rd_dready_ch1  : std_logic;
        signal sl_fifo_rd_dready_ch2  : std_logic;

        -- Input CDCC FIFO CMD Signals
        signal slv_cmddata_axi_fifo_i_data : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        signal sl_cmddata_axi_fifo_i_valid : std_logic;
        signal sl_cmddata_axi_fifo_o_ready : std_logic;
        signal slv_cmd_axi_fifo_i_data     : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        signal sl_cmd_axi_fifo_i_valid     : std_logic;
        signal sl_cmd_axi_fifo_o_ready     : std_logic;

        -- Monitoring Flags
        signal sl_multiacc_o_acc_valid_i     : std_logic;
        signal sl_multichrdctrl_cmd_dready_i : std_logic;
        signal sl_multichrdctrl_cmd_dready_q : std_logic;

        -- Prevent dividing by zero
        impure function get_divisor (
            constant DIVISOR : integer
        ) return integer is
        begin
            if DIVISOR = 0 then
                return 1;
            else
                return integer(10.0*(floor(log10(real(DIVISOR))) + 1.0));
            end if;
        end function;
        constant REAL_DDC_LOCOSC_IN_FREQ_MHZ_DIVISOR : integer := get_divisor(INT_DECIMAL_DDC_LOCOSC_IN_FREQ_MHZ);
        constant REAL_DDC_LOCOSC_OUT_FREQ_MHZ_DIVISOR : integer := get_divisor(INT_DECIMAL_DDC_LOCOSC_OUT_FREQ_MHZ);

        constant REAL_DDC_LOCOSC_IN_FREQ_MHZ : real := real(INT_WHOLE_DDC_LOCOSC_IN_FREQ_MHZ) + real(INT_DECIMAL_DDC_LOCOSC_IN_FREQ_MHZ) 
            / real(REAL_DDC_LOCOSC_IN_FREQ_MHZ_DIVISOR);
        constant REAL_DDC_LOCOSC_OUT_FREQ_MHZ : real := real(INT_WHOLE_DDC_LOCOSC_OUT_FREQ_MHZ) + real(INT_DECIMAL_DDC_LOCOSC_OUT_FREQ_MHZ) 
            / real(REAL_DDC_LOCOSC_OUT_FREQ_MHZ_DIVISOR);

    begin

        -- Instantiation of Axi Bus Interface S00_AXI
        inst_axi4lite_fifo_readout : entity work.axi4lite_fifo_readout
        generic map (
            -- User
            
            -- Don't touch
            C_S_AXI_DATA_WIDTH => C_S00_AXI_DATA_WIDTH,
            C_S_AXI_ADDR_WIDTH => C_S00_AXI_ADDR_WIDTH
        )
        port map (
            -- User
            i_fifo_data_ch1       => slv_fifo_data_ch1,
            i_fifo_data_ch2       => slv_fifo_data_ch2,
            i_fifo_data_ch1_valid => sl_fifo_data_ch1_valid,
            i_fifo_data_ch2_valid => sl_fifo_data_ch2_valid,
            o_fifo_rd_dready_ch1  => sl_fifo_rd_dready_ch1,
            o_fifo_rd_dready_ch2  => sl_fifo_rd_dready_ch2,

            o_cmddata32b_fifo_i_data  => slv_cmddata_axi_fifo_i_data,
            o_cmddata32b_fifo_i_valid => sl_cmddata_axi_fifo_i_valid,
            i_cmddata32b_fifo_o_ready => sl_cmddata_axi_fifo_o_ready,
            o_cmd32b_fifo_i_data      => slv_cmd_axi_fifo_i_data,
            o_cmd32b_fifo_i_valid     => sl_cmd_axi_fifo_i_valid,
            i_cmd32b_fifo_o_ready     => sl_cmd_axi_fifo_o_ready,

            -- Don't touch
            S_AXI_ACLK      => s00_axi_aclk,
            S_AXI_ARESETN   => s00_axi_aresetn,
            S_AXI_AWADDR	=> s00_axi_awaddr,
            S_AXI_AWPROT	=> s00_axi_awprot,
            S_AXI_AWVALID	=> s00_axi_awvalid,
            S_AXI_AWREADY	=> s00_axi_awready,
            S_AXI_WDATA	    => s00_axi_wdata,
            S_AXI_WSTRB	    => s00_axi_wstrb,
            S_AXI_WVALID	=> s00_axi_wvalid,
            S_AXI_WREADY	=> s00_axi_wready,
            S_AXI_BRESP	    => s00_axi_bresp,
            S_AXI_BVALID	=> s00_axi_bvalid,
            S_AXI_BREADY	=> s00_axi_bready,
            S_AXI_ARADDR	=> s00_axi_araddr,
            S_AXI_ARPROT	=> s00_axi_arprot,
            S_AXI_ARVALID	=> s00_axi_arvalid,
            S_AXI_ARREADY	=> s00_axi_arready,
            S_AXI_RDATA	    => s00_axi_rdata,
            S_AXI_RRESP	    => s00_axi_rresp,
            S_AXI_RVALID	=> s00_axi_rvalid,
            S_AXI_RREADY	=> s00_axi_rready
        );


        -- Wrap the top module so that it appears that it has no other internal modules
        -- It will be then possible to add it to the board file
        inst_top_redpitaya_125_14 : entity work.top_redpitaya_125_14
        generic map (
            -- General IO setup of the module
            INT_DIFF_ADC_CLK       => INT_DIFF_ADC_CLK,
            INT_ADC_CHANNELS       => INT_ADC_CHANNELS,
            INT_DAC_CHANNELS       => INT_DAC_CHANNELS,
            INT_ADC_DATA_CH1_WIDTH => INT_ADC_DATA_CH1_WIDTH,
            INT_ADC_DATA_CH2_WIDTH => INT_ADC_DATA_CH2_WIDTH,
            INT_ADC_DATA_CH1_TRIM_BITS_RIGHT => INT_ADC_DATA_CH1_TRIM_BITS_RIGHT,
            INT_ADC_DATA_CH2_TRIM_BITS_RIGHT => INT_ADC_DATA_CH2_TRIM_BITS_RIGHT,
            INT_DAC_DATA_CH1_WIDTH => INT_DAC_DATA_CH1_WIDTH,
            INT_DAC_DATA_CH2_WIDTH => INT_DAC_DATA_CH2_WIDTH,
            INT_AXIS_DATA_WIDTH    => C_S00_AXI_DATA_WIDTH,
            INT_BYPASS_DSP         => INT_BYPASS_DSP,

            -- DDC
            INT_DDC_NUMBER_OF_TAPS       => INT_DDC_NUMBER_OF_TAPS,
            INT_DDC_COEF_WIDTH           => INT_DDC_COEF_WIDTH,
            REAL_DDC_LOCOSC_IN_FREQ_MHZ  => REAL_DDC_LOCOSC_IN_FREQ_MHZ,
            REAL_DDC_LOCOSC_OUT_FREQ_MHZ => REAL_DDC_LOCOSC_OUT_FREQ_MHZ,
            INT_DDC_OUT_DATA_WIDTH       => INT_DDC_OUT_DATA_WIDTH,
            INT_DDC_MAX_DOWNSAMPLING     => INT_DDC_MAX_DECIMATION,

            -- Integration & averaging
            INT_AVG_MAX_AVERAGE_BY => INT_AVG_MAX_AVERAGE_BY,
            INT_AVG_DIVISOR_WIDTH  => INT_AVG_DIVISOR_WIDTH,

            -- Multichannel Accumulator
            INT_MULTIACC_FIFO_WIDTH  => INT_MULTIACC_FIFO_WIDTH,
            INT_MULTIACC_FIFO_DEPTH  => INT_MULTIACC_FIFO_DEPTH,
            INT_MULTIACC_CHANNELS    => INT_MULTIACC_CHANNELS,
            INT_MULTIACC_REPETITIONS => INT_MULTIACC_REPETITIONS,

            -- RX Command Parser
            INT_CMD_OUTPUT_WIDTH    => INT_CMD_OUTPUT_WIDTH,
            INT_MODULE_SELECT_WIDTH => INT_MODULE_SELECT_WIDTH,
            INT_MODULES_CMD_CNT     => INT_MODULES_CMD_CNT,

            -- Output FIFO Buffer 1, 2 Depth
            INT_OUT_FIFO_BUFFER1_DEPTH => INT_OUT_FIFO_BUFFERS_DEPTH,
            INT_OUT_FIFO_BUFFER2_DEPTH => INT_OUT_FIFO_BUFFERS_DEPTH
        )
        port map (

            -- AXI4 Lite Signals
            aclk => s00_axi_aclk,
        
            -- Peripheral Inputs
            in_adc_clk_p  => in_adc_clk_p,
            in_adc_clk_n  => in_adc_clk_n,
            in_data_ch1 => in_data_ch1,
            in_data_ch2 => in_data_ch2,

            -- Peripheral Outputs
            dac_o_data   => dac_o_data,
            dac_o_iqsel  => dac_o_iqsel,
            dac_o_iqclk  => dac_o_iqclk,
            dac_o_iqwrt  => dac_o_iqwrt,
            dac_o_iqrst  => dac_o_iqrst,
            adc_i_clkstb => adc_i_clkstb,

            leds => leds,

            -- Accumulator Ready
            o_multiacc_o_acc_valid_i => sl_multiacc_o_acc_valid_i,

            -- Output CDCC FIFO Read Signals
            o_fifo_data_ch1       => slv_fifo_data_ch1,
            o_fifo_data_ch2       => slv_fifo_data_ch2,
            o_fifo_data_ch1_valid => sl_fifo_data_ch1_valid,
            o_fifo_data_ch2_valid => sl_fifo_data_ch2_valid,
            i_fifo_rd_dready_ch1  => sl_fifo_rd_dready_ch1,
            i_fifo_rd_dready_ch2  => sl_fifo_rd_dready_ch2,

            -- Input CDCC FIFO CMD Signals
            i_cmddata_axi_fifo_i_data  => slv_cmddata_axi_fifo_i_data,
            i_cmddata_axi_fifo_i_valid => sl_cmddata_axi_fifo_i_valid,
            o_cmddata_axi_fifo_o_ready => sl_cmddata_axi_fifo_o_ready,
            i_cmd_axi_fifo_i_data      => slv_cmd_axi_fifo_i_data,
            i_cmd_axi_fifo_i_valid     => sl_cmd_axi_fifo_i_valid,
            o_cmd_axi_fifo_o_ready     => sl_cmd_axi_fifo_o_ready,

            -- Multichannel Read Control: Next Read Command Ready Flag
            o_multichrdctrl_cmd_dready_i => sl_multichrdctrl_cmd_dready_i,
            o_multichrdctrl_cmd_dready_q => sl_multichrdctrl_cmd_dready_q,

            -- External Analog Trigger
            i_acc_trigger_1 => i_acc_trigger_1,
            i_acc_trigger_2 => i_acc_trigger_2
        );


    end architecture;