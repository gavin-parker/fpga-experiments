library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use IEEE.MATH_REAL.all;
use work.utils.all;

entity uart_receiver is
	Generic (
		BaudRateHz	: Integer := 9600;
		ClockSpeedHz: Integer := 100e6;
		DataWidth 	: Integer := 8);

	Port (
		i_clk 	: in std_logic;
		i_rx  	: in std_logic;
		o_data	: out std_logic_vector(DataWidth-1 downto 0);
		o_parity: out std_logic;
		o_ready	: out std_logic;
		o_error	: out std_logic);

end uart_receiver;

architecture Behavioral of uart_receiver is
	-- Baud Rate
	constant ClocksPerBit : Integer := ClockSpeedHz / BaudRateHz;
	signal clock_count : unsigned(clog2(ClocksPerBit)-1 downto 0) := (others => '0');

	type StateType is (Ready, Start, Receive, Waiting, Check);

	signal state 		: StateType := Ready;
	signal state_next 	: StateType := Ready;
	signal bitIndex 	: unsigned(clog2(DataWidth)-1 downto 0) := (others => '0');
	signal ready_signal : std_logic := '0';
	signal data         : std_logic_vector(DataWidth-1 downto 0);
	signal parity       : std_logic := '0';
begin

o_ready <= ready_signal;
o_data <= data;
o_parity <= parity;

process (i_clk) is begin
	if rising_edge(i_clk) then
		state <= state_next;
    end if;
end process;

process (i_clk) is begin
	if rising_edge(i_clk) then
		case state is
			when Ready =>
				if i_rx = '0' then
					state_next <= Start;
					bitIndex <= (others => '0');
				end if;
			when Start =>
				clock_count <= clock_count+1;
				if clock_count = ClocksPerBit/2 then
					state_next <= Waiting;
					clock_count <= (others => '0');
					ready_signal <= '0';
				end if;
			when Waiting =>
					clock_count <= clock_count+1;
					if clock_count = ClocksPerBit then
						clock_count <= (others => '0');
						if ready_signal = '1' then state_next <= Ready;
						else 
							state_next <= Receive;
						end if;
					end if;
			when Receive =>
					clock_count <= clock_count+1;
					if bitIndex = DataWidth then
						state_next <= Check;
					else
						data(to_integer(bitIndex)) <= i_rx;
						state_next <= Waiting;
					end if;
					bitIndex <= bitIndex+1;
			when Check =>
                bitIndex <= (others => '0');
				if find_parity(data) = i_rx then
					ready_signal <= '1';
					state_next <= Waiting;
				else
					ready_signal <= '1';
					o_error <= '1';
					state_next <= Ready;
				end if;
		end case;
    end if;
end process;

end Behavioral;
