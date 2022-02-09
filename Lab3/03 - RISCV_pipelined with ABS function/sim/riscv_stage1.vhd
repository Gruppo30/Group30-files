-- RISC-V stage 1

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RISCV_stage1 is 
 port(
	clk 			 : in std_logic;
	rst 			 : in std_logic;
	en_hdu			 : in std_logic;
	rst_hdu			 : in std_logic;
	instruction 	 : in  std_logic_vector(31 downto 0);
	en_pcreg		 : in std_logic;
	
	hazard_control	 : in std_logic;
	branch_cntr		 : in  std_logic;
	jump_addr		 : in std_logic_vector(63 downto 0);
	
	hazard_control_out : out std_logic;
	PC_out             : out std_logic_vector(63 downto 0);
	current_addr_out   : out std_logic_vector(63 downto 0);
	instruction_out    : out std_logic_vector(31 downto 0)
	);
end RISCV_stage1;

architecture arc of RISCV_stage1 is	

	-- internal signals declaration
	signal PCreg_in	    : std_logic_vector(63 downto 0);
	signal pcreg_out    : std_logic_vector(63 downto 0);

	signal adder_out	: std_logic_vector(63 downto 0);
	
	signal signal4  : std_logic_vector(63 downto 0); 
	
	
	--internal components declaration
	component regn IS
	GENERIC ( N : integer := 64);
	PORT (R 	 : IN std_logic_vector(N-1 DOWNTO 0);
		  Clock  : IN STD_LOGIC;
		  Resetn : IN STD_LOGIC;
	          Enable : IN STD_LOGIC;
		  Q      : OUT std_logic_vector(N-1 DOWNTO 0));
	END component regn;
	
	component adder IS
		port(
			in_adder_A : IN  std_logic_vector(63 downto 0);
			in_adder_B : IN  std_logic_vector(63 downto 0);
			result	   : OUT std_logic_vector(63 downto 0)
			);
	END component;
	
	component mux is
		PORT( 
		  datain_a : in  std_logic_vector(63 downto 0);
		  datain_b : in  std_logic_vector(63 downto 0);
		  sel	   : in  std_logic;
		  dataout  : out std_logic_vector(63 downto 0)
		 );
	end component;


begin
	
	signal4 <= "0000000000000000000000000000000000000000000000000000000000000100";
	
	-- 
	process(clk, instruction,rst,en_hdu) is
	begin
		if(rst = '0') then
			instruction_out <= (others => '0');
			current_addr_out <= (others => '0');
			hazard_control_out <='0';
		elsif(clk 'event and clk = '1') then
			hazard_control_out <= hazard_control;
			if(en_hdu ='1') then
				instruction_out <= instruction;
				current_addr_out <= pcreg_out;
			elsif(rst_hdu = '0') then 
				instruction_out <= (others => '0');
				current_addr_out <= (others => '0');
				hazard_control_out <='0';
			end if;
		end if;
	end process;
	
	-- port map
	PCreg : regn  port map(pcreg_in, clk, rst, en_pcreg, pcreg_out);
	Add4  : adder port map(pcreg_out, signal4, adder_out);
	PCmux : mux   port map(adder_out, jump_addr, branch_cntr, pcreg_in); 
	PC_out <= pcreg_out;
	
	


end arc;