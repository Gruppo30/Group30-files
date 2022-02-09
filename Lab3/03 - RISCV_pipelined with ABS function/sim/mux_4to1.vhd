LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

entity mux_4to1 is
	port(
		  datain_a : in  std_logic_vector(63 downto 0);
		  datain_b : in  std_logic_vector(63 downto 0);
		  datain_c : in  std_logic_vector(63 downto 0);
		  datain_d : in  std_logic_vector(63 downto 0);
		  sel	   : in  std_logic_vector(1 downto 0);
		  dataout  : out std_logic_vector(63 downto 0)
	);
end mux_4to1;

architecture beh of mux_4to1 is
begin

	with sel select dataout <= 
		datain_a when "00",
		datain_b when "01",
		datain_c when "10",
		datain_d when others;
end beh;