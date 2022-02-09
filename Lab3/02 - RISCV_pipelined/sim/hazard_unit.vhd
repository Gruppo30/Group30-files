LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

entity hazard_unit is
	port(branch_control  	: in std_logic;
		memread_control 	: in std_logic;
		memwrite_control	: in std_logic;
		current_instr   	: in std_logic_vector(31 downto 0);
		current_rd_add  	: in std_logic_vector(4 downto 0);

		en_pc_reg			: out std_logic;
		en_pipereg_stage1   : out std_logic;
		rst_pipereg_stage1  : out std_logic;
		hazard_control		: out std_logic
	);
end hazard_unit;

architecture beh of hazard_unit is

begin

	process(branch_control, current_rd_add,current_instr, memread_control)
	begin
	-- if memread_control = '1' it means that we have to perform a load operation into a register file (so we have to read from the data memory and),
    -- but if the value to be saved is used as operand for the next instruction (rs1 or rs2) we have to insert a bubble (so we disenable the PC and
    -- the stage1) and we give the value '0' to the decoder through hazard_control in order to do NOP (this signal is used also to forward the value
	-- to the ALU input)
		if(memread_control  = '1') then
			if((current_rd_add = current_instr(24 downto 20)) OR (current_rd_add = current_instr(19 downto 15))) then
				hazard_control <= '0';
				en_pc_reg <= '0';
				en_pipereg_stage1 <= '0';
				rst_pipereg_stage1 <= '1';
	-- else we proceed with the normal execution of the instructions
			else
				hazard_control <= '1';
				en_pc_reg <= '1';
				en_pipereg_stage1 <= '1';
				rst_pipereg_stage1 <= '1';
			end if;
	-- if the signal determining the branch condition is equal to 1, it means that we have to jump,
	-- in this case we have to flush the stage1 and clear the pipe queue by means of NOP
		elsif(branch_control = '1') then 
			hazard_control <= '0';
			en_pc_reg <= '1';
			en_pipereg_stage1 <= '1';
			rst_pipereg_stage1 <= '0';
	-- else we proceed with the normal execution of the instructions
		else
			hazard_control <= '1';
			en_pc_reg <= '1';
			en_pipereg_stage1 <= '1';
			rst_pipereg_stage1 <= '1';
		end if;
	end process;
	


end beh;