library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity IIR_FILTER is
	port (	clk,resn,VIN 	: in std_logic;	
          	DIN, b0,b1,a1	: in signed (13 downto 0);
         	DOUT 			: out signed (13 downto 0);
			VOUT 			: out std_logic);
end IIR_FILTER;

architecture beh of IIR_FILTER is

	COMPONENT regn IS
	GENERIC (N : integer:=14);
	PORT (R	: IN signed(N-1 DOWNTO 0);
	      Clock, Resetn,Enable: IN STD_LOGIC;
	      Q	: OUT signed(N-1 DOWNTO 0));
	END COMPONENT regn;
	
	COMPONENT FFs IS
	PORT (R ,Clock, Resetn,en : IN STD_LOGIC;
	      Q : OUT STD_LOGIC);
	END COMPONENT FFs;
  
  	signal reg_a1, reg_b0, reg_b1 : signed (12 downto 0);
	signal fb, ff, y, w, sw : signed (14 downto 0);
	signal x : signed (13 downto 0);
	signal fb_temp, ff_temp, y_temp, w_temp	: signed (27 downto 0);
	signal reg_en, en_VIN, en_VOUT, clkn : std_logic;
  
begin 

	fb_temp <= sw*reg_a1;
	fb <= -(fb_temp(27 downto 14)&'0');
	
	ff_temp <= sw*reg_b1;
	ff <= (ff_temp(27 downto 14)&'0');
	
	w <= fb+(x(13)&x);

	y_temp <= w*reg_b0;
	y <= y_temp(27 downto 13)+ff;
	
	process(VIN)
	begin
		if(VIN='1') then 
			en_VIN <='1';
			en_VOUT<='1';
		elsif (VIN='0') then 
			en_VIN <='1';
			en_VOUT<='1';
		else 
		   en_VOUT<='0';
		   en_VIN<='0';
		end if;
	end process;
	
	FFVIN	: FFs PORT MAP (VIN,clk,resn,en_VIN,reg_en);
	FFVOUT	: FFs PORT MAP (reg_en,clk,resn,en_VOUT,VOUT);

	clkn	<= not(clk);
	REGDIN 	: regn PORT MAP (DIN, clkn, resn, reg_en, x);
	REGDOUT : regn PORT MAP (y(13 downto 0), clk, resn, reg_en, DOUT);
	
	REGa1 	: regn GENERIC MAP (N=>13) PORT MAP (a1(12 downto 0), clk, resn, reg_en, reg_a1);
	REGb0 	: regn GENERIC MAP (N=>13) PORT MAP (b0(12 downto 0), clk, resn, reg_en, reg_b0);
	REGb1 	: regn GENERIC MAP (N=>13) PORT MAP (b1(12 downto 0), clk, resn, reg_en, reg_b1);
	
	REGxtemp: regn GENERIC MAP (N=>15) PORT MAP (w, clk, resn, reg_en, sw);

end beh;
