`include "define.v"

module RRS(clk, r, writable, write, inrf, out, outrf);
  input clk;
  input[5:0] r; // 64 registers
  input writable; // write(1) or read(0)
  input[`UNIT_SIZE-1:0] write;
  input signed[`WORD_SIZE-1:0] inrf;
  output reg[`UNIT_SIZE-1:0] out; // which unit is using this register
  output reg signed[`WORD_SIZE-1:0] outrf; // whether the register has its value
  
  reg[`UNIT_SIZE-1:0] rrs[63:0];
  reg[`WORD_SIZE-1:0] rf[63:0];
  reg[`WORD_SIZE-1:0] i;
  initial begin
    for (i = 0; i < 64; i = i + 1) begin
      rrs[i] = 8'b01111111;
      rrs[i] = 0;
    end
  end
  
  always begin
    if (writable == 1) begin
      rrs[r] = write;
      if (write == 8'b01111111) 
        rf[r] = inrf;
	  end	else begin
      out = rrs[r];
      if (rrs[r] == 8'b01111111)
        outrf = rf[r];
    end
  end
endmodule