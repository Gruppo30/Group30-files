-- VHDL Entity HAVOC.FPmul_stage2.interface
--
-- Created by
-- Guillermo Marcus, gmarcus@ieee.org
-- using Mentor Graphics FPGA Advantage tools.
--
-- Visit "http://fpga.mty.itesm.mx" for more info.
--
-- 2003-2004. V1.0
--

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY FPmul_stage2 IS
   PORT( 
      A_EXP           : IN     std_logic_vector (7 DOWNTO 0);
      A_SIG           : IN     std_logic_vector (31 DOWNTO 0);
      B_EXP           : IN     std_logic_vector (7 DOWNTO 0);
      B_SIG           : IN     std_logic_vector (31 DOWNTO 0);
      SIGN_out_stage1 : IN     std_logic;
      clk             : IN     std_logic;
      isINF_stage1    : IN     std_logic;
      isNaN_stage1    : IN     std_logic;
      isZ_tab_stage1  : IN     std_logic;
      EXP_in          : OUT    std_logic_vector (7 DOWNTO 0);
      EXP_neg_stage2  : OUT    std_logic;
      EXP_pos_stage2  : OUT    std_logic;
      SIGN_out_stage2 : OUT    std_logic;
      SIG_in          : OUT    std_logic_vector (27 DOWNTO 0);
      isINF_stage2    : OUT    std_logic;
      isNaN_stage2    : OUT    std_logic;
      isZ_tab_stage2  : OUT    std_logic
   );

-- Declarations

END FPmul_stage2 ;

--
-- VHDL Architecture HAVOC.FPmul_stage2.struct
--
-- Created by
-- Guillermo Marcus, gmarcus@ieee.org
-- using Mentor Graphics FPGA Advantage tools.
--
-- Visit "http://fpga.mty.itesm.mx" for more info.
--
-- Copyright 2003-2004. V1.0
--


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;


ARCHITECTURE struct OF FPmul_stage2 IS

   -- Architecture declarations
   COMPONENT regn IS
   GENERIC ( N : integer:=14);
   PORT (R : IN std_logic_vector(N-1 DOWNTO 0);
      Clock, Resetn : IN STD_LOGIC;
      Q : OUT std_logic_vector(N-1 DOWNTO 0));
   END COMPONENT regn;
   
   COMPONENT FFs IS
	   PORT (	R,Clock, Resetn : IN STD_LOGIC;
			   Q : OUT STD_LOGIC);
   END COMPONENT FFs;

	COMPONENT MBE is
	port (X_MBE, A_MBE : in std_logic_vector (31 downto 0);
		product_res : OUT std_logic_vector(63 downto 0)
		  );
	end COMPONENT MBE;

   -- Internal signal declarations
   SIGNAL EXP_in_int     	 : std_logic_vector(7 DOWNTO 0);
   SIGNAL EXP_in_tmp 		 : std_logic_vector(7 DOWNTO 0);
   SIGNAL EXP_neg_int    	 : std_logic;
   SIGNAL EXP_neg_stage2_tmp : std_logic;
   SIGNAL EXP_pos_int    	 : std_logic;
   SIGNAL EXP_pos_stage2_tmp : std_logic;
   SIGNAL SIG_in_int      	 : std_logic_vector(27 DOWNTO 0);
   SIGNAL SIG_in_tmp 		 : std_logic_vector(27 DOWNTO 0);
   SIGNAL dout           	 : std_logic;
   SIGNAL dout1          	 : std_logic_vector(7 DOWNTO 0);
   SIGNAL prod           	 : std_logic_vector(63 DOWNTO 0);
   SIGNAL isZ_tab_stage1_tmp  : std_logic;
   SIGNAL isINF_stage1_tmp    : std_logic;
   SIGNAL isNaN_stage1_tmp    : std_logic;
   SIGNAL SIGN_out_stage1_tmp : std_logic;

BEGIN
   -- Architecture concurrent statements
   -- HDL Embedded Text Block 1 sig
   -- eb1 1
   SIG_in_int <= prod(47 DOWNTO 20);

   -- HDL Embedded Text Block 2 inv
   -- eb5 5
   EXP_in_int <= (NOT dout1(7)) & dout1(6 DOWNTO 0);

   -- HDL Embedded Text Block 3 latch
   -- eb2 2
   
   PROCESS(clk)
   BEGIN
      IF RISING_EDGE(clk) THEN
         EXP_in_tmp <= EXP_in_int;
         SIG_in_tmp <= SIG_in_int;
         EXP_pos_stage2_tmp <= EXP_pos_int;
         EXP_neg_stage2_tmp <= EXP_neg_int;
      END IF;
   END PROCESS;

   -- output registers port map 
   reg_sig_in  : regn GENERIC MAP (N=>28) PORT MAP (SIG_in_tmp,clk,'1',SIG_in);
   reg_exp_in  : regn GENERIC MAP (N=>8)  PORT MAP (EXP_in_tmp,clk,'1',EXP_in);
   FF_EXP_pos  : FFs PORT MAP(EXP_pos_stage2_tmp,clk,'1',EXP_pos_stage2);
   FF_EXP_neg  : FFs PORT MAP(EXP_neg_stage2_tmp,clk,'1',EXP_neg_stage2);
   FF_tab      : FFs PORT MAP(isZ_tab_stage1_tmp, clk,'1',isZ_tab_stage2);
   FF_Nan      : FFs PORT MAP(isNaN_stage1_tmp,   clk,'1',isNaN_stage2);
   FF_inf      : FFs PORT MAP(isINF_stage1_tmp,   clk,'1',isINF_stage2);
   FF_sign_out : FFs PORT MAP(SIGN_out_stage1_tmp,clk,'1',SIGN_out_stage2);

   -- HDL Embedded Text Block 4 latch2
   -- latch2 4
   PROCESS(clk)
   BEGIN
      IF RISING_EDGE(clk) THEN
         isINF_stage1_tmp    <= isINF_stage1;
         isNaN_stage1_tmp    <= isNaN_stage1;
         isZ_tab_stage1_tmp  <= isZ_tab_stage1;
         SIGN_out_stage1_tmp <= SIGN_out_stage1;
      END IF;
   END PROCESS;

   -- HDL Embedded Text Block 5 eb1
   -- exp_pos 5
   EXP_pos_int <= A_EXP(7) AND B_EXP(7);
   
   EXP_neg_int <= '1' WHEN ( (A_EXP(7)='0' AND NOT (A_EXP=X"7F")) AND (B_EXP(7)='0' AND NOT (B_EXP=X"7F")) ) ELSE '0';

   -- ModuleWare code(v1.1) for instance 'I4' of 'add'
   I4combo: PROCESS (A_EXP, B_EXP, dout)
   VARIABLE mw_I4t0 : std_logic_vector(8 DOWNTO 0);
   VARIABLE mw_I4t1 : std_logic_vector(8 DOWNTO 0);
   VARIABLE mw_I4sum : unsigned(8 DOWNTO 0);
   VARIABLE mw_I4carry : std_logic;
   BEGIN
      mw_I4t0 := '0' & A_EXP;
      mw_I4t1 := '0' & B_EXP;
      mw_I4carry := dout;
      mw_I4sum := unsigned(mw_I4t0) + unsigned(mw_I4t1) + mw_I4carry;
      dout1 <= conv_std_logic_vector(mw_I4sum(7 DOWNTO 0),8);
   END PROCESS I4combo;
  

   -- ModuleWare code(v1.1) for instance 'I2' of 'mult'
  -- I2combo : PROCESS (A_SIG, B_SIG)
   --VARIABLE dtemp : unsigned(63 DOWNTO 0);
   --BEGIN
      --dtemp := (unsigned(A_SIG) * unsigned(B_SIG));
      --prod <= std_logic_vector(dtemp);
  -- END PROCESS I2combo;

   -- ModuleWare code(v1.1) for instance 'I6' of 'vdd'
   dout <= '1';

   -- Instance port mappings.

	MBE : MBE PORT MAP (A_SIG, B_SIG, prod);

END struct;
