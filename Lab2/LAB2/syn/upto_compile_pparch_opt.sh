analyze -f vhdl -lib WORK ../fpuvhdl/common/fpnormalize_fpnormalize.vhd
analyze -f vhdl -lib WORK ../fpuvhdl/common/fpround_fpround.vhd
analyze -f vhdl -lib WORK ../fpuvhdl/common/packfp_packfp.vhd
analyze -f vhdl -lib WORK ../fpuvhdl/common/unpackfp_unpackfp.vhd
analyze -f vhdl -lib WORK ../fpuvhdl/multiplier/FFs.vhd
analyze -f vhdl -lib WORK ../fpuvhdl/multiplier/regn.vhd
analyze -f vhdl -lib WORK ../fpuvhdl/multiplier/fpmul_pipeline.vhd
analyze -f vhdl -lib WORK ../fpuvhdl/multiplier/fpmul_stage1_struct.vhd
analyze -f vhdl -lib WORK ../fpuvhdl/multiplier/fpmul_stage2_struct.vhd
analyze -f vhdl -lib WORK ../fpuvhdl/multiplier/fpmul_stage3_struct.vhd
analyze -f vhdl -lib WORK ../fpuvhdl/multiplier/fpmul_stage4_struct.vhd
set power_preserve_rtl_hier_names true
elaborate FPmul -arch pipeline -lib WORK > ./results_optimize_reg/elaborate_pparch.txt
uniquify
link
create_clock -name MY_CLK -period 0.82 clk
set_dont_touch_network MY_CLK
set_clock_uncertainty 0.07 [get_clocks MY_CLK]
set_input_delay 0.5 -max -clock MY_CLK [remove_from_collection [all_inputs] clk]
set_output_delay 0.5 -max -clock MY_CLK [all_outputs]
set OLOAD [load_of NangateOpenCellLibrary/BUF_X4/A]
set_load $OLOAD [all_outputs]
ungroup -all -flatten
set_implementation DW02_mult/pparch [find cell *mult*]
compile
optimize_registers
report_timing
report_timing > ./results_optimize_reg/report_timing_pparch.txt
report_area > ./results_optimize_reg/report_area_pparch.txt
report_resources > ./results_optimize_reg/report_resources_pparch.txt
