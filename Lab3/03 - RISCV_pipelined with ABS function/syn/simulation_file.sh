analyze -f vhdl -lib WORK ../sim/absALU.vhd
analyze -f vhdl -lib WORK ../sim/adder.vhd
analyze -f vhdl -lib WORK ../sim/ALU.vhd
analyze -f vhdl -lib WORK ../sim/comparator.vhd
analyze -f vhdl -lib WORK ../sim/controlALU.vhd

analyze -f vhdl -lib WORK ../sim/decoder.vhd
analyze -f vhdl -lib WORK ../sim/fwd_unit.vhd
analyze -f vhdl -lib WORK ../sim/hazard_unit.vhd
analyze -f vhdl -lib WORK ../sim/ImmediateGenerator.vhd

analyze -f vhdl -lib WORK ../sim/mux.vhd
analyze -f vhdl -lib WORK ../sim/mux_4to1.vhd
analyze -f vhdl -lib WORK ../sim/regFile.vhd
analyze -f vhdl -lib WORK ../sim/regn.vhd
analyze -f vhdl -lib WORK ../sim/riscv.vhd
analyze -f vhdl -lib WORK ../sim/riscv_stage1.vhd
analyze -f vhdl -lib WORK ../sim/riscv_stage2.vhd
analyze -f vhdl -lib WORK ../sim/riscv_stage3.vhd
analyze -f vhdl -lib WORK ../sim/riscv_stage4.vhd
analyze -f vhdl -lib WORK ../sim/riscv_stage5.vhd

analyze -f vhdl -lib WORK ../sim/reg_barrel.vhd
analyze -f vhdl -lib WORK ../sim/mux32to1.vhd

set power_preserve_rtl_hier_names true
elaborate riscv -arch arc -lib WORK > ./elaborate.txt



uniquify
link
create_clock -name MY_CLK -period 10 clk
set_dont_touch_network MY_CLK
set_clock_uncertainty 0.07 [get_clocks MY_CLK]
set_input_delay 0.5 -max -clock MY_CLK [remove_from_collection [all_inputs] CLK]
set_output_delay 0.5 -max -clock MY_CLK [all_outputs]
set OLOAD [load_of NangateOpenCellLibrary/BUF_X4/A]
set_load $OLOAD [all_outputs]
compile
report_timing > ./report_timing.txt
report_area > ./report_area.txt
ungroup -all -flatten
change_names -hierarchy -rules verilog
write_sdf ../netlist/riscv.sdf
write -f verilog -hierarchy -output ../netlist/RISCV.v
write_sdc ../netlist/riscv.sdc
quit 
