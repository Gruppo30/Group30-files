LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

ENTITY testbench IS
END testbench;

ARCHITECTURE Behavior OF testbench IS

component RISCV is 
 port(
	clk, rst : in std_logic;
 
	instruction 	: in  std_logic_vector(31 downto 0);
	Data			: in  std_logic_vector(63 downto 0);
	Instruction_addr 	: out std_logic_vector(31 downto 0);
	DataMemory_addr	: out std_logic_vector(63 downto 0);
	DataMemory_data : out std_logic_vector(63 downto 0);
	DataMemory_rd   : out std_logic;
	DataMemory_wr	: out std_logic
	);
end component RISCV;

component InstructionMemory is
	generic ( 	k : positive := 8);
	port(	clk,rst   : in  std_logic;
			addr 	  : in  std_logic_vector(31 downto 0);
			data_out  : out std_logic_vector(31 downto 0)
		);
end component InstructionMemory;

component DataMemory is
	generic ( 	k 	  : positive := 8);
		port(	clk,rst   : in std_logic;
				addr 	  : in std_logic_vector(63 downto 0);
				data 	  : in std_logic_vector(63 downto 0);
				read_en   : in std_logic;
				write_en  : in std_logic;
			    data_out  : out std_logic_vector(63 downto 0)
		);
end component DataMemory;


	SIGNAL 	clk_tb, rst_tb,DataMemory_rd_tb, DataMemory_wr_tb	: std_logic;
	SIGNAL  instruction_tb, PC_OUT_TB,data1,data2 : std_logic_vector(31 downto 0);
	SIGNAL	data_tb, DataMemory_addr_tb, DataMemory_data_tb: std_logic_vector(63 downto 0);
	
BEGIN
	  rst_tb <= '0', '1' after 21 ns;

PROCESS
BEGIN
	clk_tb <= '0';
	WAIT FOR 20 ns;
	clk_tb <= '1';
	WAIT FOR 20 ns;
	END PROCESS;
	
	DUT: RISCV PORT MAP (clk_tb, rst_tb, instruction_tb, Data_tb, pc_out_tb, DataMemory_addr_tb, datamemory_data_tb, datamemory_rd_tb, datamemory_wr_tb);
	DataMem: DataMemory PORT MAP (clk_tb,rst_tb, DataMemory_addr_tb, DataMemory_data_tb, DataMemory_rd_tb, DataMemory_wr_tb, data_tb);
	DataInstruction: InstructionMemory PORT MAP (clk_tb, rst_tb, pc_out_tb, instruction_tb);
		
END Behavior;
