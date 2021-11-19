library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use ieee.std_logic_arith.all;

entity FA is
port ( a_fa, b_fa, cin_fa : IN std_logic;
	s_fa, c_fa : OUT std_logic);
end fa;

architecture beh of fa is
begin

 s_fa <= (a_fa XOR b_fa) XOR cin_fa;
 c_fa <= ( ((a_fa XOR b_fa) AND cin_fa) OR (a_fa AND b_fa)); 


end beh;

