LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY FFs IS
	PORT (	R,Clock, Resetn,en : IN STD_LOGIC;
			Q : OUT STD_LOGIC);
END FFs;

ARCHITECTURE Behavior OF FFs IS

BEGIN
	PROCESS (Clock,Resetn)
	BEGIN			
		IF (Resetn = '0') THEN
			Q <=  '0';
		ELSIF (Clock'EVENT AND Clock = '1') THEN
			if (en ='1') then 
				Q <= R;
			end if;
		END IF;
	END PROCESS;
END Behavior;

