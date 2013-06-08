`include "define.v"
`include "instmem.v"
`include "instcache.v"
`include "clock.v"

module CPU();
  reg[`WORD_SIZE-1:0] in;
  wire[`BLOCK_SIZE-1:0] out1, out2;
  wire[`BLOCK_SIZE-1:0] out;
  
  wire clkout;
  clock clk(.out(clkout));
  instmem instm(.clk(clkout), .in(in), .readable(1), .writable(0), .write(1024'b11110), .out1(out1), .out2(out2));
  //instcache instc(.clk(clkout), .in(in), .out(out));

  
  initial fork
    #1 in=129;
    #2 $display("%b", in);
    #3 $display("%b", out1);
  join
endmodule
