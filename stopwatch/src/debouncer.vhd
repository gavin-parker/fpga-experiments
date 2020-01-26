library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use IEEE.MATH_REAL.all;
use work.utils.all;

entity debouncer is
      Generic (
        WaitPeriodS: Real := 0.1;
        ClockSpeedHz: Integer := 100e6
      );

      Port (    i_clk : in std_logic;
                b_in  : in std_logic;
                b_out : out std_logic);
end debouncer;

architecture Behavioral of debouncer is
    constant MaxCount : Integer := Integer(WaitPeriodS * Real(ClockSpeedHz));
    signal count : unsigned(clog2(MaxCount) downto 0) := (others => '0');
begin

process (i_clk) is
begin
    b_out <= '0';
    if rising_edge(i_clk) then
        if b_in = '1' and count < MaxCount then
            count <= count+1;
        end if;
        
        if b_in = '0' then
            count <= (others => '0');
        end if;
        
        if count = MaxCount then
            b_out <= '1';
        end if;
        
    end if;
end process;

end Behavioral;
