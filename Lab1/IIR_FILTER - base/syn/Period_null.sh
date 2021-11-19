
analyze -f vhdl -lib WORK ../MODELSIM/IIR_FILTER.vhd
analyze -f vhdl -lib WORK ../MODELSIM/clk_gen.vhd
analyze -f vhdl -lib WORK ../MODELSIM/data_maker_new.vhd
analyze -f vhdl -lib WORK ../MODELSIM/data_sink.vhd
analyze -f vhdl -lib WORK ../MODELSIM/regn.vhd
analyze -f vhdl -lib WORK ../MODELSIM/FFs.vhd
set power_preserve_rtl_hier_names true
elaborate IIR_FILTER -arch beh -lib WORK > ./elaborate.txt
uniquify
link
create_clock -name MY_CLK -period 0 clk
set_dont_touch_network MY_CLK
set_clock_uncertainty 0.07 [get_clocks MY_CLK]
set_input_delay 0.5 -max -clock MY_CLK [remove_from_collection [all_inputs] CLK]
set_output_delay 0.5 -max -clock MY_CLK [all_outputs]
set_OLOAD [load_of NangateOpenCellLibrary/BUF_X4/A]
set_load $OLOAD [all_outputs]
compile
report_timing > ./report_timing_T0.txt
report_area > ./report_area_T0.txt
ungroup -all -flatten
change_names -hierarchy -rules verilog
write_sdf ..netlist/IIR_FILTER.sdf
write -f verilog -hierarchy -output ../netlist/IIR_FILTER.v
write_sdc ../netlist/IIR_FILTER.sdc 
