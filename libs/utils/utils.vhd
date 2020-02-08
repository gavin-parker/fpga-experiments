library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

package utils is
  -- Return the bit width required to store an integer value
  function clog2 (A : NATURAL) return INTEGER;
  function find_parity (A : std_logic_vector) return std_logic;
end package;

package body utils is

	function clog2 (A : NATURAL) return INTEGER is
    	variable Y : REAL;
    	variable N : INTEGER := 0;
  	begin
		if  A = 1 or A = 0 then -- 1 bit
			return A;
		end if;

		Y := REAL(A);
		while Y >= 2.0 loop
			Y := Y / 2.0;
			N := N + 1;
		end loop;

		if Y > 0.0 then --round up
			N := N + 1;
		end if;
		
		return N;
  end function clog2;

  function find_parity (A : std_logic_vector) return std_logic is
	   variable P : std_logic := '0';
   begin
       for i in A'range loop
           P := P xor A(i);
        end loop;
	return P;
    end function find_parity;
end package body;