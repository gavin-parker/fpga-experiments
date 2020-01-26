library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use work.utils.all;

entity counter_tb is
end counter_tb;

architecture TestBench of counter_tb is
    constant WaitPeriod     : time := 10ns;
    constant MaxCount       : Integer := 9;
    constant ClockSpeedHz : Integer := 100e6;
    constant ClockPeriod : time := 1sec / ClockSpeedHz;

    signal incr         : std_logic := '0';
    signal counter_val  : unsigned(clog2(MaxCount)-1 downto 0);
    signal clk          : std_logic := '0';
begin
    UUT : entity work.counter 
        generic map (MaxValue => MaxCount)
        port map (i_clk => clk, i_incr => incr, o_val => counter_val);
        
    clk <= not clk after ClockPeriod / 2;
    test_counter : process

        begin
            incr <= '0';
            wait for ClockPeriod*2;
            assert counter_val = 0 report "Counter unexpectedly incremented" severity error;
            
            incr <= '1';
            wait for ClockPeriod*2;
            assert counter_val = 1 report "Unexpected counter value" severity error;
            
            incr <= '0';
            wait for ClockPeriod*2;
            assert counter_val = 1 report "Unexpected counter value" severity error;


            for i in 0 to 8 loop
                wait for ClockPeriod*2;
                incr <= '0';
                wait for ClockPeriod*2;
                incr <= '1';
            end loop;
            assert counter_val = 9 report "Unexpected counter value" severity error;
            
            incr <= '0';
            wait for ClockPeriod*2;

            incr <= '1';
            wait for ClockPeriod*2;
            assert counter_val = 0 report "Didn't wrap" severity error;

            std.env.finish;
        end process;
end TestBench;
