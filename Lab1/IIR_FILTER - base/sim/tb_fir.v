//`timescale 1ns

module tb_fir ();

   wire clk_i;
   wire RST_n_i;
   wire [13:0] DIN_i;
   wire VIN_i;
   wire [13:0] a0_i;
   wire [13:0] a1_i;
   wire [13:0] b0_i;
   wire [13:0] b1_i;
   wire [13:0] DOUT_i;
   wire VOUT_i;
   wire END_SIM_i;
   wire R_i;
   wire en_i;
   wire Q_i;
   wire [13:0] R1_i;
   wire [13:0] Q1_i;

   clk_gen CG(.END_SIM(END_SIM_i),
  	      .clk(clk_i),
	      .RST_n(RST_n_i));

   data_maker SM(.clk(clk_i),
	         .RST_n(RST_n_i),
		 .VOUT(VIN_i),
		 .DOUT(DIN_i),
		 .a0(a0_i),
		 .a1(a1_i),
		 .b0(b0_i),
		 .b1(b1_i),
		 .END_SIM(END_SIM_i));

   IIR_FILTER UUT(.clk(clk_i),
	     .resn(RST_n_i),
             .VIN(VIN_i),
	     .DIN(DIN_i),
	     .b0(b0_i),
	     .b1(b1_i),
	     .a1(a1_i),
             .DOUT(DOUT_i),
             .VOUT(VOUT_i));

   data_sink DS(.clk(clk_i),
		.RST_n(RST_n_i),
		.VIN(VOUT_i),
		.DIN(DOUT_i)); 

  
   FFs FF(.R(R_I),
          .Clock(clk_i),
	  .Resetn(RST_n_i),
          .en(en_i),
          .Q(Q_i));

    regn RG(.R(R1_i),
            .Clock(clk_i),
            .Resetn(RST_n_i),
            .Enable(en_i),
            .Q(Q1_i));

endmodule

		   
