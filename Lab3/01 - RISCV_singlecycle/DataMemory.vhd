LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.ALL;

entity DataMemory is
		generic ( 	k 	  : positive := 8);
		port(		clk,rst   : in std_logic;
				addr 	  : in std_logic_vector(63 downto 0);
				data 	  : in std_logic_vector(63 downto 0);
				read_en   : in std_logic;
				write_en  : in std_logic;
			        data_out  : out std_logic_vector(63 downto 0)
		);
end DataMemory;

architecture beh of DataMemory is

	type mem is array(0 to (2**k)-1)  of signed (63 downto 0);
	signal memArray : mem := (others => "0000000000000000000000000000000000000000000000000000000000000000");
				
begin 

	write : PROCESS (clk,rst,addr,write_en) IS
			BEGIN
			IF(rst = '0') then
				memArray(0 to 6) <=("0000000000000000000000000000000000000000000000000000000000001010",
									"1111111111111111111111111111111111111111111111111111111111010001",
									"0000000000000000000000000000000000000000000000000000000000010110",
									"1111111111111111111111111111111111111111111111111111111111111101",
									"0000000000000000000000000000000000000000000000000000000000001111",
									"0000000000000000000000000000000000000000000000000000000000011011",
									"1111111111111111111111111111111111111111111111111111111111111100");
			ELSIF(clk'event and clk = '1') THEN
				IF (write_en = '1') THEN
					memArray(to_integer(unsigned(addr(7 downto 0)))/4) <= signed(data);	
				END IF;
			END IF;
		END PROCESS;
		
	read : PROCESS(read_en,addr) IS 
		   BEGIN
			IF (read_en = '1') THEN
				data_out <= std_logic_vector(memArray(to_integer(unsigned(addr(7 downto 0)))/4));
			ELSE
				data_out <= (others => 'Z');
			END IF;		   
		   END PROCESS; 

end beh;