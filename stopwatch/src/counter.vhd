library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use work.utils.all;

-- Count up and down using the edge-detected signals 'i_incr' and 'i_decr'
entity counter is
	Generic (
		MaxValue: Integer := 9999);

	port (
		i_clk 	: in std_logic;
		i_rst 	: in std_logic;
		i_incr 	: in std_logic;
		i_decr 	: in std_logic;
		o_val 	: out unsigned(clog2(MaxValue)-1 downto 0));

end counter;

architecture Behavioral of counter is
	type CounterState is (Increment, Decrement, Waiting);
	signal state : CounterState := Waiting;
	signal state_next : CounterState := Waiting;
	signal count : unsigned(clog2(MaxValue)-1 downto 0) := (others => '0');
	signal count_next : unsigned(clog2(MaxValue)-1 downto 0) := (others => '0');
begin

o_val <= count;
-- Handle state transitions
process (i_clk, i_rst) begin
	if rising_edge(i_clk) then
			state <= state_next;
			count <= count_next;
			if i_rst = '1' then
				state <= Waiting;
				count <= (others => '0');
			end if;
	end if;
end process;

process (i_incr, i_decr, count, state) is begin
	state_next <= state;
	count_next <= count;
	case state is
		when Waiting =>
			if i_incr = '1' then
				state_next <= Increment;
				if count < MaxValue then
					count_next <= count+1;
				else
					count_next <= (others => '0');
				end if;
				
			elsif i_decr = '1' then
				state_next <= Decrement;
				if count > 0 then
					count_next <= count-1;
				else
					count_next <= to_unsigned(MaxValue, clog2(MaxValue));
				end if;
			end if;

		when Increment => 
			if i_incr = '0' then
				state_next <= Waiting;
			else
				state_next <= Increment;
			end if;

		when Decrement => 
			if i_decr = '0' then
				state_next <= Waiting;
			else
				state_next <= Decrement;
			end if;
	end case;

end process;
end Behavioral;
