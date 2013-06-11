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
    #106 $display("%b %b", out, out1);
    #107 readable = 0;
    #210 in = `WORD_SIZE'b1;
    #211 readable = 1;
    #316 $display("%b %b", out, out1);
    #317 readable = 0;
    #420 in = `WORD_SIZE'b10;
    #421 readable = 1;
    #526 $display("%b %b", out, out1);
    #527 readable = 0;
    #630 in = `WORD_SIZE'b11;
    #631 readable = 1;
    #736 $display("%b %b", out, out1);
    #737 readable = 0;
  join
endmodule
