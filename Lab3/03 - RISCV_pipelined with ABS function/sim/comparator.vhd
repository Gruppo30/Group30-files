LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.ALL;

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
			result <= '1';
		else 
			result <= '0';
		end if;
	end process;

end arc;