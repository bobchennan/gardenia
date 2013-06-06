`include "define.v"
`include "instmem.v"
`include "clock.v"

module CPU();
  reg [`WORD_SIZE-1:0]in;
  wire [`BLOCK_SIZE-1:0]out;
  
  wire clkout;
  clock clk(.out(clkout));
  instmem inst(.clk(clkout), .in(in), .out(out));
  
  initial fork
    in = 8'b00000000;
    #10 $display("%b", out);
    #20 in = 8'b00001000;
    #30 $display("%b", out);
  join
endmodule
