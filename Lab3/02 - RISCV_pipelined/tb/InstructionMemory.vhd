LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.ALL;

-- The instruction memory is pointed by the address coming out from the program counter. It returns the instruction to be executed

entity InstructionMemory is
	generic ( 	k : positive := 8);
	port(		clk,rst    : in std_logic;
			addr 	   : in  std_logic_vector(31 downto 0);
			data_out   : out std_logic_vector(31 downto 0)
		);
end InstructionMemory;

architecture beh of InstructionMemory is

-- As we did for the data instruction, we decided to reduce the size of the memory decreasing the number of addressing bits from 32 to 8

	type mem is array(0 to (2**k)-1)  of std_logic_vector (31 downto 0);
	signal memArray : mem := (others => "00000000000000000000000000000000");
				
begin 
-- These string of bits correspond to the instructions useful to perform the research of the minimum value (we set all the other locations to 0)

	memArray(0 to 31) <= (		"00000000011100000000100000010011", --ADDI
								"00001111110000010000001000010111", --AUIPC
								"11111111110000100000001000010011", --ADDI
								"00001111110000010000001010010111", --AUIPC
								"00000001000000101000001010010011", --ADDI
								"01000000000000000000011010110111", --LUI
								"11111111111101101000011010010011", --ADDI
								"00000010000010000000100001100011", --BEQ
								"00000000000000100010010000000011", --LW
								"01000001111101000101010010010011", --SRAI
								"00000000100101000100010100110011", --XOR
								"00000000000101001111010010010011", --ANDI
								"00000000100101010000010100110011", --ADD
								"00000000010000100000001000010011", --ADDI
								"11111111111110000000100000010011", --ADDI
								"00000000110101010010010110110011", --SLT
								"11111100000001011000111011100011", --BEQ
								"00000000000001010000011010110011", --ADD
								"11111101010111111111000011101111", --JAL
								"00000000110100101010000000100011", --SW
								"00000000000000000000000011101111", --JAL
								"00000000000000000000000000010011", --ADDI
								"00000000000000000000000000000000",
								"00000000000000000000000000000000",
								"00000000000000000000000000000000",
								"00000000000000000000000000000000",
								"00000000000000000000000000000000",
								"00000000000000000000000000000000",
								"00000000000000000000000000000000",
								"00000000000000000000000000000000",
								"00000000000000000000000000000000",
								"00000000000000000000000000000000");

	process(addr, rst) is
	begin
		if(rst = '0') then
			data_out <= (others => '0');
		else
			data_out <= memArray((to_integer(unsigned(addr(7 downto 0))))/4);
		end if;
	end process;

end beh;

