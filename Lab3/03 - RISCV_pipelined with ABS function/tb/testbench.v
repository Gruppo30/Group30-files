module tb_risc();

	wire clk_tb;
	wire rstn_tb;
	wire data_mem_we;
	wire data_mem_rd;
	wire [63:0] data_mem_addr;
	wire [63:0] data_mem_data;
	wire [63:0] data_tb;
	wire [31:0] istruction_tb;
	wire [31:0] pc_out_tb;
	
	clk_gen CG(
				.CLK(clk_tb),
				.RST_n(rstn_tb)
	);
	
	RISCV DUT(
				.clk(clk_tb),
				.rst(rstn_tb),
				.instruction(istruction_tb),
				.Data(data_tb),
				.instruction_addr(pc_out_tb),
				.DataMemory_addr(data_mem_addr),
				.DataMemory_data(data_mem_data),
				.DataMemory_rd(data_mem_rd),
				.DataMemory_wr(data_mem_we)
	);
	
	DataMemory DM(
				.clk(clk_tb),
				.rst(rstn_tb),
				.addr(data_mem_addr),
				.data(data_mem_data),
				.read_en(data_mem_rd),
				.write_en(data_mem_we),
				.data_out(data_tb)
	);
	
	InstructionMemory IM(
				.clk(clk_tb),
				.rst(rstn_tb),
				.addr(pc_out_tb),
				.data_out(istruction_tb)
	);
	
endmodule
	