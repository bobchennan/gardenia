`include "datacache.v"
`include "define.v"
`include "clock.v"

module czptestbench();
  wire clkout;
  clock clk(.out(clkout));
  
  reg[`WORD_SIZE-1:0] in; // address
  reg readable, writable;
  reg[`WORD_SIZE-1:0] write;
  wire[`WORD_SIZE-1:0] out;
  wire over;
  datacache data(clkout, in, readable, 1'b0, write, out, over);
  wire[`BLOCK_SIZE-1:0] out1, out2;
  datamem dm(clkout, in, readable, 1'b0, write, out1, out2);
  initial fork
    readable = 0;
    #1 in = `WORD_SIZE'b0;
    #2 readable = 1;
    #6 $display("%b %b", out, out1);
    #7 readable = 0;
    #10 in = `WORD_SIZE'b1;
    #11 readable = 1;
    #16 $display("%b %b", out, out1);
    #17 readable = 0;
    #20 in = `WORD_SIZE'b10;
    #21 readable = 1;
    #26 $display("%b %b", out, out1);
    #27 readable = 0;
    #30 in = `WORD_SIZE'b11;
    #31 readable = 1;
    #36 $display("%b %b", out, out1);
    #37 readable = 0;
  join
endmodule
