LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY ALU IS
	port(
		in_ALU_A 	: IN  std_logic_vector(63 downto 0);
		in_ALU_B 	: IN  std_logic_vector(63 downto 0);
		in_ALU_ctrl     : IN  std_logic_vector(3 downto 0);
		ALU_result 	: OUT std_logic_vector(63 downto 0);
		ALU_zero 	: OUT std_logic
		);
END ALU;

ARCHITECTURE Behavior OF ALU IS

	signal N : integer;

	signal in_ALU_A_tmp   : signed(63 downto 0);
	signal in_ALU_B_tmp   : signed(63 downto 0);
	signal alu_result_tmp : signed(63 downto 0);

	signal tmp_4	      : signed(63 downto 0) := (others => '0');
	signal tmp_SLT	      : signed(63 downto 0) := (others => '0');
	signal tmp_srai	      : std_logic_vector(63 downto 0);


BEGIN

	in_ALU_A_tmp <= signed(in_ALU_A);
	in_ALU_B_tmp <= signed(in_ALU_B);
	ALU_result   <= std_logic_vector(ALU_result_tmp);
	
	tmp_4(2) <= '1';

	N <= to_integer(unsigned(in_ALU_B(4 downto 0)));


	with in_ALU_ctrl select ALU_result_tmp <=
		(in_ALU_A_tmp + in_ALU_B_tmp)   when "0010",    --SUM (ADD, ADDI, LW, SW)
		signed(tmp_srai)  		        when "0110",    --SRAI
		(in_ALU_A_tmp AND in_ALU_B_tmp) when "0000",    --AND
		(in_ALU_A_tmp XOR in_ALU_B_tmp) when "0111",    --XOR
		(in_ALU_A_tmp + tmp_4)			when "0001",   	--JAL
		(in_ALU_B_tmp)					when "0011",    --LUI
		(tmp_SLT)						when "0100",    --SLT

		(others => '0') when others;
     
	-- flag ZERO control for jump instructions
	flag : PROCESS(in_ALU_ctrl,in_ALU_A,in_ALU_B)
		BEGIN
			if(in_ALU_ctrl = "0011") then
				if(in_ALU_A = in_ALU_B) then
					ALU_zero <= '1';
				else
					ALU_zero <= '0';
				end if;
			elsif (in_ALU_ctrl = "0010") then
				ALU_zero <= '1';
			elsif (in_ALU_ctrl = "0001") then
				ALU_zero <= '1';
			else
				ALU_zero <= '0';
		
			end if;
		END process;
	
	-- computation of SRAI operation result
	SRAI : process(in_ALU_ctrl,N)
		 BEGIN
			if(in_ALU_ctrl = "0110") then
				tmp_srai((63 - N) downto 0) <= in_ALU_A(63 downto N);
				tmp_srai(63 downto (63-N+1)) <= (others => in_ALU_A(63));
			end if;
		end process;

	-- computation of SLT operation result
	SLT : process(in_ALU_ctrl, in_ALU_A_tmp, in_ALU_B_tmp)
		 BEGIN
			if(in_ALU_A_tmp < in_ALU_B_tmp) then
				tmp_SLT(0) <= '1';
			else
				tmp_SLT(0) <= '0';
			end if;
		end process;

 	 
END Behavior;
