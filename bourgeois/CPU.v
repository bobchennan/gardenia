`include "define.v"
`include "fetch.v"
`include "clock.v"

module CPU();
  wire[`WORD_SIZE-1:0] newpc;
  
  wire clkout;
  clock clk(.out(clkout));
  fetch fet(.clk(clkout), .pc(`WORD_SIZE'b0), .newpc(newpc));
  
  
endmodule
