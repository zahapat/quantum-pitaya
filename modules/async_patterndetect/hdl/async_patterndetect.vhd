library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity async_patterndetect is
    generic (
        NATURAL_INPUT_IS_INVERTED : integer := 0;
        POSITIVE_DOWNSAMPLING : positive := 1; -- POSITIVE_DOWNSAMPLING 1 means no downsampling, 0 is not accepted
        POSITIVE_PATTERN_WIDTH : positive := 3;
        NATURAL_PATTERN : natural := 2**10-1; -- high level when NATURAL_INPUT_IS_INVERTED = 0
        STATIC_DELAY_CYCLES : positive := 25;
        VARIABLE_DELAY_CYCLES_1 : natural := 5; -- Added to STATIC_DELAY_CYCLES, Set (Maximal & Initial) Delay Value after device programming - can be changed by in_update_variable_delay_cycles_X port
        VARIABLE_DELAY_CYCLES_2 : natural := 5  -- Added to STATIC_DELAY_CYCLES, Set (Maximal & Initial) Delay Value after device programming - can be changed by in_update_variable_delay_cycles_X port
    );
    port (
        clk          : in  std_logic;
        in_async_sig : in  std_logic;
        out_sync_pattern_present : out std_logic;
        out_sync_pattern_posedge : out std_logic;
        out_sync_pattern_negedge : out std_logic;
        out_sync_event_posedge   : out std_logic;
        out_sync_event_negedge   : out std_logic;
        out_sync_pattern_posedge_delayed : out std_logic;
        out_sync_pattern_posedge_delayed_latched : out std_logic;
        in_sync_pattern_posedge_delayed_latched_pulldown : in std_logic;

        -- Update the delay due to the changes on variables, such as updated INT_DDC_MAX_DOWNSAMPLING
        in_update_variable_delay_cycles_1_valid : in std_logic;
        in_update_variable_delay_cycles_1_data : in std_logic_vector(integer(ceil(log2(real(VARIABLE_DELAY_CYCLES_1)))) downto 0);
        in_update_variable_delay_cycles_2_valid : in std_logic;
        in_update_variable_delay_cycles_2_data : in std_logic_vector(integer(ceil(log2(real(VARIABLE_DELAY_CYCLES_2)))) downto 0)
    );
end async_patterndetect;

architecture rtl of async_patterndetect is

    -- Ports
    -- nFF Synchronizer
    function init_bit return std_logic is
    begin
        if NATURAL_INPUT_IS_INVERTED = 1 then
            return '1';
        else
            return '0';
        end if;
    end function;
    signal sl_async_sig_flop1 : std_logic := init_bit;
    signal sl_async_sig_flop2 : std_logic := init_bit;
    signal sl_async_sig_inv_or_notinv : std_logic := init_bit;

    -- Counter
    signal int_clkdiv_counter : natural := 0;
    signal sl_sample_enable   : std_logic := '0';

    -- Shift Register (one-liner, variable length)
    signal sl_shiftreg_pattern : std_logic_vector(POSITIVE_PATTERN_WIDTH-1 downto 0) := (others => '0');
    signal sl_pattern_present : std_logic := '0';
    signal sl_pattern_present_p1 : std_logic := '0';
    signal sync_pulse_posedge : std_logic := '0';
    signal sync_pulse_negedge : std_logic := '0';
    signal sync_event_posedge : std_logic := '0';
    signal sync_event_negedge : std_logic := '0';
    signal sync_pattern_posedge_delayed_latched : std_logic := '0';

    -- Delayed trigger logic
    constant TOTAL_MAX_DELAY : natural := STATIC_DELAY_CYCLES + VARIABLE_DELAY_CYCLES_1 + VARIABLE_DELAY_CYCLES_2;
    signal slv_shiftreg_delayed_posedge : std_logic_vector(TOTAL_MAX_DELAY downto 0) := (others => '0');
    signal int_delay_trig_counter : natural := 0;
    signal sl_delay_trig_counter_en : std_logic := '0';
    signal sync_event_posedge_delayed : std_logic := '0';

    -- Total Configurable Delay Logic
    signal slv_capture_delay_cycles_1 : std_logic_vector(integer(ceil(log2(real(VARIABLE_DELAY_CYCLES_1)))) downto 0)
        := std_logic_vector(to_unsigned (VARIABLE_DELAY_CYCLES_1, 1+integer(ceil(log2(real(VARIABLE_DELAY_CYCLES_1)))) ));
    signal slv_capture_delay_cycles_2 : std_logic_vector(integer(ceil(log2(real(VARIABLE_DELAY_CYCLES_2)))) downto 0)
        := std_logic_vector(to_unsigned (VARIABLE_DELAY_CYCLES_2, 1+integer(ceil(log2(real(VARIABLE_DELAY_CYCLES_2)))) ));
    signal slv_capture_delay_cycles_12_added : std_logic_vector(integer(ceil(log2(real(VARIABLE_DELAY_CYCLES_1+VARIABLE_DELAY_CYCLES_2)))) downto 0)
        := std_logic_vector(to_unsigned (VARIABLE_DELAY_CYCLES_1+VARIABLE_DELAY_CYCLES_2, 1+integer(ceil(log2(real(VARIABLE_DELAY_CYCLES_1+VARIABLE_DELAY_CYCLES_2)))) ));

    -- REVISE THIS PART OF THE CODE !
    -- Binary address to one-hot (bit enable) conversion
    function init_onehot_vector return std_logic_vector is
        variable var_onehot_vector : std_logic_vector(TOTAL_MAX_DELAY downto 0) := (others => '0');
    begin
        var_onehot_vector(TOTAL_MAX_DELAY) := '1';
        return var_onehot_vector;
    end function;
    signal slv_capture_total_delay_cycles_added : std_logic_vector(integer(ceil(log2(real(TOTAL_MAX_DELAY)))) downto 0) := std_logic_vector(to_unsigned (TOTAL_MAX_DELAY, 1+integer(ceil(log2(real(TOTAL_MAX_DELAY)))) ));
    signal slv_capture_total_delay_cycles_added_onehot : std_logic_vector(TOTAL_MAX_DELAY downto 0) := init_onehot_vector;


begin

    ---------------------------------------------------
    -- 2-FlipFlop Synchronizer
    ---------------------------------------------------
    -- Analog signal is being sampled each clock cycle on 'sl_async_sig_flop1'
    -- Metastable data will be stabilized on 'sl_async_sig_flop2' the next clk
    proc_2ff_synchronizer : process(clk)
    begin
        -- Connect asynchronous signal (in_async_sig) straight to a Flip Flop + wait one more clock cycle for the metastable signal to stabilize (at sl_async_sig_flop2)
        if rising_edge(clk) then
            sl_async_sig_flop1 <= in_async_sig;
            sl_async_sig_flop2 <= sl_async_sig_flop1;
        end if;
    end process;

    --  Invert signal 2FF if input analog signal is inverted of not
    gen_input_notinv : if (NATURAL_INPUT_IS_INVERTED = 0) generate
        sl_async_sig_inv_or_notinv <= sl_async_sig_flop2;
    end generate;

    gen_input_inv : if (NATURAL_INPUT_IS_INVERTED /= 0) generate
        sl_async_sig_inv_or_notinv <= not sl_async_sig_flop2;
    end generate;


    ---------------------------------------------------
    -- Downsampling
    ---------------------------------------------------
    -- Create a lower frequency enable signal out of the input clock 'clk'
    -- To make something trigger at a lower rate (here, the Button Debouncer)
    proc_downsampling : process(clk)
    begin
       if rising_edge(clk) then

           -- Default operation: Increment counter every clock cycle
            int_clkdiv_counter <= int_clkdiv_counter + 1;
            sl_sample_enable <= '0';

            -- Count until the maximum value 'POSITIVE_DOWNSAMPLING'
            -- Then reset the counter and send a pulse 'sl_sample_enable'
            if (int_clkdiv_counter = POSITIVE_DOWNSAMPLING-1) then
                int_clkdiv_counter <= 0;
                sl_sample_enable <= '1';
            end if;

       end if;
    end process;


    ---------------------------------------------------
    -- Pattern Detector
    ---------------------------------------------------
    -- Sample the synchronized analog button signal on each 'sl_sample_enable'
    -- In signal processing, this is called 'decimation/downsampling' - noise filter ignoring some noisy values
    out_sync_pattern_present <= sl_pattern_present_p1; -- Send to output
    out_sync_pattern_posedge <= sync_pulse_posedge; -- Send to output
    out_sync_pattern_negedge <= sync_pulse_negedge; -- Send to output
    -- out_sync_pattern_posedge_delayed <= slv_shiftreg_delayed_posedge(slv_shiftreg_delayed_posedge'high); -- Send to output
    out_sync_event_posedge <= sync_event_posedge; -- Send to output
    out_sync_event_negedge <= sync_event_negedge; -- Send to output
    out_sync_pattern_posedge_delayed_latched <= sync_pattern_posedge_delayed_latched;

    proc_btn_debouncer : process(clk)
    begin

        if rising_edge(clk) then

            -- These lines will always perform this operation unless a condition below is met (=deferred assignment)
            sl_pattern_present <= '0';
            sync_pulse_posedge <= '0';
            sync_event_posedge_delayed <= '0';
            sync_pulse_negedge <= '0';
            sl_pattern_present_p1 <= sl_pattern_present; -- 1 Clk delay


            -- Shift register: Append the stabilized data 'sl_async_sig_flop2', shift them left
            -- Negate the value to convert input to positive logic since button logic is inverted (0 = Pushed, 1 = Not Pushed)
            -- 3-bit Shift Reg 'sl_shiftreg_pattern':
            -- t = 0: |0|0|0| -- No activity detected in the channel
            -- t = 1: |0|0|1| -- Button Pressed on "sl_sample_enable" (Rising Edge Detected)
            -- t = 2: |0|1|1| -- Button Pressed on "sl_sample_enable"
            -- t = 3: |1|1|1| -- Button Pressed on "sl_sample_enable"
            -- t = 4: |1|1|0| -- Button Released on "sl_sample_enable" (Falling Edge Detected)

            if (sl_sample_enable = '1') then
                sl_shiftreg_pattern(sl_shiftreg_pattern'high downto 0) 
                    <= sl_shiftreg_pattern(sl_shiftreg_pattern'high-1 downto 0) & sl_async_sig_inv_or_notinv;
            end if;

            -- Detect Shift Register Pattern defined in 'NATURAL_PATTERN'
            if (sl_shiftreg_pattern = std_logic_vector(to_unsigned(NATURAL_PATTERN, sl_shiftreg_pattern'length))) then
                sl_pattern_present <= '1';
            end if;

            -- Send 1 clk signal: Detect positive edge event: compare 'sl_pattern_present_p1' and 'sl_pattern_present' to create a pulsed event signal
            if ((sl_pattern_present = '1') and (sl_pattern_present_p1 = '0')) then
                sync_pulse_posedge <= '1';
                sync_event_posedge <= not sync_event_posedge;
            end if;

            -- Send 1 clk signal: Detect negative edge event: compare 'sl_pattern_present_p1' and 'sl_pattern_present' to create a pulsed event signal
            if ((sl_pattern_present = '0') and (sl_pattern_present_p1 = '1')) then
                sync_pulse_negedge <= '1';
                sync_event_negedge <= not sync_event_negedge;
            end if;

        end if;
    end process;


    ---------------------------------------------------
    -- Triggr Delay Logic
    ---------------------------------------------------
    proc_delay_config : process (slv_capture_total_delay_cycles_added) 
        variable base_or_higher : std_logic_vector(TOTAL_MAX_DELAY downto 0) := (others => '0');
        variable bound_or_lower : std_logic_vector(TOTAL_MAX_DELAY downto 0) := (others => '0');
    begin
        slv_capture_total_delay_cycles_added_onehot <= (others => '0');

        for i in STATIC_DELAY_CYCLES to TOTAL_MAX_DELAY loop
            base_or_higher := (others => '0');
            bound_or_lower := (others => '0');

            if (slv_capture_total_delay_cycles_added >= std_logic_vector(to_unsigned (i, 1+integer(ceil(log2(real(TOTAL_MAX_DELAY)))) )) ) then
                base_or_higher(i) := '1';
            end if;

            if (slv_capture_total_delay_cycles_added <= std_logic_vector(to_unsigned (i, 1+integer(ceil(log2(real(TOTAL_MAX_DELAY)))) )) ) then
                bound_or_lower(i) := '1';
            end if;

            if (base_or_higher(i) = '1') and (bound_or_lower(i) = '1') then
                slv_capture_total_delay_cycles_added_onehot(i) <= '1';
            end if;
        end loop;
    end process;


    proc_total_delay_calc : process(clk)
    begin
        if rising_edge(clk) then
            if (in_update_variable_delay_cycles_1_valid = '1') then
                slv_capture_delay_cycles_1 <= in_update_variable_delay_cycles_1_data;
            end if;
            if (in_update_variable_delay_cycles_2_valid = '1') then
                slv_capture_delay_cycles_2 <= in_update_variable_delay_cycles_2_data;
            end if;

            slv_capture_delay_cycles_12_added <= std_logic_vector(
                '0' & unsigned(slv_capture_delay_cycles_1) + unsigned(slv_capture_delay_cycles_2));

            slv_capture_total_delay_cycles_added <= std_logic_vector(
                to_unsigned(STATIC_DELAY_CYCLES, 1+integer(ceil(log2(real(STATIC_DELAY_CYCLES)))) ) + unsigned(slv_capture_delay_cycles_12_added));
        end if;
    end process;


    proc_delay_control : process(clk)
    begin
        if rising_edge(clk) then

            out_sync_pattern_posedge_delayed <= '0';

            slv_shiftreg_delayed_posedge(slv_shiftreg_delayed_posedge'high downto 0) 
                <= slv_shiftreg_delayed_posedge(slv_shiftreg_delayed_posedge'high-1 downto 0) & sync_pulse_posedge;

            for i in STATIC_DELAY_CYCLES to TOTAL_MAX_DELAY loop
                if (slv_shiftreg_delayed_posedge(i) = slv_capture_total_delay_cycles_added_onehot(i)) and slv_capture_total_delay_cycles_added_onehot(i) = '1' then
                    sync_pattern_posedge_delayed_latched <= '1';
                    out_sync_pattern_posedge_delayed <= '1';
                end if;
            end loop;

            if (in_sync_pattern_posedge_delayed_latched_pulldown = '1') then
                sync_pattern_posedge_delayed_latched <= '0';
            end if;
        end if;
    end process;


end architecture;