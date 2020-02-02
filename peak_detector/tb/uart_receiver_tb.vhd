library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use work.utils.all;

entity uart_receiver_tb is
end uart_receiver_tb;

architecture TestBench of uart_receiver_tb is
	constant ClockSpeedHz : Integer := 100e6;
	constant BaudRateHz : Integer := 9600;
	constant DataWidth  : Integer := 8;
	constant ClockPeriod : time := 1sec / ClockSpeedHz;
	constant BaudPeriod : time := 1sec / BaudRateHz;

    signal clk          	: std_logic := '0';
	signal tx 				: std_logic := '1';
	signal data 			: std_logic_vector(DataWidth-1 downto 0) := (others => '0');
	signal parity 			: std_logic := '0';
	signal ready 			: std_logic := '0';
	signal uart_err 		: std_logic := '0';
	signal test_data 		: std_logic_vector(DataWidth-1 downto 0) := "00000100";
begin

    uart_rx : entity work.uart_receiver 
    generic map (BaudRateHz => BaudRateHz, ClockSpeedHz => ClockSpeedHz, DataWidth => DataWidth)
	port map (	i_clk => clk,
				i_rx => tx,
				o_data => data,
				o_parity => parity,
				o_ready => ready,
				o_error => uart_err);

    clk <= not clk after ClockPeriod / 2;
	send_byte : process
	-- send byte '4'
		begin
			tx <= '0';
			wait for BaudPeriod;
			for i in 0 to DataWidth-1 loop
				tx <= test_data(i);
                wait for BaudPeriod;
			end loop;
            -- parity bit
            tx <= '1';
            wait for BaudPeriod;
            tx <= '1';
			assert ready = '1' report "Ready signal not set after byte" severity error;
			assert data = test_data report "Incorrect data" severity error;
			assert uart_err = '0' report "Unexpected error signal" severity error;
            wait;
        end process;
end TestBench;
