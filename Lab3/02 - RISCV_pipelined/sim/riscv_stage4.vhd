LIBRARY ieee;
USE ieee.std_logic_1164.all;
--USE ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity RISCV_stage4 is 
 port(
	clk 			 : in std_logic;
	rst 			 : in std_logic;
	memReadData_in	 : in std_logic_vector(63 downto 0);
		
--	branch	     	 : in  std_logic;
--  MemRead			 : in  std_logic;      -- non servono in questo stadio perchè vanno direttamente al testbench nello stadio 3
	MemtoReg_in		 : in  std_logic;
 --	MemWrite		 : in  std_logic;
	RegWrite_in		 : in  std_logic;
--	ALU_zero		 : in  std_logic;
	
	ALU_output_in	 : in  std_logic_vector(63 downto 0);
	sr2_data_out	 : in  std_logic_vector(63 downto 0);
	rd_adrress_in	 : in  std_logic_vector(4 downto 0);

	MemtoReg_out	 : out std_logic;
	RegWrite_out	 : out std_logic;
--	branch_cntl		 : out std_logic;
	
	ALU_output_out	 : out std_logic_vector(63 downto 0);
	rd_adrress_out	 : out std_logic_vector(4 downto 0);
	memReadData_out  : out std_logic_vector(63 downto 0)
	);
end RISCV_stage4;

architecture arc of RISCV_stage4 is		

	-- internal signals declaration
	
	-- internal components declaration
	
	
begin

	-- internal signals behaviour
	memReadData_out <= memReadData_in;
	
	rgn : process(clk,rst) is
			begin
				if(rst = '0') then
					RegWrite_out <= ('0');
					MemtoReg_out <= ('0');
					
					-- data signals
					ALU_output_out <=  (others => '0');
					rd_adrress_out <=  (others => '0');

				elsif (clk 'event and clk = '1') then
					
					-- control signals
					RegWrite_out <= RegWrite_in;
					MemtoReg_out <= MemtoReg_in;
					
					-- data signals
					rd_adrress_out  <= rd_adrress_in;
					ALU_output_out  <= ALU_output_in;
					
				end if;
			end process;
	


end arc;