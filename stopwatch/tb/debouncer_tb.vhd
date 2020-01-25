library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity debouncer_tb is
end debouncer_tb;

architecture TestBench of debouncer_tb is
    constant WaitPeriod : time := 100ns;
    constant ClockSpeedHz : Integer := 100e6;
    constant ClockPeriod : time := 100ms / ClockSpeedHz;

    signal b_in, b_out : std_logic := '0';
    signal clk : std_logic := '0';
begin
    UUT : entity work.debouncer 
        generic map (WaitPeriod => WaitPeriod, ClockSpeedHz => ClockSpeedHz) 
        port map (i_clk => clk, b_in => b_in, b_out => b_out);
        
    clk <= not clk after ClockPeriod / 2;
    test_not_activated_early : process

        begin
            b_in <= '0';
            wait for WaitPeriod / 2;
            assert b_out = '0' report "Button pressed without signal" severity error;
            
            b_in <= '1';
            wait for WaitPeriod / 2;
            assert b_out = '0' report "Button pressed early" severity error;
            
            b_in <= '0';
            wait for WaitPeriod / 2;
            assert b_out = '0' report "Button WaitPeriod not reset" severity error;
            
            b_in <= '1';
            wait for WaitPeriod;
            assert b_out = '1' report "Button not pressed after WaitTime" severity error;
            
            b_in <= '0';
            wait for ClockPeriod;
            assert b_out = '0' report "Button not reset" severity error;
            
            std.env.finish;
        end process;
end TestBench;
