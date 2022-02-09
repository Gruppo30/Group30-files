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
		if(memread_control  = '1') then
			if((current_rd_add = current_instr(24 downto 20)) OR (current_rd_add = current_instr(19 downto 15))) then
				hazard_control <= '0';
				en_pc_reg <= '0';
				en_pipereg_stage1 <= '0';
				rst_pipereg_stage1 <= '1';
			else
				hazard_control <= '1';
				en_pc_reg <= '1';
				en_pipereg_stage1 <= '1';
				rst_pipereg_stage1 <= '1';
			end if;
		elsif(branch_control = '1') then 
			hazard_control <= '0';
			en_pc_reg <= '1';
			en_pipereg_stage1 <= '1';
			rst_pipereg_stage1 <= '0';
		else
			hazard_control <= '1';
			en_pc_reg <= '1';
			en_pipereg_stage1 <= '1';
			rst_pipereg_stage1 <= '1';
		end if;
	end process;
	


end beh;