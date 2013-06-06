`include "define.v"
`include "instmem.v"
`include "clock.v"

module CPU();
  reg[`WORD_SIZE-1:0] in;
  wire[`BLOCK_SIZE-1:0] out1, out2;
  
  wire clkout;
  clock clk(.out(clkout));
  instmem inst(.clk(clkout), .in(in), .writable(1), .write(1024'b11110), .out1(out1), .out2(out2));
  
  initial fork
    in = 8'b00000000;
    #10 $display("%b", out1);
    #20 in = 8'b00001000;
    #30 $display("%b", out1);
  join
endmodule
