LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY mux32to1 IS
	PORT (	input0  : IN  std_logic_vector(63 DOWNTO 0);
			input1  : IN  std_logic_vector(63 DOWNTO 0);
			input2  : IN  std_logic_vector(63 DOWNTO 0);
			input3  : IN  std_logic_vector(63 DOWNTO 0);
			input4  : IN  std_logic_vector(63 DOWNTO 0);
			input5  : IN  std_logic_vector(63 DOWNTO 0);
			input6  : IN  std_logic_vector(63 DOWNTO 0);
			input7  : IN  std_logic_vector(63 DOWNTO 0);
			input8  : IN  std_logic_vector(63 DOWNTO 0);
			input9  : IN  std_logic_vector(63 DOWNTO 0);
			input10  : IN  std_logic_vector(63 DOWNTO 0);
			input11  : IN  std_logic_vector(63 DOWNTO 0);
			input12  : IN  std_logic_vector(63 DOWNTO 0);
			input13  : IN  std_logic_vector(63 DOWNTO 0);
			input14  : IN  std_logic_vector(63 DOWNTO 0);
			input15  : IN  std_logic_vector(63 DOWNTO 0);
			input16  : IN  std_logic_vector(63 DOWNTO 0);
			input17  : IN  std_logic_vector(63 DOWNTO 0);
			input18  : IN  std_logic_vector(63 DOWNTO 0);
			input19  : IN  std_logic_vector(63 DOWNTO 0);
			input20  : IN  std_logic_vector(63 DOWNTO 0);
			input21  : IN  std_logic_vector(63 DOWNTO 0);
			input22  : IN  std_logic_vector(63 DOWNTO 0);
			input23  : IN  std_logic_vector(63 DOWNTO 0);
			input24  : IN  std_logic_vector(63 DOWNTO 0);
			input25  : IN  std_logic_vector(63 DOWNTO 0);
			input26  : IN  std_logic_vector(63 DOWNTO 0);
			input27  : IN  std_logic_vector(63 DOWNTO 0);
			input28  : IN  std_logic_vector(63 DOWNTO 0);
			input29  : IN  std_logic_vector(63 DOWNTO 0);
			input30  : IN  std_logic_vector(63 DOWNTO 0);
			input31  : IN  std_logic_vector(63 DOWNTO 0);
			sel  : IN  STD_LOGIC_vector(4 downto 0);
			output : OUT std_logic_vector(63 DOWNTO 0));
END mux32to1;

ARCHITECTURE Behavior OF mux32to1 IS

	BEGIN
	
	with sel select output <=
		input0 when  "00000",
		input1 when  "00001",
		input2 when  "00010",
		input3 when  "00011",
		input4 when  "00100",
		input5 when  "00101",
		input6 when  "00110",
		input7 when  "00111",
		input8 when  "01000",
		input9 when  "01001",
		input10 when "01010",
		input11 when "01011",
		input12 when "01100",
		input13 when "01101",
		input14 when "01110",
		input15 when "01111",
		input16 when "10000",
		input17 when "10001",
		input18 when "10010",
		input19 when "10011",
		input20 when "10100",
		input21 when "10101",
		input22 when "10110",
		input23 when "11111",
		input24 when "11000",
		input25 when "11001",
		input26 when "11010",
		input27 when "11011",
		input28 when "11100",
		input29 when "11101",
		input30 when "11110",
		input31 when others;
	
END Behavior;