`include "define.v"

module RRS(clk, r, writable, write, inrf, out, outrf, check);
  input clk;
  input[5:0] r; // 64 registers
  input writable; // write(1) or read(0)
  input[`UNIT_SIZE-1:0] write;
  input signed[`WORD_SIZE-1:0] inrf;
  output reg[`UNIT_SIZE-1:0] out; // which unit is using this register
  output reg signed[`WORD_SIZE-1:0] outrf; // whether the register has its value
  input check;
  
  reg[`UNIT_SIZE-1:0] rrs[63:0];
  reg[`WORD_SIZE-1:0] rf[63:0];
  reg[`WORD_SIZE-1:0] i;
  initial begin
    for (i = 0; i < 64; i = i + 1) begin
      rrs[i] = 8'b01111111;
      rf[i] = 0;
    end
  end
  
  always @(check) begin
    if (check == 1) begin
      for (i = 0; i < 64; i = i + 1) 
        if (rrs[i] == write) begin
          rrs[i] = 8'b01111111;
          rf[i] = inrf;
        end
    end
  end
  always @(writable) begin
    if (writable == 1) begin
      rrs[r] = write;
      if (write == 8'b01111111) 
        rf[r] = inrf;
      $display("rrs write:%b %b %b", r, rrs[r], rf[r]);
	  end
	  out = rrs[r];
    outrf = rf[r];
	end
	always @(r) begin
    out = rrs[r];
    outrf = rf[r];
    $display("rrs:%b %b %b", r, out, outrf);
  end
endmodule