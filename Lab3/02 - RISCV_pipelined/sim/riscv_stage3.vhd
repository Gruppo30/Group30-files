LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RISCV_stage3 is 
 port(
	clk 			 : in std_logic;
	rst 			 : in std_logic;
	
	branch_cntr_in   : in  std_logic;
	MemRead_in 	 	 : in  std_logic;
	MemtoReg_in		 : in  std_logic;
	MemWrite_in		 : in  std_logic;
	ALUsrc_in1  	 : in  std_logic;
	ALUsrc_in2  	 : in  std_logic;
	RegWrite_in 	 : in  std_logic;
	ALU_cntr 		 : in  std_logic_vector(3 downto 0);	
	
	current_addr	 : in  std_logic_vector(63 downto 0);
	sr1_data 	 	 : in  std_logic_vector(63 downto 0);
	sr2_data_in	 	 : in  std_logic_vector(63 downto 0);
	immediate 		 : in  std_logic_vector(63 downto 0);
	funct3			 : in  std_logic_vector(2 downto 0);
	rd_adrress_in	 : in  std_logic_vector(4 downto 0);

	sel_fwd_muxA	 : in std_logic_vector(1 downto 0);
	sel_fwd_muxB	 : in std_logic_vector(1 downto 0);
	fwd_alu_out	 	 : out std_logic_vector(63 downto 0);
	fwd_mem_inA	 	 : in std_logic_vector(63 downto 0);
	fwd_mem_inB	 	 : in std_logic_vector(63 downto 0);
	
	branch_cntr_out  : out std_logic;
	MemRead_out		 : out std_logic;
	MemtoReg_out	 : out std_logic;
	MemWrite_out	 : out std_logic;
	RegWrite_out	 : out std_logic;
	
	DataMemory_addr_asynch	 : out std_logic_vector(63 downto 0);
	DataMemory_data_asynch  : out std_logic_vector(63 downto 0);
	DataMemory_rd_asynch    : out std_logic;
	DataMemory_wr_asynch	 : out std_logic;
	
	ALU_output 		 : out std_logic_vector(63 downto 0);
	sr2_data_out	 : out std_logic_vector(63 downto 0);
	rd_adrress_out	 : out std_logic_vector(4 downto 0)
	);
end RISCV_stage3;

architecture arc of RISCV_stage3 is		

	-- internaal signals declaration
	signal ALU_inA	  : std_logic_vector(63 downto 0);
	signal ALU_inB 	  : std_logic_vector(63 downto 0);
	signal alumux_inA : std_logic_vector(63 downto 0);
	signal alumux_inB : std_logic_vector(63 downto 0);
	signal empty_sig  : std_logic_vector(63 downto 0);
	signal tmp_ALU 	  : std_logic_vector(63 downto 0);
	signal tmp_ALU_sync : std_logic_vector(63 downto 0);
	
	component ALU IS
	port(
		in_ALU_A 	: IN  std_logic_vector(63 downto 0);
		in_ALU_B 	: IN  std_logic_vector(63 downto 0);
		in_ALU_ctrl : IN  std_logic_vector(3 downto 0);
		ALU_result 	: OUT std_logic_vector(63 downto 0)
		);
	END component;


	component mux is
		PORT( 
		  datain_a : in  std_logic_vector(63 downto 0);
		  datain_b : in  std_logic_vector(63 downto 0);
		  sel	   : in  std_logic;
		  dataout  : out std_logic_vector(63 downto 0)
		 );
	end component;

	component mux_4to1 is
	port(
		  datain_a : in  std_logic_vector(63 downto 0);
		  datain_b : in  std_logic_vector(63 downto 0);
		  datain_c : in  std_logic_vector(63 downto 0);
		  datain_d : in  std_logic_vector(63 downto 0);
		  sel	   : in  std_logic_vector(1 downto 0);
		  dataout  : out std_logic_vector(63 downto 0)
	);
	end component;

begin

	DataMemory_addr_asynch <= tmp_ALU;
	DataMemory_data_asynch <= sr2_data_in;
	DataMemory_rd_asynch <= MemRead_in;
	DataMemory_wr_asynch <= MemWrite_in;

	branch_cntr_out <= branch_cntr_in;
	
	-- the ALU result is forwarded to the comparator
	fwd_alu_out <= tmp_ALU;
	
	-- the ALU result is also associated to the output in order to propagate it to the next stage
	ALU_output <= tmp_ALU_sync;
	
	-- output synchronization
	reg : process(clk,rst) is
	begin
		if (rst = '0') then 
			-- control signals
				MemRead_out	<= ('0');
				MemtoReg_out <= ('0');
				MemWrite_out <= ('0');
				RegWrite_out <= ('0');
	
				-- data signals
				tmp_ALU_sync <= (others => '0');
				sr2_data_out <= (others => '0');
				rd_adrress_out <= (others => '0');

		elsif (clk 'event and clk = '1') then
			
				-- control signals
				MemRead_out	 <= MemRead_in;
				MemtoReg_out <= MemtoReg_in;
				MemWrite_out <= MemWrite_in;
				RegWrite_out <= RegWrite_in;
	
				-- data signals
				tmp_ALU_sync <= tmp_ALU;
				sr2_data_out <= sr2_data_in;
				rd_adrress_out <= rd_adrress_in;


		end if;
	end process;

	-- port map
	ArithmUnit : ALU port map(ALU_inA,
							  ALU_inB,
							  ALU_cntr,
							  tmp_ALU
				);

--these mux receives the current rs1/rs2 and the value of imediate/PC in order to select the correct decision depending on the instruction
	MuxA : mux   port map(sr1_data, current_addr, ALUsrc_in1, alumux_inA);
	MuxB : mux   port map(sr2_data_in, immediate,   ALUsrc_in2, alumux_inB);

	empty_sig <= (OTHERS => '0');
	
--these mux receives the value of the mux2to1 (whose output is rs1/rs2 or immediate/PC), the value of the mux output in stage 5 or the previous ALU
-- result which is in stage4 (tmp_ALU_sync is the ALU result in stage4, i.e. an input of this stage)

	FWD_MuxA : mux_4to1   port map(alumux_inA, fwd_mem_inA, tmp_ALU_sync, empty_sig, sel_fwd_muxA, ALU_inA);
	FWD_MuxB : mux_4to1   port map(alumux_inB, fwd_mem_inB, tmp_ALU_sync, empty_sig, sel_fwd_muxB, ALU_inB);


end arc;