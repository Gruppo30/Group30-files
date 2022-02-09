LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY reg_barrel IS
	PORT (input  : IN  std_logic_vector(63 DOWNTO 0);
		  shift  : IN  STD_LOGIC_vector(4 downto 0);
		  output_sh : OUT std_logic_vector(63 DOWNTO 0));
END reg_barrel;

ARCHITECTURE Behavior OF reg_barrel IS

	component mux32to1 IS
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
END component;

	signal sign_ext : std_logic_vector (30 downto 0);
	signal concatenated_data : std_logic_vector(94 downto 0);
	
	BEGIN
	
	sign_ext <= (others => input(63));
	concatenated_data <= sign_ext & input;
	
	mux_barrel: mux32to1 port map(
		input0  => concatenated_data(63 downto 0),
		input1  => concatenated_data(64 downto 1),
		input2  => concatenated_data(65 downto 2),
		input3  => concatenated_data(66 downto 3),
		input4  => concatenated_data(67 downto 4),
		input5  => concatenated_data(68 downto 5),
		input6  => concatenated_data(69 downto 6),
		input7  => concatenated_data(70 downto 7),
		input8  => concatenated_data(71 downto 8),
		input9  => concatenated_data(72 downto 9),
		input10 => concatenated_data(73 downto 10),
		input11 => concatenated_data(74 downto 11),
		input12 => concatenated_data(75 downto 12),
		input13 => concatenated_data(76 downto 13),
		input14 => concatenated_data(77 downto 14),
		input15 => concatenated_data(78 downto 15),
		input16 => concatenated_data(79 downto 16),
		input17 => concatenated_data(80 downto 17),
		input18 => concatenated_data(81 downto 18),
		input19 => concatenated_data(82 downto 19),
		input20 => concatenated_data(83 downto 20),
		input21 => concatenated_data(84 downto 21),
		input22 => concatenated_data(85 downto 22),
		input23 => concatenated_data(86 downto 23),
		input24 => concatenated_data(87 downto 24),
		input25 => concatenated_data(88 downto 25),
		input26 => concatenated_data(89 downto 26),
		input27 => concatenated_data(90 downto 27),
		input28 => concatenated_data(91 downto 28),
		input29 => concatenated_data(92 downto 29),
		input30 => concatenated_data(93 downto 30),
		input31 => concatenated_data(94 downto 31),
		sel => shift,
		output => output_sh
	);
END Behavior;