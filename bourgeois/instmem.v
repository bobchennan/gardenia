`include "define.v"

module instmem(clk, in, out);
  input clk, in;
  output out;
  wire clk;
  wire[`WORD_SIZE-1:0] in;
  reg[`BLOCK_SIZE-1:0] out;
  reg[`BYTE_SIZE-1:0] inst[0:`INST_MEM_SIZE];
  initial fork
  $readmemb("input.bin", inst);
  join
  always @(posedge clk) begin: block1
      reg [`WORD_SIZE-1:0] i;
      for (i = 0; i < `BLOCK_SIZE / `BYTE_SIZE; i = i + 1)
        out = out << `BYTE_SIZE + inst[in + i * `BYTE_SIZE];
  end
endmodule
