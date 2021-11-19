library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use ieee.std_logic_arith.all;

entity product_gen is
	port (	X, A		: in std_logic_vector (31 downto 0);
         	y1,y2,y3,y4,y5,y6,y7,y8,y9,y10,y11,y12,y13,y14,y15,y16,y17 : out std_logic_vector (63 downto 0)
		  );
end product_gen;

architecture beh of product_gen is

component pj_gen is
	port (	tripl	: in std_logic_vector (2 downto 0); 
				A	: in std_logic_vector (31 downto 0);
         	p 	: out std_logic_vector (32 downto 0);
		sign    : out std_logic
		  );
end component;
	
	signal p1 : std_logic_vector (32 downto 0);
	signal p_tot : std_logic_vector (527 downto 0);
	signal x_new : std_logic_vector (34 downto 0);
	signal sign_out : std_logic_vector(16 downto 0);
	signal prod, sum : std_logic_vector(63 downto 0);
	signal temp_x,temp_a : std_logic_vector(31 downto 0);
	
begin

	x_new <= "00"&x&'0';
	
	partial1: pj_gen PORT MAP (x_new(2 downto 0),A,p1,sign_out(0));
		
	y1 <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" & (NOT sign_out(0)) & sign_out(0) & sign_out(0) & p1;
	
	gen_partial: for i in 1 to 16 generate 
		part: pj_gen PORT MAP ( x_new((2*i+2) downto 2*i), A, p_tot( (32*i+(i-1)) downto (33*(i-1))), sign_out(i) );
	end generate;
	
	y2 <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZ1" & (NOT sign_out(1)) & p_tot(32 downto 0) & '0' & sign_out(0);
	y3 <= "ZZZZZZZZZZZZZZZZZZZZZZZZZ1" & (NOT sign_out(2)) & p_tot(65 downto 33) & '0' & sign_out(1) &     "ZZ";
	y4 <= "ZZZZZZZZZZZZZZZZZZZZZZZ1" & (NOT sign_out(3)) & p_tot(98 downto 66) & '0' & sign_out(2) &     "ZZZZ";
	y5 <= "ZZZZZZZZZZZZZZZZZZZZZ1" & (NOT sign_out(4)) & p_tot(131 downto 99) & '0' & sign_out(3) &    "ZZZZZZ";
	y6 <= "ZZZZZZZZZZZZZZZZZZZ1" & (NOT sign_out(5)) & p_tot(164 downto 132) & '0' & sign_out(4) &   "ZZZZZZZZ";
	y7 <= "ZZZZZZZZZZZZZZZZZ1" & (NOT sign_out(6)) & p_tot(197 downto 165) & '0' & sign_out(5) &   "ZZZZZZZZZZ";
	y8 <= "ZZZZZZZZZZZZZZZ1" & (NOT sign_out(7)) & p_tot(230 downto 198) & '0' & sign_out(6) &   "ZZZZZZZZZZZZ";
	y9 <= "ZZZZZZZZZZZZZ1" & (NOT sign_out(8)) & p_tot(263 downto 231) & '0' & sign_out(7) &   "ZZZZZZZZZZZZZZ";
	y10 <="ZZZZZZZZZZZ1" & (NOT sign_out(9)) & p_tot(296 downto 264) & '0' & sign_out(8) &   "ZZZZZZZZZZZZZZZZ";
	y11 <="ZZZZZZZZZ1" & (NOT sign_out(10)) & p_tot(329 downto 297) & '0' & sign_out(9) &  "ZZZZZZZZZZZZZZZZZZ";
	y12 <="ZZZZZZZ1" & (NOT sign_out(11)) & p_tot(362 downto 330) & '0' & sign_out(10) & "ZZZZZZZZZZZZZZZZZZZZ";
	y13 <="ZZZZZ1" & (NOT sign_out(12)) & p_tot(395 downto 363) & '0' & sign_out(11) & "ZZZZZZZZZZZZZZZZZZZZZZ";
	y14 <="ZZZ1" & (NOT sign_out(13)) & p_tot(428 downto 396) & '0' & sign_out(12) & "ZZZZZZZZZZZZZZZZZZZZZZZZ";
	y15 <="Z1" & (NOT sign_out(14)) & p_tot(461 downto 429) & '0' & sign_out(13) & "ZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	y16 <=(NOT sign_out(15)) & p_tot(494 downto 462) & '0' & sign_out(14) &      "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	y17 <=p_tot(526 downto 495) & '0' & sign_out(15) &                         "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";


end beh;

