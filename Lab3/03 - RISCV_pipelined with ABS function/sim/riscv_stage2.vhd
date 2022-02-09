LIBRARY ieee;
USE ieee.std_logic_1164.all;
--USE ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity RISCV_stage2 is 
 port(
	clk 			 : in std_logic;
	rst 			 : in std_logic;
	
	instruction 	 : in  std_logic_vector(31 downto 0); -- current instruction
	current_addr_in	 : in  std_logic_vector(63 downto 0); -- current instruction address (from PC)
	rd_adrress_in	 : in  std_logic_vector( 4 downto 0); -- pipelined destination register address
	RegWrite_in		 : in  std_logic;                     -- pipelined write enable
	data_in			 : in  std_logic_vector(63 downto 0); -- data coming from the ALu or memory
	haz_control		 : in  std_logic;
	
	fwd_ALU			 : in std_logic_vector(63 downto 0);
	
	MemRead 		 : out std_logic;
	MemtoReg		 : out std_logic;
	MemWrite		 : out std_logic;
	ALUsrc_in1  	 : out std_logic;
	ALUsrc_in2  	 : out std_logic;
	RegWrite_out	 : out std_logic;
	haz_control_out  : out std_logic;
	branch_cntr		 : out std_logic;
	branch_hdu		 : out std_logic;
	ALU_cntr 		 : out std_logic_vector( 3 downto 0);
	abs_cntr		 : out std_logic;
	
	instruction_out  : out std_logic_vector(31 downto 0); -- current instruction
	current_addr_out : out std_logic_vector(63 downto 0);
	sr1_data 	 	 : out std_logic_vector(63 downto 0);
	sr2_data 		 : out std_logic_vector(63 downto 0);
	immediate 		 : out std_logic_vector(63 downto 0);
	funct3			 : out std_logic_vector( 2 downto 0);
	rd_adrress_out	 : out std_logic_vector( 4 downto 0);
	jump_addr	 	 : out std_logic_vector(63 downto 0)
	);
end RISCV_stage2;

architecture arc of RISCV_stage2 is

	--internal components declaration
	signal branch_tmp     : std_logic;
	signal MemRead_tmp 	  : std_logic;
	signal MemtoReg_tmp	  : std_logic;
	signal ALUop_tmp	  : std_logic_vector(1 downto 0);
	signal MemWrite_tmp	  : std_logic;
	signal ALUsrc_in1_tmp : std_logic;
	signal ALUsrc_in2_tmp : std_logic;
	signal RegWrite_tmp	  : std_logic;
	signal abs_cntr_tmp   : std_logic;
	
	signal branch_cntr_tmp : std_logic;
	--
	signal ALU_cntr_tmp   : std_logic_vector(3 downto 0);
	signal rd_adrress_out_tmp   : std_logic_vector(4 downto 0);
	
	signal immediate_tmp  : std_logic_vector(63 downto 0);
	signal shift_immediate: std_logic_vector(63 downto 0);

	signal adder_out : std_logic_vector(63 downto 0);
	
	signal sr1_data_tmp : std_logic_vector(63 downto 0);
	signal sr2_data_tmp : std_logic_vector(63 downto 0);
	signal comp_in : std_logic_vector(63 downto 0);
	
	signal comparator_tmp : std_logic;
	signal flag 		  : std_logic;


	-- internal components declaration
	component decoder is 
		port(
			instruction : in  std_logic_vector(31 downto 0);
			branch      : out std_logic;
			MemRead 	: out std_logic;
			MemtoReg	: out std_logic;
			ALUop		: out std_logic_vector(1 downto 0);
			MemWrite	: out std_logic;
			ALUsrc_in1  : out std_logic;
			ALUsrc_in2  : out std_logic;
			RegWrite	: out std_logic;
			abs_cntr	: out std_logic
		);
	end component;
	
	component regFile is
		generic (k : positive := 5;
			     N : integer := 64);
		port(	
			clock,rst	  : in std_logic;
			rs1	 	  : in  unsigned ((k-1) downto 0);
			rs2		  : in  unsigned ((k-1) downto 0);
			rd 		  : in  unsigned ((k-1) downto 0);
			data_in   : in  std_logic_vector ((N-1) downto 0);
			wr_en	  : in  std_logic;
			data1_out : out std_logic_vector ((N-1) downto 0);
			data2_out : out std_logic_vector ((N-1) downto 0)
		);
	end component;

	component ImmediateGenerator is
		port(
			instruction : in  std_logic_vector(31 downto 0);
			immediate   : out std_logic_vector(63 downto 0)
			);
	end component;

	component mux is
		PORT( 
		  datain_a : in  std_logic_vector(63 downto 0);
		  datain_b : in  std_logic_vector(63 downto 0);
		  sel	   : in  std_logic;
		  dataout  : out std_logic_vector(63 downto 0)
		 );
	end component;

	component adder IS
	port(
		in_adder_A : IN  std_logic_vector(63 downto 0);
        in_adder_B : IN  std_logic_vector(63 downto 0);
        result	   : OUT std_logic_vector(63 downto 0)
		);
	END component adder;
	
	component comparator is
		port(datain1 : in std_logic_vector(63 downto 0);
			 datain2 : in std_logic_vector(63 downto 0);
			 --
			 result  : out std_logic
			 );
	end component;	

	component controlALU is 
	port(
		ALUop	 : in  std_logic_vector(1 downto 0);
		funct3	 : in  std_logic_vector(2 downto 0);
		ALU_out  : out std_logic_vector(3 downto 0)
	);
	end component;

begin

	-- branch control 
	branch_cntr_tmp <= branch_tmp AND (comparator_tmp OR flag);
	
	branch_cntr <= branch_cntr_tmp;
	jump_addr 	<= adder_out;

	-- shift left
	shift_immediate <= immediate_tmp(62 downto 0) & '0';
	
	rd_adrress_out <= rd_adrress_out_tmp;

	-- processo per rendere sincrona l'uscita
	sync : process(clk, current_addr_in, instruction, immediate_tmp,rst) is
	begin
		-- set all outputs to zero if the reset is active
		if (rst = '0') then 
			-- data signals
			funct3 <= (others => '0');
			rd_adrress_out_tmp <= (others => '0');
			immediate <= (others => '0');
			instruction_out <= (OTHERS => '0');
			current_addr_out <= (OTHERS => '0');
			sr1_data <= (OTHERS => '0');
			sr2_data <= (OTHERS => '0');
			branch_hdu <= '0';
			
			-- control signals 
			MemRead <= '0';
			MemtoReg <= '0';
			MemWrite <= '0';
			ALUsrc_in1 <= '0';
			ALUsrc_in2 <= '0';
			RegWrite_out <= '0';
			haz_control_out <= '0';
			ALU_cntr <= "0000";
			abs_cntr <= '0';
	 
		-- output synchronization
		elsif (clk'event and clk = '1') then
			-- data signals
			funct3		   	 <= instruction(14 downto 12);
			rd_adrress_out_tmp	 <= instruction(11 downto 7);
			immediate 	   	 <= immediate_tmp;
			instruction_out  <= instruction;
			current_addr_out <= current_addr_in;
			sr1_data <= sr1_data_tmp;
			sr2_data <= sr2_data_tmp;
			haz_control_out <= haz_control;
			ALU_cntr <= ALU_cntr_tmp;
			branch_hdu <= branch_cntr_tmp;

			if(haz_control = '1') then
				-- control signals 
				MemRead <= MemRead_tmp;
				MemtoReg <= MemtoReg_tmp;
				MemWrite <= MemWrite_tmp;
				ALUsrc_in1 <= ALUsrc_in1_tmp;
				ALUsrc_in2 <= ALUsrc_in2_tmp;
				RegWrite_out <= RegWrite_tmp;
				abs_cntr <= abs_cntr_tmp;
			else 
				-- control signals 
				MemRead <= '0';
				MemtoReg <= '0';
				MemWrite <= '0';
				ALUsrc_in1 <= '0';
				ALUsrc_in2 <= '0';
				RegWrite_out <= '0';
				abs_cntr <= '0';
			end if;
		end if;
	end process;
	
	branch_flag : process(ALU_cntr_tmp)
	begin
			if(ALU_cntr_tmp = "0001") then  -- JAL
				flag <= '1';
			else
				flag <= '0';		
			end if;		
	end process;
	
	-- port map 
	registerFile : regFile port map (clk,rst, 
									 unsigned(instruction(19 downto 15)), 
									 unsigned(instruction(24 downto 20)), 
									 unsigned(rd_adrress_in),
									 data_in,
									 RegWrite_in,
									 sr1_data_tmp,
									 sr2_data_tmp
									 );
	
	ImmGenerator : ImmediateGenerator port map(instruction, immediate_tmp);

	ControlUnit  : decoder port map(instruction,
									branch_tmp,
									MemRead_tmp,
									MemtoReg_tmp,
									ALUop_tmp,
									MemWrite_tmp,
									ALUsrc_in1_tmp,
									ALUsrc_in2_tmp,
									RegWrite_tmp,
									abs_cntr_tmp
									);
									
	ALUcontrol : controlALU port map(ALUop_tmp,
									instruction(14 downto 12),
									ALU_cntr_tmp
									);
									

	Add  : adder 	  port map(current_addr_in, shift_immediate, adder_out);
	
	--MuxA : mux   port map(sr1_data_tmp, fwd_ALU, sel_fwd_ALU, comp_in);
	fwd_comparator: process (rd_adrress_out_tmp,instruction,sr1_data_tmp,fwd_ALU) 
	begin
		if ((rd_adrress_out_tmp = instruction(19 downto 15)) OR (rd_adrress_out_tmp = instruction(24 downto 20))) then
			comp_in <= fwd_ALU;
		else 
			comp_in <= sr1_data_tmp;
		end if;
	end process;
	
	comp : comparator port map(comp_in, sr2_data_tmp, comparator_tmp);


end arc;	