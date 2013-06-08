`include "define.v"
`include "fetch.v"
`include "clock.v"

module CPU();
  wire[`BLOCK_SIZE-1:0] newpc;
  
  wire clkout;
  clock clk(.out(clkout));
  fetch fet(.clk(clkout), .pc(`BLOCK_SIZE'b0), .newpc(newpc));
endmodule
