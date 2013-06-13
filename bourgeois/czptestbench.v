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
    #210 in = `WORD_SIZE'b1;
    #210 write = 32'b111101;
    #211 readable = 1;
    #211 writable = 1;
    #216 $display("%b", out);
    #217 readable = 0;
    #217 writable = 0;
    #220 in = `WORD_SIZE'b1;
    #221 readable = 1;
    #226 $display("%b", out);
    #227 readable = 0;
    #230 in = `WORD_SIZE'b10;
    #231 readable = 1;
    #236 $display("%b", out);
    #237 readable = 0;
  join
endmodule
