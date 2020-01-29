library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use work.utils.all;

entity stopwatch is
    port ( 
		clk: in std_logic;
		btnU : in std_logic;
		btnD : in std_logic;
		btnC : in std_logic;
		seg : out std_logic_vector(6 downto 0);
		an : out std_logic_vector(3 downto 0);
		led : out std_logic_vector(15 downto 0));
end stopwatch;

architecture Behavioral of stopwatch is
    constant WaitPeriodS    : Real := 0.1;
    constant ClockSpeedHz   : Integer := 100e6;
    constant MaxCount       : Integer := 9999;

    type AlarmState is (Setting, Counting, Alarming);
    signal state            : AlarmState := Setting;
    signal state_next       : AlarmState := Setting;

    signal counterNum : unsigned(clog2(MaxCount)-1 downto 0);
    signal displayNum : unsigned(clog2(MaxCount)-1 downto 0);

    signal rst : std_logic := '0';

    -- Alarm setting signals
    signal up_pressed       : std_logic;
    signal down_pressed     : std_logic;
    signal center_pressed   : std_logic;
    signal increment        : std_logic;
    signal decrement        : std_logic;

    -- Alarm counting signals
    signal secondCounter      : unsigned(clog2(ClockSpeedHz)-1 downto 0) := (others => '0');
    signal countdown          : unsigned(clog2(MaxCount)-1 downto 0);

begin
    ButtonUp        : entity work.debouncer port map(i_clk => clk, b_in => btnU, b_out => up_pressed);
    ButtonDown      : entity work.debouncer port map(i_clk => clk, b_in => btnD, b_out => down_pressed);
    ButtonCenter    : entity work.debouncer port map(i_clk => clk, b_in => btnC, b_out => center_pressed);
    Counter         : entity work.counter port map(i_clk => clk, i_rst => rst, i_incr => increment, i_decr => decrement, o_val => counterNum);
    Display         : entity work.display port map(i_clk => clk, i_num => displayNum, o_cathode => seg, o_anode => an);

    -- Only allow counter changes in Setting state        
    increment <= up_pressed when state = Setting else '0';
    decrement <= down_pressed when state = Setting else '0';

    displayNum <= counterNum when state = Setting else countdown;
    led(0) <= increment;

    process (clk) is begin
        if rising_edge(clk) then
            state <= state_next;
        end if;
    end process;

    -- refactor this...
    process (clk) is begin
        if rising_edge(clk) then
            state_next      <= state;
            secondCounter   <= secondCounter;
            led(1)          <= '0';
            countdown       <= countdown;
            rst             <= '0';

            case state is
                when Setting =>
                    if center_pressed = '1' then
                        state_next <= Counting;
                        countdown <= counterNum;
                    end if;

                when Counting =>
                    secondCounter <= secondCounter+1;
                    if secondCounter = ClockSpeedHz then
                        secondCounter <= (others => '0');
                        countdown <= countdown-1;
                        if countdown = 0 then
                            state_next <= Alarming;
                        end if;
                    end if;

                when Alarming =>
                    led(1) <= '1';
                    secondCounter <= secondCounter+1;
                    countdown <= (others => '0');
                    if secondCounter = ClockSpeedHz then
                        state_next <= Setting;
                        secondCounter <= (others => '0');
                        rst <= '1';
                    end if;
            end case;
        end if;
    end process;
end Behavioral;
