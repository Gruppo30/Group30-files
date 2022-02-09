LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RISCV is 
 port(
	clk 			 : in std_logic;
	rst 		 	 : in std_logic;
	instruction 	 : in  std_logic_vector(31 downto 0);
	Data	         : in  std_logic_vector(63 downto 0);
	instruction_addr : out std_logic_vector(31 downto 0);
	DataMemory_addr	 : out std_logic_vector(63 downto 0);
	DataMemory_data  : out std_logic_vector(63 downto 0);
	DataMemory_rd    : out std_logic;
	DataMemory_wr	 : out std_logic
	);
end RISCV;

architecture arc of RISCV is	
	
	-- internal components declaration
	component decoder is 
		port(
			instruction : in  std_logic_vector(31 downto 0);
			branch      : out std_logic;
			MemRead     : out std_logic;
			MemtoReg    : out std_logic;
			ALUop	    : out std_logic_vector(1 downto 0);
			MemWrite    : out std_logic;
			ALUrsc_in1  : out std_logic;
			ALUrsc_in2  : out std_logic;
			RegWrite    : out std_logic
		);
	end component;


	component controlALU is 
	port(
		ALUop	 : in  std_logic_vector(1 downto 0);
		funct3	 : in  std_logic_vector(2 downto 0);
		ALU_out  : out std_logic_vector(3 downto 0)
	);
	end component;


	component regFile is
		generic (k : positive := 5;
			     N : integer := 64);
		port(	
			clock	  : in std_logic;
			rs1		  : in  unsigned ((k-1) downto 0);
			rs2	 	  : in  unsigned ((k-1) downto 0);
			rd 	  	  : in  unsigned ((k-1) downto 0);
			data_in   : in  std_logic_vector ((N-1) downto 0);
			wr_en	  : in  std_logic;
			data1_out : out std_logic_vector ((N-1) downto 0);
			data2_out : out std_logic_vector ((N-1) downto 0)
		);
	end component;
	
	component mux is
		PORT( 
		  	datain_a : in  std_logic_vector(63 downto 0);
		  	datain_b : in  std_logic_vector(63 downto 0);
		  	sel		 : in  std_logic;
		  	dataout  : out std_logic_vector(63 downto 0)
		 	);
	end component;

	component ImmediateGenerator is
		port(
			instruction : in  std_logic_vector(31 downto 0);
			immediate   : out std_logic_vector(63 downto 0)
			);
	end component;
	
	component adder IS
		port(
			in_adder_A : IN  std_logic_vector(63 downto 0);
			in_adder_B : IN  std_logic_vector(63 downto 0);
			result	   : OUT std_logic_vector(63 downto 0)
			);
	END component;
	
	component ALU IS
		port(
			in_ALU_A    : IN  std_logic_vector(63 downto 0);
			in_ALU_B    : IN  std_logic_vector(63 downto 0);
			in_ALU_ctrl : IN  std_logic_vector(3 downto 0);
			ALU_result  : OUT std_logic_vector(63 downto 0);
			ALU_zero    : OUT std_logic
			);
	END component;

	
	component regn IS
		GENERIC (	N : integer := 64);
		PORT(
			R      : IN std_logic_vector(N-1 DOWNTO 0);
		  	Clock  : IN STD_LOGIC;
		    Resetn : IN STD_LOGIC;
		 	Q      : OUT std_logic_vector(N-1 DOWNTO 0));
	END component regn;

	
	-- internal signals declarations
	signal rs1_data : std_logic_vector(63 downto 0);
	signal rs2_data : std_logic_vector(63 downto 0);
	
	signal branch     : std_logic;
	signal MemRead    : std_logic;
	signal MemtoReg   : std_logic;
	signal MemWrite   : std_logic;
	signal ALUrsc_inB : std_logic;
	signal ALUrsc_inA : std_logic;
	signal RegWrite   : std_logic;
	signal ALUop      : std_logic_vector(1 downto 0);

	signal ALU_opcontrol  : std_logic_vector (3 downto 0);
	signal ALU_zero       : std_logic;

	signal sel_mux_pc     : std_logic;
	
	signal inputALU_B     : std_logic_vector(63 downto 0);
	signal inputALU_A     : std_logic_vector(63 downto 0);
	  
	signal mux_ALUout_out : std_logic_vector(63 downto 0);
	
	signal ImmGen_out     : std_logic_vector(63 downto 0);
	signal ImmGen_shift   : std_logic_vector(63 downto 0);	
	
	signal PC_out 	      : std_logic_vector(63 downto 0);
	signal in_reg_pc      : std_logic_vector(63 downto 0);
	
	signal Add4_out       : std_logic_vector(63 downto 0); 
	signal signal4        : std_logic_vector(63 downto 0) := "0000000000000000000000000000000000000000000000000000000000000100";
	
	signal add_sum_out    : std_logic_vector(63 downto 0);
	signal alu_result1    : std_logic_vector(63 downto 0);

begin

	-- internal behaviour
	instruction_addr <= pc_out(31 downto 0);

	DataMemory_addr  <= alu_result1;
	DataMemory_data  <= rs2_data;
	DataMemory_wr    <= MemWrite;
	DataMemory_rd    <= MemRead;
	
	ImmGen_shift <= ImmGen_out(62 downto 0) & '0';
	
	sel_mux_pc <= (branch AND ALU_zero);

	--port maps							   
	Dec  : decoder port map (	instruction, 
					branch, 
					memread, 
					memtoreg, 
					aluop, 
					memwrite, 
					ALUrsc_inB,
					ALUrsc_inA,
					regwrite
					);
	

	aritmLogicUnit: ALU port map (	inputALU_A,
					inputALU_B,
					ALU_opcontrol,
					Alu_result1,
					ALU_zero
					);

	
	ALUcntr : controlALU port map(	ALUop,
					instruction(14 downto 12),
					ALU_opcontrol
					);

	
	registerFile : regFile port map(	clk,
						unsigned(instruction(19 downto 15)), 
						unsigned(instruction(24 downto 20)), 
						unsigned(instruction(11 downto 7)),
						mux_ALUout_out,
						regWrite,
						rs1_data,
						rs2_data
						);


	mux_ALUinB : mux port map(	rs2_data,
					ImmGen_out,
					ALUrsc_inB,        --ALU1 è quella di Read2
					inputALU_B
					); 


	mux_ALUinA : mux port map(	rs1_data,
				   	pc_out,
				   	ALUrsc_inA,         --ALU2 è quella di Read1
				   	inputALU_A
				  	);


	mux_ALUout : mux port map(	 alu_result1,
				  	 Data,
				  	 MemtoReg,
				  	 mux_ALUout_out
				 	 );


	mux_PCin : mux port map(	Add4_out,	
				 	Add_sum_out,
				 	sel_mux_pc,
				 	in_reg_PC
					);


							   
	regPC : regn PORT MAP(	in_reg_PC,
 				clk, 
				rst,
				pc_out
				);

								
	ImmGen  : ImmediateGenerator port map (instruction, ImmGen_out);

	Add4    : Adder port map (pc_out, signal4, Add4_out);
	Add_sum : Adder port map (pc_out, ImmGen_shift, Add_sum_out);

end arc;
	