library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use ieee.std_logic_arith.all;

entity MBE is
	port (X_MBE, A_MBE : in std_logic_vector (31 downto 0);
		product_res : OUT std_logic_vector(63 downto 0)
		  );
end MBE;

architecture beh of MBE is

component product_gen is
	port (	X, A		: in std_logic_vector (31 downto 0);
         	y1,y2,y3,y4,y5,y6,y7,y8,y9,y10,y11,y12,y13,y14,y15,y16,y17 : out std_logic_vector (63 downto 0)
		  );
end component product_gen;

component dadda_tree is
	port (y1,y2,y3,y4,y5,y6,y7,y8,y9,y10,y11,y12,y13,y14,y15,y16,y17 : in std_logic_vector (63 downto 0);
			product : OUT std_logic_vector(63 downto 0)
		  );
end component dadda_tree;
	
	signal y1_temp,y2_temp,y3_temp,y4_temp,y5_temp,y6_temp,y7_temp,y8_temp,y9_temp,y10_temp,y11_temp,y12_temp,y13_temp,y14_temp,y15_temp,y16_temp,y17_temp : std_logic_vector (63 downto 0);

begin

	PRODUCT	: 	product_gen PORT MAP (X_MBE,A_MBE, y1_temp,y2_temp,y3_temp,y4_temp,y5_temp,y6_temp,y7_temp,y8_temp,y9_temp,y10_temp,y11_temp,y12_temp,y13_temp,y14_temp,y15_temp,y16_temp,y17_temp);
    DADDA	: 	dadda_tree PORT MAP (y1_temp,y2_temp,y3_temp,y4_temp,y5_temp,y6_temp,y7_temp,y8_temp,y9_temp,y10_temp,y11_temp,y12_temp,y13_temp,y14_temp,y15_temp,y16_temp,y17_temp, product_res);

end beh;

