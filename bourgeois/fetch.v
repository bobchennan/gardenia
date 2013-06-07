`include "define.v"
`include "instcache.v"

module fetch(clk, pc, instr, newpc);
	input clk;
	input pc;
	reg[`BYTE_SIZE-1:0] pc;
	output instr;
	reg[`WORD_SIZE-1:0] instr[`MULTIPLE_ISSUE-1:0];
	output newpc;
	reg[`BYTE_SIZE-1:0] newpc;
	reg[`WORD_SIZE-1:0] out[`MULTIPLE_ISSUE-1:0];
	
	generate
		genvar i;
		for(i=0;i<`MULTIPLE_ISSUE;i=i+1)
		begin:cnx
			instcache inst(.clk(clk), .in(pc), .out(out[i]));
		end
	endgenerate
	
	always @(posedge clk) begin
		
	end
endmodule