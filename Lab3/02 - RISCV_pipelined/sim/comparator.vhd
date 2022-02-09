LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.ALL;

--The comparator is a useful component to anticipate the conditional jump. In fact we are going to compare the two operands rs1 and rs2 just
--outside the register file, without waiting for them to be analyzed by the ALU; in this way we can save a "layer of bubble" in case of a jump 

--This signal is sent to the hazard control unit in order to decide if is needed the flush of the pipe queue and give the correct value to the PC

entity comparator is
	port(datain1 : in std_logic_vector(63 downto 0);
		 datain2 : in std_logic_vector(63 downto 0);
		 --
		 result  : out std_logic
		 );
end entity;

architecture arc of comparator is

begin

	process(datain1, datain2)
	begin
		if(datain1 = datain2) then
			result <= '1'; -- rs1 = rs2 so we have to jump
		else 
			result <= '0';
		end if;
	end process;

end arc;