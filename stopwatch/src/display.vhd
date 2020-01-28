library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use work.utils.all;

entity display is
  generic (
    ClockSpeedHz: Integer := 100e6;
    TargetRefreshHz: Integer := 100;
    MaxValue: Integer := 9999
  );

  port (i_clk : in std_logic;
        i_num : in unsigned(clog2(MaxValue)-1 downto 0);
        o_cathode : out std_logic_vector(6 downto 0);
        o_anode : out std_logic_vector(3 downto 0));
end display;

architecture Behavioral of display is

    constant ClocksPerRefresh: Integer := ClockSpeedHz / TargetRefreshHz;
    signal num : Integer := 0;
    signal count : unsigned(clog2(ClocksPerRefresh)-1  downto 0) := (others => '0');
    signal segment : unsigned(1 downto 0) := (others => '0');
    signal digit : Integer := 0;
    
    type digits is array (0 to 3) of unsigned(3 downto 0);
    signal displayedDigits : digits;
begin

-- Change selected segment every N clocks
process (i_clk) is
  begin
    if rising_edge(i_clk) then
      count <= count+1;
      segment <= segment;
      if count = ClocksPerRefresh then
        count <= (others => '0');
        segment <= segment+1;
      end if;
    end if;
end process;

-- BCD encode the digits
process (i_clk) is
begin
if rising_edge(i_clk) then
  displayedDigits(0) <= i_num mod 10;
  displayedDigits(1) <= i_num/10 mod 10;
  displayedDigits(2) <= i_num/100 mod 10;
  displayedDigits(3) <= i_num/1000 mod 10;
end if;
end process;

--Select correct anodes for current segment
process (i_clk, segment) is
  begin
    o_anode <= "0000";
    case segment is
      when "00" => o_anode <= "1110";
      when "01" => o_anode <= "1101";
      when "10" => o_anode <= "1011";
      when "11" => o_anode <= "0111";
      when others => null;
    end case;
  end process;
  

-- Select correct segment value for num
process (i_clk) is
  begin
    if rising_edge(i_clk) then
      o_cathode <= (others => '0');
      num <= to_integer(displayedDigits(to_integer(segment)));
      case num is
          when 0 => o_cathode <= "1000000";
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
    end if;
end process;



end Behavioral;
