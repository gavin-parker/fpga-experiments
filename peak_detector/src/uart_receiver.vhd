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
	signal bitIndex 	: Integer range 0 to DataWidth := 0;
	signal ready_signal : std_logic := '0';
	signal data         : std_logic_vector(DataWidth downto 0);
	signal parity       : std_logic := '0';
begin

o_ready <= ready_signal;
o_parity <= parity;

process (i_clk) is begin
	if rising_edge(i_clk) then
		case state is
			when Ready =>
				if i_rx = '0' then
					state <= Start;
					bitIndex <= 0;
				end if;
			when Start =>
				if clock_count = ClocksPerBit/2 then
					state <= Waiting;
					clock_count <= (others => '0');
					ready_signal <= '0';
					o_error <= '0';
				else
					clock_count <= clock_count+1;
				end if;
			when Waiting =>
					if clock_count = ClocksPerBit then
						clock_count <= (others => '0');
						if ready_signal = '1' then state <= Ready;
						else 
							state <= Receive;
						end if;
					else
						clock_count <= clock_count+1;
					end if;
			when Receive =>
				data(bitIndex) <= i_rx;
				bitIndex <= bitIndex+1;				
				if bitIndex = DataWidth then
					state <= Check;
				else
					state <= Waiting;
				end if;
			when Check =>
				if find_parity(data(DataWidth-1 downto 0)) = data(DataWidth) then
					ready_signal <= '1';
					state <= Waiting;
					o_data <= data(7 downto 0);
					parity <= data(DataWidth);
				else
					ready_signal <= '1';
					o_data <= (others => '-');
					o_error <= '1';
					state <= Ready;
				end if;
		end case;
    end if;
end process;

end Behavioral;
