library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use ieee.std_logic_arith.all;

entity HA is
port ( a_ha, b_ha : IN std_logic;
	s_ha, c_ha : OUT std_logic);
end ha;

architecture beh of ha is
begin

 s_ha <= a_ha XOR b_ha;
 c_ha <= a_ha AND b_ha;

end beh;


 


