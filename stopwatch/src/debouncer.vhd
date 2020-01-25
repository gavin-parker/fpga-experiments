library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use work.utils.all;

entity debouncer is
      Generic (
        WaitPeriod: time := 10ms;
        ClockSpeedHz: Integer := 100e6
      );

      Port (    i_clk : in std_logic;
                b_in : in std_logic;
                b_out : out std_logic );
end debouncer;

architecture Behavioral of debouncer is
    type ButtonState is (Pressed, Unpressed);
    constant MaxCount : Integer := (WaitPeriod / 1000ms) * ClockSpeedHz;
    signal count : unsigned(clog2(MaxCount) downto 0) := (others => '0');
    signal state : ButtonState := Unpressed;
begin
process (i_clk, b_in) is
    begin
        if rising_edge(i_clk) then
        
            if state = Unpressed then
                if b_in = '1' then
                    count <= count+1;
                else
                    count <= (others => '0');
                end if;
                
                if count = MaxCount then
                    state <= Pressed;
                end if;
            end if;
            
            if state = Pressed then
                if b_in = '0' then
                    count <= (others => '0');
                    state <= Unpressed;
                end if;
            end if;
        
    end if;
    case state is
        when Pressed    => b_out <= '1';
        when Unpressed  => b_out <= '0';
    end case;
end process;

end Behavioral;
