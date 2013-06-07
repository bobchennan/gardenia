`include "define.v"

module datamem(clk, in, writable, write, out1, out2);
  input clk; 
  input[`WORD_SIZE-1:0] in;
  input writable;
  input[`BLOCK_SIZE-1:0] write;
  output out1, out2;
  reg[`BLOCK_SIZE-1:0] out1, out2;
  
  reg[`BYTE_SIZE-1:0] data[0:`DATA_MEM_SIZE];
  reg[`WORD_SIZE-1:0] i;
    
  initial fork
  $readmemb("ram_data.txt", data);
  join
  
  always @(posedge clk) begin
      if (writable == 0) begin
      out1 = 0;
      for (i = 0; i < `BLOCK_SIZE / `BYTE_SIZE; i = i + 1) 
        out1 = (out1 << `BYTE_SIZE) + data[in + i];
      out2 = 0;
      for (i = 0; i < `BLOCK_SIZE / `BYTE_SIZE; i = i + 1)
        out2 = (out2 << `BYTE_SIZE) + data[in + `BLOCK_SIZE / `BYTE_SIZE + i];
      end
      else begin
        for (i = 0; i < `BLOCK_SIZE / `BYTE_SIZE; i = i + 1) 
          data[in + i] = (write >> (`BLOCK_SIZE - `BYTE_SIZE * (i+1))) & 8'b11111111;
      end
  end
endmodule