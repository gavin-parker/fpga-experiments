library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use IEEE.MATH_REAL.all;
use work.utils.all;

entity uart_transmitter is
	Generic (
		BaudRateHz	: Integer := 9600;
		ClockSpeedHz: Integer := 100e6;
		DataWidth 	: Integer := 8);

	Port (
		i_clk 	: in std_logic;
		i_send  : in std_logic;
		i_data	: in std_logic_vector(DataWidth-1 downto 0);
		o_tx  	: out std_logic;
		o_ready : out std_logic);

end uart_transmitter;

architecture Behavioral of uart_transmitter is
	-- Baud Rate
	constant ClocksPerBit : Integer := ClockSpeedHz / BaudRateHz;
	signal clock_count : unsigned(clog2(ClocksPerBit)-1 downto 0) := (others => '0');

	type StateType is (Ready, Load, Send);
	signal state 		: StateType := Ready;

	signal bitIndex 	: Integer range 0 to DataWidth+2 := 0;
	signal ready_signal : std_logic := '0';
	-- Leave room head trailing bit
	signal data         : std_logic_vector(DataWidth+1 downto 0);
	signal parity       : std_logic := '0';

	signal tx 			: std_logic := '1';
begin

o_tx <= tx;
process (i_clk) is begin
	if rising_edge(i_clk) then
		case state is
			when Ready =>
				o_ready <= '1';
				if i_send  = '1' then
					data <= '1' & i_data & '0';
					state <= Load;
					o_ready <= '0';
				end if;
				clock_count <= (others => '0');
				bitIndex <= 0;
				tx <= '1';
			when Load =>
				state <= Send;
				bitIndex <= bitIndex+1;
				tx <= data(bitIndex);
			when Send =>
                if clock_count = ClocksPerBit then
                    clock_count <= (others => '0');
                    if bitIndex = DataWidth+2 then
                        state <= Ready;
                    else
                        state <= Load;
                    end if;
                else
                    clock_count <= clock_count+1;
                end if;
		end case;
    end if;
end process;

end Behavioral;
