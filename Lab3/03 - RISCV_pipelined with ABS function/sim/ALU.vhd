LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY ALU IS
	port(
		in_ALU_A 	: IN  std_logic_vector(63 downto 0);
		in_ALU_B 	: IN  std_logic_vector(63 downto 0);
		in_ALU_ctrl     : IN  std_logic_vector(3 downto 0);
		ALU_result 	: OUT std_logic_vector(63 downto 0)
		);
END ALU;

ARCHITECTURE Behavior OF ALU IS

	component reg_barrel IS
		PORT (input  : IN  std_logic_vector(63 DOWNTO 0);
			  shift  : IN  STD_LOGIC_vector(4 downto 0);
			  output_sh : OUT std_logic_vector(63 DOWNTO 0));
	END component;

	signal in_ALU_A_tmp    : signed(63 downto 0);
	signal in_ALU_B_tmp    : signed(63 downto 0);
	signal alu_result_tmp  : signed(63 downto 0);

	signal tmp_4	      : signed(63 downto 0);
	signal tmp_SLT	      : signed(63 downto 0);
	signal tmp_srai	      : std_logic_vector(63 downto 0);

BEGIN

	in_ALU_A_tmp <= signed(in_ALU_A);
	in_ALU_B_tmp <= signed(in_ALU_B);
	ALU_result   <= std_logic_vector(ALU_result_tmp);
	
	tmp_4 <= "0000000000000000000000000000000000000000000000000000000000000100";

	with in_ALU_ctrl select ALU_result_tmp <=
		(in_ALU_A_tmp + in_ALU_B_tmp)   when "0010",    --SUM (ADD, ADDI, LW, SW, AUIPC)
		signed(tmp_srai)  		        when "0110",    --SRAI
		(in_ALU_A_tmp AND in_ALU_B_tmp) when "0000",    --AND
		(in_ALU_A_tmp XOR in_ALU_B_tmp) when "0111",    --XOR
		(in_ALU_A_tmp + tmp_4)			when "0001",   	--JAL
		(in_ALU_B_tmp)					when "0011",    --LUI
		(tmp_SLT)						when "0100",    --SLT

		(others => '0') when others;
     
	-- computation of SRAI operation result
	barrel_shift: reg_barrel port map(
		input => in_ALU_A,
		shift => in_ALU_B(4 downto 0),
		output_sh => tmp_srai
	);
	
	SLT : process(in_ALU_A_tmp, in_ALU_B_tmp)
	begin
		if(in_ALU_A_tmp < in_ALU_B_tmp) then
			tmp_SLT(0) <= '1';
			tmp_SLT(63 downto 1) <= (others => '0');
		else
			tmp_SLT(63 downto 0) <= (others => '0');
		end if;
	end process;

 	 
END Behavior;
