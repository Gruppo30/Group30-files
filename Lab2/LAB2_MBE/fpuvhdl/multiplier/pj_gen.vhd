library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use ieee.std_logic_arith.all;

entity pj_gen is
	port (	tripl	: in std_logic_vector (2 downto 0); 
				A	: in std_logic_vector (31 downto 0);
         	p 	: out std_logic_vector (32 downto 0);
		sign    : out std_logic
		  );
end pj_gen;

architecture beh of pj_gen is

	signal q , temp    : std_logic_vector (32 downto 0) := (others => '0');

begin

	process(A,tripl)
	begin
		if((NOT(tripl(1) xOR tripl(0)) AND NOT(tripl(2) XOR (tripl(1)))) = '1') then
			q <= (others => '0');
		elsif ( (tripl(1) XOR tripl(0)) = '1') then
			q <= '0' & A;
		else --( (NOT(tripl(1) XOR tripl(0)) AND (tripl(2) XOR tripl(1))) = '1' ) 
			q <= A & '0';
		end if;
	end process;

	--gen_p: for i in 0 to 32 generate
	--p(i) <= (tripl(2) XOR q(i));
	--end generate;

	temp <= (others => tripl(2));
	p <= temp XOR q;

	sign <= tripl(2);

end architecture;