`include "define.v"

module RRS(r,writable,write,out);
  input[5:0] r; // 64 registers
  input writable; // write(1) or read(0)
  input[`UNIT_SIZE-1:0] write;
  output reg[`UNIT_SIZE-1:0] out; // which unit is using this register
  
  reg[`UNIT_SIZE-1:0] rrs[63:0];
  
  always begin
    if (writable == 1) 
	  rrs[r] = write;
	else
	  out = rrs[r];
  end
endmodule