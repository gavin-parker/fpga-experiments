library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use work.utils.all;

entity stopwatch is
    port ( clk: in std_logic;
            btnU : in std_logic;
            btnD : in std_logic;
            seg : out std_logic_vector(6 downto 0);
            an : out std_logic_vector(3 downto 0);
            led : out std_logic_vector(15 downto 0));
end stopwatch;

architecture Behavioral of stopwatch is
    constant WaitPeriodS    : Real := 0.1;
    constant ClockSpeedHz   : Integer := 100e6;
    constant MaxCount       : Integer := 9999;
    signal num : unsigned(clog2(MaxCount)-1 downto 0);
    signal increment : std_logic;
    signal decrement : std_logic;

begin
    ButtonUp : entity work.debouncer port map(i_clk => clk, b_in => btnU, b_out => increment);
    ButtonDown : entity work.debouncer port map(i_clk => clk, b_in => btnD, b_out => decrement);
    Counter : entity work.counter port map(i_clk => clk, i_incr => increment, i_decr => decrement, o_val => num);
    Display : entity work.display
        port map (i_clk => clk, i_num => num, o_cathode => seg, o_anode => an);
        
    led(0) <= increment;
end Behavioral;
