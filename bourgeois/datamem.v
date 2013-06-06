`include "define.v"

module datamem(clk, in, out);
  input clk, in;
  output out;
  wire clk;
  wire [`BYTE_SIZE-1:0]in;
  reg [`BLOCK_SIZE-1:0]out;
  reg [`BYTE_SIZE-1:0]data[0:`DATA_MEM_SIZE];
  initial fork
  $readmemb("ram_data.txt", data);
  join
  always @(posedge clk)
    fork
      
    join
endmodule