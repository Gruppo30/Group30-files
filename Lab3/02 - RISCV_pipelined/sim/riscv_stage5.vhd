LIBRARY ieee;
USE ieee.std_logic_1164.all;
--USE ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity RISCV_stage5 is 
 port(
	clk 			 : in std_logic;
	rst 			 : in std_logic;
		
	MemtoReg		 : in std_logic;
	
	ALU_output		 : in  std_logic_vector(63 downto 0);
	memReadData		 : in  std_logic_vector(63 downto 0);
	
	data_toRegFile   : out std_logic_vector(63 downto 0)
	);
end riscv_stage5;

architecture arc of riscv_stage5 is

	-- internal components
	component mux is
		PORT( 
		  datain_a : in  std_logic_vector(63 downto 0);
		  datain_b : in  std_logic_vector(63 downto 0);
		  sel	   : in  std_logic;
		  dataout  : out std_logic_vector(63 downto 0)
		 );
	end component;	

begin

	Register_inputData : mux port map(
								ALU_output,
								memReadData,
								MemtoReg,
								data_toRegFile);

end arc;
