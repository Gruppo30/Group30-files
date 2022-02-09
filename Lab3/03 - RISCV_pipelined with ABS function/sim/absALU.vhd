LIBRARY ieee;
USE ieee.std_logic_1164.all;
--USE ieee.std_logic_arith.all;
USE ieee.numeric_std.all;

entity absALU is 
 port(rs1 	  : in  std_logic_vector(63 downto 0);
	  abs_out : out std_logic_vector(63 downto 0)
	  );
	end absALU;
	
	-- this block allows to evaluate the absolute value of rs1 depending on its value
	
architecture beh of absALU is

	signal tmp : signed(63 downto 0); 

begin

	abs_out <= std_logic_vector(tmp);
--	with rs1(63) select abs_out <=
	
	process(rs1)
	begin
		if(rs1(63) = '1') then
			tmp <= (-signed(rs1));
		else
			tmp <= signed(rs1); 
		end if;
	end process;

end beh;