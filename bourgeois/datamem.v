`include "define.v"

module datamem(clk, in, out);
  input clk, in;
  output out;
  wire clk;
  wire [`BYTE_SIZE-1:0]in;
  reg [`BLOCK_SIZE-1:0]out;
  reg [`BYTE_SIZE-1:0]data[0:`DATA_MEM_SIZE];
  reg[`WORD_SIZE-1:0] i;
    
  initial fork
  $readmemb("ram_data.txt", data);
  join
  
  always @(posedge clk) begin
      out = 0;
      for (i = 0; i < `BLOCK_SIZE / `BYTE_SIZE; i = i + 1) 
        out = (out << `BYTE_SIZE) + data[in + i];
  end
endmodule