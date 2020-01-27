library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use work.utils.all;

entity display is

  port (i_num : in unsigned(3 downto 0);
        o_cathode : out std_logic_vector(6 downto 0));
end display;

architecture Behavioral of display is
    signal num : Integer := 0;
begin
process (i_num) is
  begin
    num <= to_integer(i_num);
    case num is
        when 0 => o_cathode <= "1000000"; --reverse these
        when 1 => o_cathode <= "1111001";
        when 2 => o_cathode <= "0100100";
        when 3 => o_cathode <= "0110000";
        when 4 => o_cathode <= "0011001";
        when 5 => o_cathode <= "0010010";
        when 6 => o_cathode <= "0000010";
        when 7 => o_cathode <= "1111000";
        when 8 => o_cathode <= "0000000";
        when 9 => o_cathode <= "0010000";
        when others => null;
    end case;
end process;
end Behavioral;
