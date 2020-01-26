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
        o_val : out unsigned(clog2(MaxValue)-1 downto 0));
end counter;

-- TODO: Handle both buttons at once, split out edge detector

architecture Behavioral of counter is
    type CounterState is (Increment, Waiting);
    signal state : CounterState := Waiting;
    signal state_next : CounterState := Waiting;
    signal count : unsigned(clog2(MaxValue)-1 downto 0) := (others => '0');
begin

o_val <= count;

process (i_clk)
begin
    if rising_edge(i_clk) then
        state <= state_next;
    end if;
end process;

process (state, i_incr) is
begin
    state_next <= state;
    case state is
      -- increment/decrement counter on edge
      when Waiting =>
        if i_incr = '1' then
          state_next <= Increment;
          if count < MaxValue then
            count <= count+1;
          else
            count <= (others => '0');
          end if;
        end if;

      when Increment => 
        if i_incr = '0' then
          state_next <= Waiting;
        else
          state_next <= Increment;
        end if;
    end case;
    

end process;
end Behavioral;
