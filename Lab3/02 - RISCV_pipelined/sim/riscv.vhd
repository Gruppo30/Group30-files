LIBRARY ieee;
USE ieee.std_logic_1164.all;
--USE ieee.std_logic_arith.all;
use ieee.numeric_std.all;

-- This is the top entity of our project, which cointain the port map of all the components.

entity RISCV is 
 port(
	clk 			 : in std_logic;
	rst 			 : in std_logic;
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
	
	-- internal signals declaration
	signal PCsrc : std_logic;
	
	signal branch_cntr_stage2	 : std_logic;
	signal branch_hdu : std_logic;
	
	signal MemRead_stage2	 : std_logic;
	signal MemRead_stage3	 : std_logic;
	signal MemtoReg_stage2	 : std_logic;
	signal MemtoReg_stage3	 : std_logic;
	signal MemtoReg_stage4	 : std_logic;
	signal MemWrite_stage2   : std_logic;
	signal MemWrite_stage3   : std_logic;
	signal ALUsrc_in1_stage2 : std_logic;
	signal ALUsrc_in2_stage2 : std_logic;
	signal RegWrite_stage2   : std_logic;
	signal RegWrite_stage3   : std_logic;
	signal RegWrite_stage4   : std_logic;
	signal ALU_cntr_stage2	 : std_logic_vector(3 downto 0);

	signal hazard_control    	: std_logic;
	signal hazard_control_stage1 : std_logic;
	signal hazard_control_stage2 : std_logic;
	signal en_pc		: std_logic;
	signal en_pipe_stage1	: std_logic;
	signal rst_hdu_stage1  : std_logic;
	
	signal jump_addr	 : std_logic_vector(63 downto 0);
	signal PC_out	 	 : std_logic_vector(63 downto 0);
	
	signal instruction_stage1 : std_logic_vector(31 downto 0); 
	signal instruction_stage2 : std_logic_vector(31 downto 0); 
	signal funct3 : std_logic_vector(2 downto 0);
	
	signal rd_addr_stage2 : std_logic_vector(4 downto 0);
	signal rd_addr_stage3 : std_logic_vector(4 downto 0);
	signal rd_addr_stage4 : std_logic_vector(4 downto 0);
	
	signal immediate : std_logic_vector(63 downto 0);

	signal current_addr_stage1 : std_logic_vector(63 downto 0);
	signal current_addr_out_stage2 : std_logic_vector(63 downto 0);
	signal sr1_data_stage2 : std_logic_vector(63 downto 0);
	signal sr2_data_stage2 : std_logic_vector(63 downto 0); 	
	signal sr2_data_stage3 : std_logic_vector(63 downto 0); 
	signal memReadData	   : std_logic_vector(63 downto 0); 
	signal Data_stage5 	   : std_logic_vector(63 downto 0);
	
	signal ALU_output_stage3 : std_logic_vector(63 downto 0);
	signal ALU_output_stage4 : std_logic_vector(63 downto 0);
	signal fwd_ALU : std_logic_vector(63 downto 0);

	signal fwd_Asel,fwd_Bsel : std_logic_vector( 1 downto 0); 
	
	signal DataMemory_addr_asynch	 : std_logic_vector(63 downto 0);
	signal DataMemory_data_asynch  :  std_logic_vector(63 downto 0);
	signal DataMemory_rd_asynch    :  std_logic;
	signal DataMemory_wr_asynch	 :  std_logic;
	
	-- we decided to allocate different stage as represented in the report; in this way we have 4 pipe registers and 5 different stage.
	-- Concerning the pipeline registers, we decide to create single large registers instead of create multiple registers for each signal to be propagated
	-- to the next stage. In this way we are able to have a more orderly structure and to keep track of each signal that propagates from one stage to
    -- another, without complicating the connections much.
	
	
	-- internal components declaration
	component RISCV_stage1 is 
	 port(
		clk 			 : in std_logic;
		rst 			 : in std_logic;
		en_hdu			 : in std_logic;
		rst_hdu			 : in std_logic;
		instruction 	 : in  std_logic_vector(31 downto 0);  -- instruction coming from the memory in the testbench
		en_pcreg		 : in std_logic;				       -- enable of the PC
		
		hazard_control	 : in std_logic;
		branch_cntr		 : in  std_logic;						-- selection signal of the mux in order to decide if a jump has to be performed or not.
		jump_addr		 : in std_logic_vector(63 downto 0);    -- jump address coming from the output of the adder inside the second stage
		
		hazard_control_out : out std_logic;
		PC_out             : out std_logic_vector(63 downto 0);  -- value of the PC connected to the mux2to1 near the ALU in order to perform jump operations
		current_addr_out   : out std_logic_vector(63 downto 0);
		instruction_out    : out std_logic_vector(31 downto 0)  -- current instruction from the output of the instruction memory to the second stage
		);
end component;

-- in this stage we have several components like the register file, the hazard control unit,
-- the decoder, the immediate generator and the comparator	
		
	component RISCV_stage2 is 
		port(   clk 		 : in std_logic;
				rst 		 : in std_logic;
	
				instruction 	 : in  std_logic_vector(31 downto 0); -- current instruction
				current_addr_in	 : in  std_logic_vector(63 downto 0); -- current instruction address (from PC)
				rd_adrress_in	 : in  std_logic_vector( 4 downto 0);  -- pipelined destination register address
				RegWrite_in	 	 : in  std_logic;                     -- pipelined write enable
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
				ALU_cntr 		 : out std_logic_vector(3 downto 0);
					
				instruction_out  : out std_logic_vector(31 downto 0); 
				current_addr_out : out std_logic_vector(63 downto 0);
				sr1_data 		 : out std_logic_vector(63 downto 0);
				sr2_data 		 : out std_logic_vector(63 downto 0);
				immediate 		 : out std_logic_vector(63 downto 0);
				funct3			 : out std_logic_vector( 2 downto 0);
				rd_adrress_out	 : out std_logic_vector( 4 downto 0);
				jump_addr		 : out std_logic_vector(63 downto 0)
		);	
	end component;
	
	-- in this stage we have the ALU execution, the forwarding unit and the 4 mux
	component RISCV_stage3 is 
		port(	clk 			 : in std_logic;
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
	end component;

-- in this stage we have the data memory
	component RISCV_stage4 is 
		port(   clk 			 : in std_logic;
				rst 			 : in std_logic;
				memReadData_in	 : in std_logic_vector(63 downto 0);
		
				MemtoReg_in		 : in  std_logic;
				RegWrite_in		 : in  std_logic;
	
				ALU_output_in	 : in  std_logic_vector(63 downto 0);
				sr2_data_out	 : in  std_logic_vector(63 downto 0);
				rd_adrress_in	 : in  std_logic_vector(4 downto 0);

				MemtoReg_out	 : out std_logic;
				RegWrite_out	 : out std_logic;
	
				ALU_output_out	 : out std_logic_vector(63 downto 0);
				rd_adrress_out	 : out std_logic_vector(4 downto 0);
				memReadData_out  : out std_logic_vector(63 downto 0)
				);
	end component;
	
	-- in this final stage we have the mux and the various signal coming from the stage4
	component RISCV_stage5 is 
		port(   clk 			 : in std_logic;
				rst 			 : in std_logic;
		
				MemtoReg		 : in std_logic;
		
				ALU_output		 : in  std_logic_vector(63 downto 0);
				memReadData		 : in  std_logic_vector(63 downto 0);
	
				data_toRegFile   : out std_logic_vector(63 downto 0)
				);
	end component;

	component fwd_unit is
	port(
		  wb_stage3, wb_stage4 : in  std_logic;
		  RD_stage3, RD_stage4 : in  std_logic_vector(4 downto 0);
		  RS1, RS2	     	   : in  std_logic_vector(4 downto 0);
		  hazard_control 	   : in std_logic;
		  fwdA,fwdB    : out std_logic_vector(1 downto 0)
	);
	end component;

	component hazard_unit is
	port(branch_control  	: in std_logic;
		memread_control 	: in std_logic;
		memwrite_control	: in std_logic;
		current_instr   	: in std_logic_vector(31 downto 0);
		current_rd_add  	: in std_logic_vector(4 downto 0);

		en_pc_reg			: out std_logic;
		en_pipereg_stage1	: out std_logic;
		rst_pipereg_stage1  : out std_logic;
		hazard_control		: out std_logic
	);
	end component;
	
begin

	-- internal behaviour
	instruction_addr <= PC_out(31 downto 0);
	
	DataMemory_addr <= DataMemory_addr_asynch;
	DataMemory_data <= DataMemory_data_asynch;
	DataMemory_rd   <= DataMemory_rd_asynch;
	DataMemory_wr	<= DataMemory_wr_asynch;
	
	
	-- port map
	
	-- the first stage receives the various enable/reset signal from the hazard unit in order to clear the pipe queue in case of conflicts;
	-- at the output we propagate the signals to the next stage if there are not conflicts and we have to decide if take the sequential instruction
	-- coming from the adder (which add +4 at each clock cycle) or if need to jump 
	stage1: RISCV_stage1 port map(
									clk, 
									rst, 
									en_pipe_stage1,
									rst_hdu_stage1,
									instruction,
									en_PC,
									
									hazard_control,
									PCsrc,
									jump_addr,
									
									hazard_control_stage1,
									PC_out,
									current_addr_stage1,
									instruction_stage1
	);
	
-- in this stage we "break up" the instruction in multiple fields needed to other components (as immediate generator, register file in order to take
-- rs1 and rs2 value, ecc...) and we receive a couple of signals coming from later stages (as the result of the ALU useful to compare the correct signals
-- in case we have, for example, the sequent instructions:
-- 	slt x11,x10,x13
--	beq x11,x0,loop
-- in this case we have to compare in this stage x11 and x0 but x11 is evaluated in stage 3, so we need a forward from the ALU)
	stage2 : riscv_stage2 port map(clk, rst, 
								   instruction_stage1,
								   current_addr_stage1,
								   rd_addr_stage4,
								   RegWrite_stage4,
								   Data_stage5,
								   hazard_control,
								   --
								   fwd_ALU,
								   --
								   MemRead_stage2,
								   MemtoReg_stage2,
								   MemWrite_stage2,
								   ALUsrc_in1_stage2,
								   ALUsrc_in2_stage2,
								   RegWrite_stage2,
								   hazard_control_stage2,
								   branch_cntr_stage2,
								   branch_hdu,
								   ALU_cntr_stage2,
								   --
								   instruction_stage2,
								   current_addr_out_stage2,
								   sr1_data_stage2,
								   sr2_data_stage2,
								   immediate,
								   funct3,
								   rd_addr_stage2,
								   jump_addr							   
					);

-- in this stage we assign the correct ALU inputs depending on the type of instruction and we also manage the forward unit using rs1, rs2 and the 
-- previous value of rd (which is at stage4)
	stage3 : riscv_stage3 port map(clk, rst, 
								   branch_cntr_stage2,
								   MemRead_stage2,
								   MemtoReg_stage2,
								   MemWrite_stage2,
								   ALUsrc_in1_stage2,
								   ALUsrc_in2_stage2,
								   RegWrite_stage2,
								   ALU_cntr_stage2,
								   --
								   current_addr_out_stage2,
								   sr1_data_stage2,
								   sr2_data_stage2,
								   immediate,
								   funct3,
								   rd_addr_stage2,
								   --
								   fwd_Asel,
								   fwd_Bsel,
								   fwd_ALU,
								   Data_stage5,
								   Data_stage5,
								   --
								   PCsrc,
								   MemRead_stage3,
								   MemtoReg_stage3,
								   MemWrite_stage3,
								   RegWrite_stage3,
								   --
								   DataMemory_addr_asynch,
								   DataMemory_data_asynch,  
								   DataMemory_rd_asynch,    
								   DataMemory_wr_asynch,
								   --
								   ALU_output_stage3,
								   sr2_data_stage3,
								   rd_addr_stage3
								    );

-- in this stage we simply access to the data memory using an address. This address could also be a result of an arithmetic operation, so we don't need
-- to access to the memory but we have only to propagate the result to the next stage (or forward it to the ALU input in the previous stage3)
	stage4 : riscv_stage4 port map(clk, rst, 
								   Data,
								   --
								   MemtoReg_stage3,
								   RegWrite_stage3,
								   --
								   ALU_output_stage3,
								   sr2_data_stage3,
								   rd_addr_stage3,
								   --
								   MemtoReg_stage4,
								   RegWrite_stage4,
								   --
								   ALU_output_stage4,
								   rd_addr_stage4,
								   memReadData
								    );
									
-- this is the last stage in which we forward the result of the mux at stages 2-3
	stage5 : riscv_stage5 port map(clk, rst,
								   --
								   MemtoReg_stage4,
								   --
								   ALU_output_stage4,
								   memReadData,
								   --
								   Data_stage5
								    );

	forwarding_unit: fwd_unit	port map(RegWrite_stage3,
								   RegWrite_stage4,
								   rd_addr_stage3,
								   rd_addr_stage4,
								   instruction_stage2(19 downto 15),
								   instruction_stage2(24 downto 20),
								   hazard_control,
								   fwd_Asel,
								   fwd_Bsel
									);

	haz_unit: hazard_unit port map(branch_hdu, 
								   MemRead_stage2,
								   MemWrite_stage2,
								   instruction_stage1, 
								   rd_addr_stage2, 

								   -- output
								   EN_PC,
								   en_pipe_stage1,
								   rst_hdu_stage1,
								   hazard_control
									);
								   

end arc;