LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

entity controlALU is 
 port(
	ALUop	 : in  std_logic_vector(1 downto 0);
	funct3	 : in  std_logic_vector(2 downto 0);                          
	ALU_out  : out std_logic_vector(3 downto 0)
	);
end controlALU;

architecture arc of controlALU is	
begin

	process(ALUop, funct3)
	begin
		case ALUop is 
			when "00" => ALU_out <= "0010";            -- add
			when "01" => ALU_out <= "0011";            -- beq/lui
			when "10" => 
				case funct3 is
					when "000" => ALU_out  <= "0010";  -- add
					when "100" => ALU_out  <= "0111";  -- xor
					when "010" => ALU_out  <= "0100";
					when "101" => ALU_out  <= "0110";  -- shift
					when "111" => ALU_out  <= "0000";  -- and
					when others => ALU_out <= "0000";
				end case;
			when "11" => ALU_out <= "0001";            -- JAL
			when others => ALU_out <= "0000";

		end case;
	end process;

end arc;
	