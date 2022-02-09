LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

entity ImmediateGenerator is
	port(
		instruction : in  std_logic_vector(31 downto 0);
		immediate   : out std_logic_vector(63 downto 0)
		);
end entity;

architecture beh of ImmediateGenerator is

	signal tmp1 : std_logic_vector (31 downto 0);
	signal tmp2 : std_logic_vector (31 downto 0);

begin

-- in this generator we have to "reconstruct" the entire field of the immediate, which is divided in multiple bits and multiple fields inside the
-- instruction; depending on the type of the instruction we have different things to do in order to evaluate the correct value of the immediate.
-- The first 7 bits of the instruction (OPCODE) identify the type of instruction itself; tmp1 is a signal useful to extend the evaluated immediate
-- in 64 bits, while tmp2 is a signal useful to extend the immediate using the MSB

	with instruction(6 downto 0) select tmp1 <=
		
		 --SW
		(tmp2(19 downto 0) & instruction(31 downto 25) & instruction(11 downto 7)) when "0100011",
		
		-- LW
		(tmp2(19 downto 0) & instruction(31 downto 20)) when "0000011",
		
		-- AUIPC, LUI
		instruction(31 downto 12) & "000000000000" when "0010111",
		instruction(31 downto 12) & "000000000000" when "0110111",

		--BEQ
		(tmp2(19 downto 0) & instruction(31) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8)) when "1100011",

		-- J-format (JAL)
		(tmp2(11 downto 0) & (instruction(31) & instruction(19 downto 12) & instruction(20) & instruction(30 downto 21))) when "1101111",

		--ADDI, SRAI
		tmp2(19 downto 0) & instruction(31 downto 20) when "0010011",

		(others => '0') when others;

		
	tmp2 <= (others => instruction(31));
	immediate <= tmp2 & tmp1;	

end beh;