library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use work.utils.all;

entity peak_detector is
    port ( 
		clk: in std_logic;
		RsRx: in std_logic;
		btnC : in std_logic;
		RsTx: out std_logic;
		led : out std_logic_vector(15 downto 0));
end peak_detector;

architecture Behavioral of peak_detector is
    constant WaitPeriodS    : Real := 0.1;
	constant ClockSpeedHz   : Integer := 100e6;
	-- Receiver
	signal data 			: std_logic_vector(7 downto 0);
	signal parity 			: std_logic := '0';
	signal rx_ready			: std_logic := '0';
	signal rx_error		 	: std_logic := '0';
	-- Transmitter
	signal send				: std_logic := '0';
	signal tx_ready			: std_logic := '0';
	signal tx_data			: std_logic_vector(7 downto 0) := "01100001"; -- 'a'
	
	signal center_pressed   : std_logic;
	signal second_counter 	: unsigned(clog2(ClockSpeedHz)-1 downto 0) := (others => '0');
	-- For now this module just displays received bytes on the leds
	type state_type is (Waiting, Displaying);
	signal state 			: state_type := Waiting;
begin
	ButtonCenter    : entity work.debouncer port map(i_clk => clk, b_in => btnC, b_out => center_pressed);
	UartRx        : entity work.uart_receiver 
	port map(i_clk => clk,
			i_rx => RsRx,
			o_data => data,
			o_parity => parity,
			o_ready => rx_ready,
			o_error => rx_error);

	UartTx        : entity work.uart_transmitter 
	port map(i_clk => clk,
			i_send => send,
			i_data => tx_data,
			o_tx => RsTx,
			o_ready => tx_ready);

    process (clk) is begin
		if rising_edge(clk) then
			send <= '0';
            case state is
				when Waiting =>
					if center_pressed = '1' and tx_ready = '1' then
						send <= '1';
					end if;
					-- if rx_ready = '1' then
					-- 	led(7 downto 0) <= data;
					-- 	state <= Displaying;
					-- end if;
                when Displaying =>
					second_counter <= second_counter+1;
					if second_counter = ClockSpeedHz then
						state <= Waiting;
						second_counter <= (others => '0');
						led(7 downto 0) <= (others => '0');
					end if;
            end case;
        end if;
    end process;
end Behavioral;
