library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity clk_gen is
  port (
    CLK     : out std_logic;
    RST_n   : out std_logic);
end clk_gen;

architecture beh of clk_gen is
  
begin 
	  rst_n <= '0', '1' after 5 ns;

PROCESS
BEGIN
	clk <= '0';
	WAIT FOR 20 ns;
	clk <= '1';
	WAIT FOR 20 ns;
	END PROCESS;

end beh;
