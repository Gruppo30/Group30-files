library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use ieee.std_logic_arith.all;

-- this file synthesizes a MODIFIED BOOTH ENCODER (MBE) multiplier.
-- the multiplier receives as inputs the multiplicand A and the multiplier X (from which the triplets
-- are genrated) and returns the result of the multiplication. 

entity MBE is
	port (X_MBE, A_MBE : in std_logic_vector (31 downto 0);
		product_res : OUT std_logic_vector(63 downto 0)
		  );
end MBE;

architecture beh of MBE is

-- interbal components definition
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
	
	-- port map of internal components
	-- the product_gen component allows dor the evaluation of all the partial products
	PRODUCT	: 	product_gen PORT MAP (X_MBE,A_MBE, y1_temp,y2_temp,y3_temp,y4_temp,y5_temp,y6_temp,y7_temp,y8_temp,y9_temp,y10_temp,y11_temp,y12_temp,y13_temp,y14_temp,y15_temp,y16_temp,y17_temp);
	
	-- the partial products are given as input to the Dadda tree, which adds them up and gives the final result of the MBE multiplication
    DADDA	: 	dadda_tree PORT MAP (y1_temp,y2_temp,y3_temp,y4_temp,y5_temp,y6_temp,y7_temp,y8_temp,y9_temp,y10_temp,y11_temp,y12_temp,y13_temp,y14_temp,y15_temp,y16_temp,y17_temp, product_res);

end beh;

