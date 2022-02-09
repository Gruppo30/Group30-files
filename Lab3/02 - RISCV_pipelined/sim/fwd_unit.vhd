LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

-- This unit takes care of carrying out the forward from the ALU and data memory towards the inputs of the ALU. This block receives many inputs data,
-- like the RD and write_back signal of two consecutive stage (i+1 and i+2) and the two source data of the current stage (i); if one of the two RD value is 
-- equal to one of the source data register, we have to directly forward the result to the input of the ALU instead of saving the result into
-- the register file; Doing that we avoid as much as possible the usage of bubble 
entity fwd_unit is
	port(
		  wb_stage3, wb_stage4 : in  std_logic;
		  RD_stage3, RD_stage4 : in  std_logic_vector(4 downto 0);
		  RS1, RS2	     	   : in  std_logic_vector(4 downto 0);
		  hazard_control 	   : in std_logic;
		  fwdA,fwdB    : out std_logic_vector(1 downto 0)
	);
end fwd_unit;



architecture beh of fwd_unit is
begin

	fwd_stage3: process (wb_stage3, wb_stage4, rs1, rs2, rd_stage3, rd_stage4, hazard_control) 
	begin
		if((wb_stage3 = '1' OR wb_stage4 = '1') and hazard_control = '1') then
			-- Initially we set the selectors in the default configuration that 
			-- provides the "classic" inputs to the ALU
			fwdA <= "00";
			fwdB <= "00";
			
			-- Below we assign the selector sequence for controlling mux A
			if(RD_stage3 = RS1 and wb_stage3 = '1') then
				fwdA <= "10";
			elsif(RD_stage4 = RS1 and wb_stage4 = '1') then
				fwdA <= "01";
			end if;
			
			-- Below we assign the selector sequence for controlling mux B
			if(RD_stage3 = RS2 AND wb_stage3 = '1') then 
				fwdB <= "10";
			elsif(RD_stage4 = RS2 AND wb_stage4 = '1') then
				fwdB <= "01";
			end if;
		else 
			-- As default again we set the selectors in the default 
			-- configuration that provides the "classic" inputs to the ALU
			fwdA <= "00";
			fwdB <= "00";
		end if;
	end process;
end beh;