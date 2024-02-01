library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.finish; -- Uncomment this if you simulate using Modelsim/Questasim, otherwise leave commented

use std.textio.all;

entity async_patterndetect_tb is
end async_patterndetect_tb;

architecture sim of async_patterndetect_tb is

    -- DUT Generics
    constant NATURAL_INPUT_IS_INVERTED : integer := 0;
    constant POSITIVE_DOWNSAMPLING : positive  := 1;  -- POSITIVE_DOWNSAMPLING 1 means no downsampling, 0 is not accepted
    constant POSITIVE_PATTERN_WIDTH : positive := 3; -- width of the buffer
    constant NATURAL_PATTERN : natural := 2**POSITIVE_PATTERN_WIDTH-1; -- Detect high Level   (e.g. 1111)
    -- constant NATURAL_PATTERN : natural := 0; -- Detect low Level                              (e.g. 0000)
    -- constant NATURAL_PATTERN : natural := 2**POSITIVE_PATTERN_WIDTH-2; -- Detect falling edge (e.g. 1110)
    -- constant NATURAL_PATTERN : natural := 1; -- Detect rising edge                            (e.g. 0001)
    constant STATIC_DELAY_CYCLES : positive := 100;
    constant VARIABLE_DELAY_CYCLES_1 : natural := 5-1; -- Decrement the target value by 1; Added to STATIC_DELAY_CYCLES, Set (Maximal & Initial) Delay Value after device programming - can be changed by in_update_variable_delay_cycles_X port
    constant VARIABLE_DELAY_CYCLES_2 : natural := 5-1; -- Decrement the target value by 1; Added to STATIC_DELAY_CYCLES, Set (Maximal & Initial) Delay Value after device programming - can be changed by in_update_variable_delay_cycles_X port


    constant TOTAL_MAX_DELAY : natural := STATIC_DELAY_CYCLES + VARIABLE_DELAY_CYCLES_1 + VARIABLE_DELAY_CYCLES_2;


    -- Simulation Settings : Pulse Modelling
    function init_bit return std_logic is
    begin
        if NATURAL_INPUT_IS_INVERTED = 1 then
            return '1';
        else
            return '0';
        end if;
    end function;
    constant ANALOG_PULSE_HIGH_NS : time := 100 ns;
    constant ANALOG_PULSE_LOW_NS : time := 1000 ns;
    constant ANALOG_HIGH_VALUE : std_logic := not init_bit;
    constant ANALOG_LOW_VALUE : std_logic := init_bit;

    constant PULSES_COUNT : positive := (VARIABLE_DELAY_CYCLES_1+1) * (VARIABLE_DELAY_CYCLES_2+1);

    constant EDGE_OSCILLATIONS : positive := 3; -- 1 means no oscillations will be generated
    constant MIN_OSCILLATION_DURATION_NS : real := 1.0;

    -- Simulation Settings : Clock Modelling
    constant CLK_HZ : real := 125.0e6;
    constant CLK_PERIOD : time := 1 sec / CLK_HZ;


    -- DUT Ports
    signal clk : std_logic := '1';
    signal in_async_sig : std_logic := init_bit;
    signal out_sync_pattern_present : std_logic;
    signal out_sync_pattern_posedge : std_logic;
    signal out_sync_pattern_negedge : std_logic;
    signal out_sync_pattern_posedge_delayed : std_logic;
    signal out_sync_event_posedge : std_logic;
    signal out_sync_event_negedge : std_logic;
    signal out_sync_pattern_posedge_delayed_latched : std_logic;
    signal in_sync_pattern_posedge_delayed_latched_pulldown : std_logic := '0';

    signal in_update_variable_delay_cycles_1_valid : std_logic := '0';
    signal in_update_variable_delay_cycles_1_data : std_logic_vector(integer(ceil(log2(real(VARIABLE_DELAY_CYCLES_1)))) downto 0) := (others => '0');
    signal in_update_variable_delay_cycles_2_valid : std_logic := '0';
    signal in_update_variable_delay_cycles_2_data : std_logic_vector(integer(ceil(log2(real(VARIABLE_DELAY_CYCLES_2)))) downto 0) := (others => '0');

    -- Print to console "TEST OK."
    procedure print_test_ok is
        variable str : line;
    begin
        write(str, string'("TEST OK."));
        writeline(output, str);
    end procedure;

begin

    -- Create a Clock Generator
    clk <= not clk after CLK_PERIOD / 2;

    -- Instantiate the Device Under Test
    dut : entity work.async_patterndetect(rtl)
    generic map (
        NATURAL_INPUT_IS_INVERTED => NATURAL_INPUT_IS_INVERTED,
        POSITIVE_DOWNSAMPLING  => POSITIVE_DOWNSAMPLING,
        POSITIVE_PATTERN_WIDTH  => POSITIVE_PATTERN_WIDTH,
        NATURAL_PATTERN => NATURAL_PATTERN,
        STATIC_DELAY_CYCLES => STATIC_DELAY_CYCLES,
        VARIABLE_DELAY_CYCLES_1 => VARIABLE_DELAY_CYCLES_1, -- Added to STATIC_DELAY_CYCLES, Set (Maximal & Initial) Delay Value after device programming - can be changed by in_update_variable_delay_cycles_X port
        VARIABLE_DELAY_CYCLES_2 => VARIABLE_DELAY_CYCLES_2  -- Added to STATIC_DELAY_CYCLES, Set (Maximal & Initial) Delay Value after device programming - can be changed by in_update_variable_delay_cycles_X port
    )
    port map (
        clk                      => clk,
        in_async_sig             => in_async_sig,
        out_sync_pattern_present => out_sync_pattern_present,
        out_sync_pattern_posedge => out_sync_pattern_posedge,
        out_sync_pattern_negedge => out_sync_pattern_negedge,
        out_sync_event_posedge   => out_sync_event_posedge,
        out_sync_event_negedge   => out_sync_event_negedge,
        out_sync_pattern_posedge_delayed => out_sync_pattern_posedge_delayed,
        out_sync_pattern_posedge_delayed_latched => out_sync_pattern_posedge_delayed_latched,
        in_sync_pattern_posedge_delayed_latched_pulldown => in_sync_pattern_posedge_delayed_latched_pulldown,

        in_update_variable_delay_cycles_1_valid => in_update_variable_delay_cycles_1_valid,
        in_update_variable_delay_cycles_1_data => in_update_variable_delay_cycles_1_data,
        in_update_variable_delay_cycles_2_valid => in_update_variable_delay_cycles_2_valid,
        in_update_variable_delay_cycles_2_data => in_update_variable_delay_cycles_2_data
    );


    -----------------------------------------------
    -- DUT Input Driver
    -----------------------------------------------
    proc_sequencer : process
    begin

        -- Wait for the generator to propagate data to out
        wait for (PULSES_COUNT+EDGE_OSCILLATIONS)/2*1 us;

        -- Record and assert pseudorandom output bits and compare them with the generated Galois Field symbol bits
        report "Test #1: Create a noisy oscillator and detect rising edges";
        for i in PULSES_COUNT-1 downto 0 loop
            -- Constant low
            in_async_sig <= ANALOG_LOW_VALUE;
            wait for ANALOG_PULSE_LOW_NS;


            -- Noisy transition from low to high
            for u in EDGE_OSCILLATIONS-1 downto 0 loop
                -- Modelling the noise during falling edge: reduce duty cycle slowly
                wait for CLK_PERIOD*u + MIN_OSCILLATION_DURATION_NS*1 ns;
                in_async_sig <= not in_async_sig;
                wait for CLK_PERIOD*(EDGE_OSCILLATIONS-1-u) + MIN_OSCILLATION_DURATION_NS*1 ns;
                in_async_sig <= not in_async_sig;
            end loop;
            in_async_sig <= ANALOG_HIGH_VALUE;


            -- Constant high
            wait for ANALOG_PULSE_HIGH_NS;


            -- Noisy transition from high to low
            for u in EDGE_OSCILLATIONS-1 downto 0 loop
                -- Modelling the noise during rising edge: increase duty cycle slowly
                wait for CLK_PERIOD*u + MIN_OSCILLATION_DURATION_NS*1 ns;
                in_async_sig <= not in_async_sig;
                wait for CLK_PERIOD*(EDGE_OSCILLATIONS-1-u) + MIN_OSCILLATION_DURATION_NS*1 ns;
                in_async_sig <= not in_async_sig;
            end loop;

            in_async_sig <= ANALOG_LOW_VALUE;
        end loop;

        wait for (PULSES_COUNT+EDGE_OSCILLATIONS)/2*1 us;

        wait;
    end process;

    -----------------------------------------------
    -- Test Pulldown Logic
    -----------------------------------------------
    proc_pulldown_sequencer: process
    begin

        wait until rising_edge(out_sync_pattern_posedge_delayed_latched);
        in_sync_pattern_posedge_delayed_latched_pulldown <= '1';

        wait for 30 ns;
        in_sync_pattern_posedge_delayed_latched_pulldown <= '0';

        wait until rising_edge(out_sync_pattern_posedge_delayed_latched);
        in_sync_pattern_posedge_delayed_latched_pulldown <= '1';

        wait for 30 ns;
        in_sync_pattern_posedge_delayed_latched_pulldown <= '0';

        wait;
    end process;


    -----------------------------------------------
    -- Test Setting Delay Time
    -----------------------------------------------
    proc_delay_config: process
    begin

        -- Wait for the first pulse
        wait for (PULSES_COUNT+EDGE_OSCILLATIONS-1)/2*1 us;

        -- Set internal signal to ...
        for i in VARIABLE_DELAY_CYCLES_1 downto 0 loop
            in_update_variable_delay_cycles_1_valid <= '1';
            in_update_variable_delay_cycles_1_data <= std_logic_vector(to_unsigned(i, in_update_variable_delay_cycles_1_data'length));

            for i in VARIABLE_DELAY_CYCLES_2 downto 0 loop
                in_update_variable_delay_cycles_2_valid <= '1';
                in_update_variable_delay_cycles_2_data <= std_logic_vector(to_unsigned(i, in_update_variable_delay_cycles_2_data'length));

                wait until rising_edge(clk);
                in_update_variable_delay_cycles_1_valid <= '0';
                in_update_variable_delay_cycles_2_valid <= '0';

                wait until rising_edge(out_sync_pattern_posedge_delayed);
            end loop;

        end loop;

        wait for 5000 ns;

        print_test_ok;
        finish;
        wait;
    end process;


end architecture;