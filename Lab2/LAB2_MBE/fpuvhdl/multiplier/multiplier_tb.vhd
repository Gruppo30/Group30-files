-- MULTIPLIER TESTBENCH
-- this file contains the testbench implemented to verify the FPmul multiplier behaviour;
-- it generates the system clock and reads from file the input values to be fed to the multiplier.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

ENTITY multiplier_tb IS
END multiplier_tb ;

architecture tb_arch of multiplier_tb is
    
	-- DUT declaration as internal component
    COMPONENT FPmul IS
       PORT( 
          FP_A : IN     std_logic_vector (31 DOWNTO 0);
          FP_B : IN     std_logic_vector (31 DOWNTO 0);
          clk  : IN     std_logic;
          FP_Z : OUT    std_logic_vector (31 DOWNTO 0)
       );
    END COMPONENT FPmul ;
    
	-- internal signals declaration
    signal clk_tb : std_logic;
    signal a,b,z : std_logic_vector (31 downto 0);
    
 begin
    
	-- this process allows to read the multiplier inputs from file
   process (CLK_tb)
      file fp : text open read_mode is "./fp_samples.hex";
      variable ptr : line;
      variable val : std_logic_vector(31 downto 0);
   begin  -- process
      if CLK_tb'event and CLK_tb = '1' then  -- rising clock edge
         if (not(endfile(fp))) then
             readline(fp, ptr);
             hread(ptr, val);        
         end if;
         a <= val;
         b <= val;
      end if;
   end process;

	-- process for the definition of the clock        
    process 
    begin 
       clk_tb <='0';
       wait for 2 us;
       clk_tb <='1';
       wait for 2 us;
    end process;
    
		-- DUT port map
    DUT: FPmul PORT MAP (a,b,clk_tb,z);
        
    end tb_arch;