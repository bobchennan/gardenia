`include "define.v"

//to do register file

module Regfile(Clk, Raddr, Rval, Write, Waddr, WVal);
	input Clk;
	input[5:0] Raddr;
	output Rval;
	input Write;
	input[5:0] Waddr;
	input[31:0] WVal;
	
	reg[31:0] Rval;
	reg[31:0] Regs[63:0];
	
	initial begin:cnx
		integer i;
		for(i=0;i<64;i=i+1)
			Regs[i]<=0;
	end
	
	always @(posedge Clk)begin
		if(Write==1'b1)
			Regs[Waddr] = WVal;
	end
	
	always @(Regs[Raddr] or Raddr)begin
		Rval = Regs[Raddr];
	end

endmodule
