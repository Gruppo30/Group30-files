LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

entity mux is
	port(
		  datain_a : in  std_logic_vector(63 downto 0);
		  datain_b : in  std_logic_vector(63 downto 0);
		  sel	   : in  std_logic;
		  dataout  : out std_logic_vector(63 downto 0)
	);
end mux;

architecture beh of mux is
begin

	with sel select dataout <= 
		datain_a when '0',
		datain_b when others;

end beh;