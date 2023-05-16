    -- charbuf.vhd: sampling incoming bits "IN_DATA"
    --              Reset will be ON when "1" -> will put "reg_buff_inbits" to zero
    --              Reset will be OFF when "0" -> reg_buff_inbits keeps loading IN_DATA if PULSE_TRIGGER = 1

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    entity top_redpitaya_daq_wrapper is
        generic (
            INT_DSP_BYPASS : natural := 1;
            INT_ADC_CHANNELS : natural := 2;
            INT_DAC_CHANNELS : natural := 2;
            INT_DATA_CH1_WIDTH : natural := 10;
            INT_DATA_CH2_WIDTH : natural := 10;
            INT_OUT_DATA_CH1_WIDTH : natural := 10;
            INT_OUT_DATA_CH2_WIDTH : natural := 10;
            INT_AXIS_DATA_WIDTH : natural := 32
        );
        port (

            -- Peripheral Inputs
            in_adc_clk : in std_logic;
            in_data_ch1 : in std_logic_vector(INT_DATA_CH1_WIDTH-1 downto 0);
            in_data_ch2 : in std_logic_vector(INT_DATA_CH2_WIDTH-1 downto 0);

            -- Peripheral Outputs
            dac_o_data : out std_logic_vector(INT_OUT_DATA_CH1_WIDTH-1 downto 0);
            dac_o_iqsel : out std_logic;

            dac_o_iqclk : out std_logic;
            dac_o_iqwrt : out std_logic;
            dac_o_iqrst : out std_logic;
            adc_i_clkstb : out std_logic;

            leds : out std_logic_vector(8-1 downto 0);

            -- AXI4 Lite Signals
            aclk : in std_logic;

            -- // FIFO read ctrl
            o_fifo_data_ch1 : out std_logic_vector(INT_DATA_CH1_WIDTH-1 downto 0);
            o_fifo_data_ch1_valid : out std_logic;
            i_fifo_rd_dready : in std_logic
            
        );
    end entity top_redpitaya_daq_wrapper;

    architecture str of top_redpitaya_daq_wrapper is

        

    begin

        -- Wrap the top module so that it appears that it has no other internal modules
        -- It will be then possible to add it to the board file
        inst_top_redpitaya_daq : entity top_redpitaya_daq
        generic map (
            INT_DSP_BYPASS => 1,
            INT_ADC_CHANNELS => 2,
            INT_DAC_CHANNELS => 2,
            INT_DATA_CH1_WIDTH => 10,
            INT_DATA_CH2_WIDTH => 10,
            INT_OUT_DATA_CH1_WIDTH => 10,
            INT_OUT_DATA_CH2_WIDTH => 10,
            INT_AXIS_DATA_WIDTH => 32
        )
        port map (
            -- Peripheral Inputs
            in_adc_clk => in_adc_clk,
            in_data_ch1 => in_data_ch1,
            in_data_ch2 => in_data_ch2,

            -- Peripheral Outputs
            dac_o_data => dac_o_data,
            dac_o_iqsel => dac_o_iqsel,
            dac_o_iqclk => dac_o_iqclk,
            dac_o_iqwrt => dac_o_iqwrt,
            dac_o_iqrst => dac_o_iqrst,
            adc_i_clkstb => adc_i_clkstb,

            leds => leds,

            aclk => aclk,

            -- FIFO read ctrl
            o_fifo_data_ch1 => o_fifo_data_ch1,
            o_fifo_data_ch1_valid => o_fifo_data_ch1_valid,
            i_fifo_rd_dready => i_fifo_rd_dready
        );


    end architecture;