`include "define.v"

module datamem(clk, in, readable, writable, write, out1, out2, flush);
  input clk;
  input[`WORD_SIZE-1:0] in; // address
  input readable, writable;
  input[`BLOCK_SIZE-1:0] write;
  output reg[`BLOCK_SIZE-1:0] out1, out2;
  input flush;
  
  reg[`BYTE_SIZE-1:0] data[0:`DATA_MEM_SIZE-1];
  reg[`WORD_SIZE-1:0] i;

  initial begin
    for(i=0;i<`DATA_MEM_SIZE;i=i+1)
      data[i]=`BYTE_SIZE'b00000000;
    $readmemh("ram_data.txt", data);
  end
  
  always @(writable) begin
    if (writable == 1) begin
        $display("write %g %b", in, write);
        for (i = 0; i < `BLOCK_SIZE / `BYTE_SIZE; i = i + 1) 
          data[(in >> 7 << 7) + i] = (write >> (`BLOCK_SIZE - `BYTE_SIZE * (i+1))) & 8'b11111111;
    end
  end
  always @(readable) begin
    if (readable == 1) begin
      out1 = 0;
      for (i = 0; i < `BLOCK_SIZE / `BYTE_SIZE; i = i + 1) 
        out1 = (out1 << `BYTE_SIZE) + data[(in >> 7 << 7) + i];
      //$display("%b", out1);
      out2 = 0;
      for (i = 0; i < `BLOCK_SIZE / `BYTE_SIZE; i = i + 1)
        out2 = (out2 << `BYTE_SIZE) + data[(in >> 7 << 7) + `BLOCK_SIZE / `BYTE_SIZE + i];
    end
  end
  always @(flush) begin
    $display("datamem halt %b", flush);
    if (flush == 1) begin: cpures
      integer outfile, i;
      outfile =  $fopen("cpures.txt");
      for (i = 0; i < `DATA_MEM_SIZE; i = i + 4) 
        $fdisplay(outfile, "%h %h %h %h", data[i], data[i+1], data[i+2], data[i+3]);
      $fclose(outfile);
      $finish(2);
    end
  end
endmodule
