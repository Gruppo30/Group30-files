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
	PORT (	R,Clock, Resetn,en : IN STD_LOGIC;
			Q : OUT STD_LOGIC);
	END COMPONENT FFs;
  
  	signal reg_a1,reg_b0,reg_b1 : signed (12 downto 0);
	signal MOLT2,y,MOLT1,ADD2,ADD1,MOLT3, MOLT4,reg_2,reg_3,out_PIPE2,out_PIPE3,out_RET4,out_PIPE5,out_PIPE6,out_PIPE7,out_PIPE8  : signed (14 downto 0);
	signal x,reg_1,out_PIPE1 : signed (13 downto 0);
	signal M3_temp, M4_temp	: signed (27 downto 0);
	signal M2_temp : signed (40 downto 0);
	signal M1_temp : signed (26 downto 0);
	signal a2_quadro: signed (25 downto 0);
	signal clkn, reg_en,en_VIN,en_VOUT,out_FFVOUT1,out_FFVOUT2,out_FFVOUT3,out_FFVOUT4,total_en : std_logic;
  
begin 

	clkn <= not(clk);
	total_en <= reg_en OR out_FFVOUT4;

	M1_temp <= reg_a1*reg_1;
	MOLT1 <= M1_temp(26)&M1_temp(26 downto 13);
	
	a2_quadro <=  reg_a1*reg_a1;
	M2_temp <= a2_quadro*reg_2;
	MOLT2 <= M2_temp(40 downto 26);
	
	M3_temp <= out_PIPE6 * reg_b0;
	MOLT3 <= M3_temp(27 downto 13);
	
	M4_temp <= out_PIPE5 * reg_b1;
	MOLT4 <= M4_temp (27 downto 13);

	ADD1 <= (out_PIPE1(13) & out_PIPE1)-out_PIPE2;
	ADD2 <= out_RET4 + out_PIPE3; 
	y <= out_PIPE7+out_PIPE8;
	
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
	
	FFVIN		: FFs PORT MAP (VIN,clk,resn,en_VIN,reg_en);
	FFPIPE_VOUT1	: FFs PORT MAP (reg_en,clk,resn,en_VOUT,out_FFVOUT1);
	FFPIPE_VOUT2	: FFs PORT MAP (out_FFVOUT1,clk,resn,en_VOUT,out_FFVOUT2);
	FFPIPE_VOUT3	: FFs PORT MAP (out_FFVOUT2,clk,resn,en_VOUT,out_FFVOUT3);
	FFPIPE_VOUT4	: FFs PORT MAP (out_FFVOUT3,clk,resn,en_VOUT,out_FFVOUT4);
	FFVOUT		: FFs PORT MAP (out_FFVOUT4,clk,resn,en_VOUT,VOUT);
	
	REGDIN 	: regn PORT MAP (DIN, clkn, resn, reg_en, x(13 downto 0));
	REGDOUT : regn PORT MAP (y(13 downto 0), clk, resn, en_VOUT, DOUT);
	
	REGa1 	: regn GENERIC MAP (N=>13) PORT MAP (a1(12 downto 0), clk, resn, total_en, reg_a1);
	REGb0 	: regn GENERIC MAP (N=>13) PORT MAP (b0(12 downto 0), clk, resn, total_en, reg_b0);
	REGb1 	: regn GENERIC MAP (N=>13) PORT MAP (b1(12 downto 0), clk, resn, total_en, reg_b1);
	
	R1: regn GENERIC MAP (N=>14) PORT MAP (x, clk, resn, reg_en, reg_1);
	R2: regn GENERIC MAP (N=>15) PORT MAP (ADD2, clk, resn, out_FFVOUT2, reg_2);
	
	REGPIPE_1: regn GENERIC MAP (N=>14) PORT MAP (x, clk, resn, reg_en, out_PIPE1);
	REGPIPE_2: regn GENERIC MAP (N=>15) PORT MAP (MOLT1, clk, resn, out_FFVOUT1, out_PIPE2);
	REGPIPE_3: regn GENERIC MAP (N=>15) PORT MAP (ADD1, clk, resn, out_FFVOUT1, out_PIPE3);
	REGPIPE_5: regn GENERIC MAP (N=>15) PORT MAP (ADD2, clk, resn, out_FFVOUT2, out_PIPE5);
	REGPIPE_6: regn GENERIC MAP (N=>15) PORT MAP (reg_2, clk, resn, out_FFVOUT3, out_PIPE6);
	REGPIPE_7: regn GENERIC MAP (N=>15) PORT MAP (MOLT3, clk, resn, out_FFVOUT3, out_PIPE7);
	REGPIPE_8: regn GENERIC MAP (N=>15) PORT MAP (MOLT4, clk, resn, out_FFVOUT3, out_PIPE8);
	
	REGRETIMING_4: regn GENERIC MAP (N=>15) PORT MAP (MOLT2, clk, resn, out_FFVOUT2, out_RET4);

end beh;
