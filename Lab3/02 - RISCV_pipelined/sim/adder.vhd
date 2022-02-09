LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY adder IS
	port(
		in_adder_A : IN  std_logic_vector(63 downto 0);
        in_adder_B : IN  std_logic_vector(63 downto 0);
        result	   : OUT std_logic_vector(63 downto 0)
		);
END adder;

ARCHITECTURE Beh OF adder IS

BEGIN
	
	result <= std_logic_vector(unsigned(in_adder_A)+unsigned(in_adder_B));
	
END Beh;
   