library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use work.utils.all;

entity peak_detector is
    port ( 
		clk: in std_logic;
		RsRx: in std_logic;
		led : out std_logic_vector(15 downto 0));
end peak_detector;

architecture Behavioral of peak_detector is
    constant WaitPeriodS    : Real := 0.1;
    constant ClockSpeedHz   : Integer := 100e6;
	signal data 			: std_logic_vector(7 downto 0);
	signal parity 			: std_logic := '0';
	signal ready 			: std_logic := '0';
	signal rx_error		 	: std_logic := '0';

	signal second_counter 	: unsigned(clog2(ClockSpeedHz)-1 downto 0) := (others => '0');
	-- For now this module just displays received bytes on the leds
	type state_type is (Waiting, Displaying);
	signal state 			: state_type := Waiting;
begin
	UartRx        : entity work.uart_receiver 
	port map(i_clk => clk,
			 i_rx => RsRx,
			 o_data => data,
			 o_parity => parity,
			 o_ready => ready,
			 o_error => rx_error);

    process (clk) is begin
        if rising_edge(clk) then
            case state is
                when Waiting =>
					if ready = '1' then
						led(7 downto 0) <= data;
						state <= Displaying;
					end if;
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
