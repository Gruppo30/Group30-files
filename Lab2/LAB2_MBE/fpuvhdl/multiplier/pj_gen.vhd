library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use ieee.std_logic_arith.all;

-- This file will take as input the i-th triplet coming from the 'X' operand
-- and the 'A' operand and will give as output the i-th partial product and
-- the sign of the operation. 
-- All the partial products are generated without the use of adders or 
-- multipliers. 

entity pj_gen is
	port (	tripl : in std_logic_vector (2 downto 0); 
			A	  : in std_logic_vector (31 downto 0);
         	p 	  : out std_logic_vector (32 downto 0);
			sign  : out std_logic
		  );
end pj_gen;

architecture beh of pj_gen is

	-- internal signals declaration and initialization
	signal q, temp  : std_logic_vector (32 downto 0) := (others => '0');

begin

	
	process(A,tripl) -- the process is triggered if one of the input changes
	begin
		if((NOT(tripl(1) xOR tripl(0)) AND NOT(tripl(2) XOR (tripl(1)))) = '1') then
			-- In this situation we implement q as zeros sequences
			q <= (others => '0');
		elsif ( (tripl(1) XOR tripl(0)) = '1') then
			-- In this case we report in q the A operand
			q <= '0' & A;
		else
			-- In this case we report in q two times the A operand
			q <= A & '0';
		end if;
	end process;
	
	-- Definition of a signal where each bit is equal to the sign of the triplet
	temp <= (others => tripl(2));
	
	-- Final evaluation if the partial product by performing the bit-a-bit xor in  
	-- order to complement the vector in case of negative sign
	p <= temp XOR q;

	-- the output sign but is set equal to the triplet MSB 
	sign <= tripl(2);

end architecture;