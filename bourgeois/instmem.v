`include "define.v"

module instmem(clk, in, out);
  input clk, in;
  output out;
  wire clk;
  wire[`WORD_SIZE-1:0] in;
  reg[`BLOCK_SIZE-1:0] out;
  reg[`BYTE_SIZE-1:0] inst[0:`INST_MEM_SIZE];
  reg[`WORD_SIZE-1:0] i;

  initial begin
    $readmemb("input.bin", inst);
  end
  
  always @(posedge clk) begin
      out = 0;
      for (i = 0; i < `BLOCK_SIZE / `BYTE_SIZE; i = i + 1) 
        out = (out << `BYTE_SIZE) + inst[in + i];
  end
endmodule
