`include "define.v"

module instmem(clk, in, readable, writable, write, out1, out2);
  input clk;
  input[`WORD_SIZE-1:0] in; // address
  input readable, writable;
  input[`BLOCK_SIZE-1:0] write;
  output out1, out2;
  reg[`BLOCK_SIZE-1:0] out1, out2;
  
  reg[`BYTE_SIZE-1:0] inst[0:`INST_MEM_SIZE];
  reg[`WORD_SIZE-1:0] i;

  initial begin
    for(i=0;i<`INST_MEM_SIZE;i=i+1)
      inst[i]=`BYTE_SIZE'b00000000;
    $readmemb("input.bin", inst);
  end
  
  always @(posedge clk) begin
    if (writable == 1) begin
        for (i = 0; i < `BLOCK_SIZE / `BYTE_SIZE; i = i + 1) 
          inst[(in >> 7 << 7) + i] = (write >> (`BLOCK_SIZE - `BYTE_SIZE * (i+1))) & 8'b11111111;
    end
    if (readable == 1) begin
      out1 = 0;
      for (i = 0; i < `BLOCK_SIZE / `BYTE_SIZE; i = i + 1) 
        out1 = (out1 << `BYTE_SIZE) + inst[(in >> 7 << 7) + i];
      out2 = 0;
      for (i = 0; i < `BLOCK_SIZE / `BYTE_SIZE; i = i + 1)
        out2 = (out2 << `BYTE_SIZE) + inst[(in >> 7 << 7) + `BLOCK_SIZE / `BYTE_SIZE + i];
    end
  end
endmodule
