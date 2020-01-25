library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use work.utils.all;

entity counter is
  Generic (
    MaxValue: Integer := 9
  );

  port (i_clk : in std_logic;
        i_incr : in std_logic;
        i_decr : in std_logic;
        o_val : out unsigned(clog2(MaxValue) downto 0));
end counter;

-- TODO: Handle both buttons at once, split out edge detector

architecture Behavioral of counter is
    type CounterState is (Increment, Decrement, Waiting);
    signal state : CounterState := Waiting;
    signal count : unsigned(clog2(MaxValue) downto 0) := (others => '0');
begin
process (i_clk, i_incr, i_decr) is
  begin
    if rising_edge(i_clk) then
      case state is

        -- increment/decrement counter on edge
        when Waiting =>
          if i_incr = '1' then
            count <= count+1;
            state <= Increment;
          elsif i_decr = '1' then
            count <= count-1;
            state <= Decrement;
          end if;

        when Increment => 
          if i_incr = '0' then
            state <= Waiting;
          end if;

        when Decrement =>
          if i_decr = '0' then
            state <= Waiting;
          end if;
      end case;
    end if;
    
    -- Wrap to zero
    if count > MaxValue or count < 0 then
      count <= (others => '0');
    end if;

  o_val <= count;
end process;

end Behavioral;
