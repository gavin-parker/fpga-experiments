library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use work.utils.all;

-- Calculate the peak of received data over UART. Send peak back to host on press of center button.
entity peak_detector is
    port ( 
		clk: 	in std_logic;
		RsRx: 	in std_logic;
		btnC: 	in std_logic;
		RsTx: 	out std_logic);
end peak_detector;

architecture Behavioral of peak_detector is
	constant WaitPeriodS	: Real 		:= 0.1;
	constant ClockSpeedHz	: Integer 	:= 100e6;
	-- Receiver
	signal data 			: std_logic_vector(7 downto 0);
	signal parity 			: std_logic := '0';
	signal rx_ready			: std_logic := '0';
	signal rx_error		 	: std_logic := '0';
	-- Transmitter
	signal send				: std_logic := '0';
	signal tx_ready			: std_logic := '0';
	
	signal center_pressed	: std_logic;
	signal second_counter	: unsigned(clog2(ClockSpeedHz)-1 downto 0) := (others => '0');
	signal peak				: std_logic_vector(7 downto 0) := (others => '0');
begin
	ButtonCenter: entity work.debouncer
	 port map(
		i_clk 	=> clk,
		b_in 	=> btnC,
		b_out 	=> center_pressed);

	UartRx: entity work.uart_receiver 
	port map(
		i_clk 		=> clk,
		i_rx 		=> RsRx,
		o_data 		=> data,
		o_parity 	=> parity,
		o_ready 	=> rx_ready,
		o_error 	=> rx_error);

	UartTx: entity work.uart_transmitter 
	port map(
		i_clk 	=> clk,
		i_send 	=> send,
		i_data 	=> peak,
		o_tx 	=> RsTx,
		o_ready => tx_ready);

	process (clk) is begin
		if rising_edge(clk) then
			send <= '0';
			-- Read data from UART
			if rx_ready = '1' then
				if data > peak then
					peak <= data;
				end if;
			end if;
			-- send peak to host on button press
			if center_pressed = '1' and tx_ready = '1' then
				send <= '1';
			end if;
		end if;
	end process;
	
end Behavioral;
