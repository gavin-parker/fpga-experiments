library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use work.utils.all;

entity stopwatch_tb is
end stopwatch_tb;

architecture TestBench of stopwatch_tb is
    constant DebouncePeriod     : time := 100ms;
    constant DebouncePeriodS    : Real := 0.1;

    constant MaxCount       : Integer := 9;
    constant ClockSpeedHz : Integer := 100e6;
    constant ClockPeriod : time := 1sec / ClockSpeedHz;

    signal counter_val  : unsigned(clog2(MaxCount)-1 downto 0);
    signal clk          : std_logic := '0';
    signal b_in         : std_logic := '0';
    signal b_out        : std_logic;

begin

    Debouncer : entity work.debouncer 
    generic map (WaitPeriodS => DebouncePeriodS, ClockSpeedHz => ClockSpeedHz) 
    port map (i_clk => clk, b_in => b_in, b_out => b_out);

    Counter : entity work.counter 
    generic map (MaxValue => MaxCount)
    port map (i_clk => clk, i_incr => b_out, o_val => counter_val);

    clk <= not clk after ClockPeriod / 2;
    test_stopwatch : process
        begin
            for i in 0 to 9 loop
                b_in <= '1';
                wait for DebouncePeriod*1.1;
                b_in <= '0';
                assert counter_val = i report "Unexpected counter value" severity error;
                wait for DebouncePeriod;
            end loop;
            wait;
        end process;
end TestBench;
