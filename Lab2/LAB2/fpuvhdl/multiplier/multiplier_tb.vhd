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
    
	-- declaration of UUT as internal component 
    COMPONENT FPmul IS
       PORT( 
          FP_A : IN     std_logic_vector (31 DOWNTO 0);
          FP_B : IN     std_logic_vector (31 DOWNTO 0);
          clk  : IN     std_logic;
          FP_Z : OUT    std_logic_vector (31 DOWNTO 0)
       );
    END COMPONENT FPmul ;
    
    signal clk_tb : std_logic;
    signal a,b,z : std_logic_vector (31 downto 0);
    
    begin
        
    process (CLK_tb)                         -- synchronous process 
		file fp : text open read_mode is "./fp_samples.hex";
		variable ptr : line;
		variable val : std_logic_vector(31 downto 0);
    begin  -- process
      if CLK_tb'event and CLK_tb = '1' then  -- rising clock edge
         if (not(endfile(fp))) then
             readline(fp, ptr);				 -- reads from file the values to be fed to the multiplier
             hread(ptr, val);        
         end if;
         a <= val;                           -- both variables assume the same value so that the 
         b <= val;                           -- multiplier will compute the square value 
      end if;
   end process;
        
    process                                  -- implementation of the clock signal with a period of 4 us 
    begin 
       clk_tb <='0';
       wait for 2 us;
       clk_tb <='1';
       wait for 2 us;
    end process;
    
	-- port map of DUT 
    DUT: FPmul PORT MAP (a,b,clk_tb,z);
        
    end tb_arch;