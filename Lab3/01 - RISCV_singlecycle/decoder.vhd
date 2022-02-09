LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

entity decoder is 
 port(
	instruction : in  std_logic_vector(31 downto 0);
	branch      : out std_logic;
	MemRead 	: out std_logic;
	MemtoReg	: out std_logic;
	ALUop		: out std_logic_vector(1 downto 0);
	MemWrite	: out std_logic;
	ALUrsc_in1	: out std_logic;   -- drives the mux
	ALUrsc_in2	: out std_logic;   -- drives the mux
	RegWrite	: out std_logic
	);
end decoder;

architecture arc of decoder is

	
begin

	process(instruction)
	begin
	case instruction(6 downto 0) is 
		when "0110011" =>  -- ADD, XOR, SLT 
			branch          <= '0';
			MemRead 	<= '0';
			MemtoReg	<= '0';
			ALUop		<= "10";
			MemWrite	<= '0';
			ALUrsc_in1	<= '0';  --per avere rs1
			ALUrsc_in2  <= '0';  --per avere rs2
			RegWrite	<= '1'; 
		when "0010011" =>  -- ADDI, SRAI, ANDI
			branch          <= '0';
			MemRead 	<= '0';
			MemtoReg	<= '0';
			ALUop		<= "10";
			MemWrite	<= '0';
			ALUrsc_in1	<= '1';   --per avere immediate
			ALUrsc_in2      <= '0';   --per avere rs1
			RegWrite	<= '1'; 
		when "0010111" =>  -- AUIPC
			branch          <= '0';
			MemRead 	<= '0';
			MemtoReg	<= '0';
			ALUop		<= "00";   --per avere SUM
			MemWrite	<= '0';
			ALUrsc_in1	<= '1';    --per avere immediate
			ALUrsc_in2      <= '1';    --per avere PC
			RegWrite	<= '1'; 
		when "0110111" =>  -- LUI
			branch          <= '0';
			MemRead 	<= '0';
			MemtoReg	<= '0';
			ALUop		<= "01";  
			MemWrite	<= '0';
			ALUrsc_in1	<= '1';    --per avere immediate
			ALUrsc_in2  <= '1';    --don't care
			RegWrite	<= '1'; 
		when "1100011" =>  -- BEQ
			branch          <= '1';
			MemRead 	<= '0';
			MemtoReg	<= '0';
			ALUop		<= "01";
			MemWrite	<= '0';
			ALUrsc_in1	<= '0';    --per avere rs2
			ALUrsc_in2      <= '0';    --per avere rs1
			RegWrite	<= '0'; 
		when "0000011" =>  -- LW
			branch          <= '0';
			MemRead 	<= '1';
			MemtoReg	<= '1';
			ALUop		<= "00";  --per avere SUM
			MemWrite	<= '0';
			ALUrsc_in1	<= '1';   --per avere immediate
			ALUrsc_in2      <= '0';   --per avere rs1
			RegWrite	<= '1'; 
		when "0100011" =>  -- SW
			branch          <= '0';
			MemRead 	<= '0';
			MemtoReg	<= '0';
			ALUop		<= "00";  -- per avere SUM
			MemWrite	<= '1';
			ALUrsc_in1	<= '1';   --per avere immediate
			ALUrsc_in2  <= '0';   --per avere rs1
			RegWrite	<= '0';
		when "1101111" =>  -- JAL
			branch          <= '1';
			MemRead 	<= '0';
			MemtoReg	<= '0';
			ALUop		<= "11";
			MemWrite	<= '0';
			ALUrsc_in1	<= '1';   --per avere don't care
			ALUrsc_in2      <= '1';   --per avere PC
			RegWrite	<= '1';  
		when others =>
			branch          <= '0';
			MemRead 	<= '0';
			MemtoReg	<= '0';
			ALUop		<= "00";
			MemWrite	<= '0';
			ALUrsc_in1	<= '0';
			ALUrsc_in2      <= '0'; 
			RegWrite	<= '0'; 
	end case;
	end process;

end arc;
	