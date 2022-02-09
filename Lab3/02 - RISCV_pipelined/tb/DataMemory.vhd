LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.ALL;

-- The data memory receives two inputs (read_en and write_en) in order to enable the memory to perform readings (load operation from memory to the 
-- register file) or writings (store operation from ALU result to the memory). The memory receives also the data input (in case of store operation)
-- and the address (useful both for readings as it tells us the location to read and for writings as it tells us where to go to write)

entity DataMemory is
		generic ( 	k 	  : positive := 8);
		port(	clk,rst   : in std_logic;
				addr 	  : in std_logic_vector(63 downto 0);
				data 	  : in std_logic_vector(63 downto 0);
				read_en   : in std_logic;
				write_en  : in std_logic;
			    data_out  : out std_logic_vector(63 downto 0)
		);
end DataMemory;

architecture beh of DataMemory is

-- even if the address space is composed by 64 bits (so potentially we have 2^63 location that can be pointed by the address), we decided to 
-- save space and utilize only the 8 LSB of the address as pointer to the memory. By doing so, we create a smaller memory

	type mem is array(0 to (2**k)-1)  of signed (63 downto 0);
	signal memArray : mem := (others => "0000000000000000000000000000000000000000000000000000000000000000");
				
begin 

-- at the beginning we initialize the memory by writing in the first 7 locations the numbers to be compared to find the minimum value
-- We decided to do the addressing by two byte. Since the words are made up of 64 bits we have 8 bytes of 8 bits; to pass from one word to another one,
-- we have to divide for 4 the value of the address. 

-- In the same way, reading requires the enable and the address of the location to be read, which must be divided by 4

	write : PROCESS (clk,rst,read_en,addr, write_en) IS
			BEGIN
			IF(rst = '0') then
				memArray(0 to 6) <=("0000000000000000000000000000000000000000000000000000000000001010",
									"1111111111111111111111111111111111111111111111111111111111010001",
									"0000000000000000000000000000000000000000000000000000000000010110",
									"1111111111111111111111111111111111111111111111111111111111111101",
									"0000000000000000000000000000000000000000000000000000000000001111",
									"0000000000000000000000000000000000000000000000000000000000011011",
									"1111111111111111111111111111111111111111111111111111111111111100");
			ELSIF(clk'event and clk ='1') then
				if (write_en = '1') THEN
					memArray(to_integer(unsigned(addr(7 downto 0)))/4) <= signed(data);	
				elsif(read_en ='1') then 
					data_out <= std_logic_vector(memArray(to_integer(unsigned(addr(7 downto 0)))/4));
				end if;
			END IF;
		END PROCESS;

end beh;