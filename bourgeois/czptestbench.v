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
  datacache data(clkout, in, readable, writable, write, out, over);
  initial fork
    readable = 0;
    writable = 0;
    #1 in = `WORD_SIZE'b0;
    #2 readable = 1;
    #106 $display("%b", out);
    #107 readable = 0;
    #210 in = `WORD_SIZE'b1000;
    #211 readable = 1;
    #216 $display("%b", out);
    #217 readable = 0;
  join
endmodule
