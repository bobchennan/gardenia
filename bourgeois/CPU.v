`include "define.v"
`include "fetch.v"
`include "clock.v"

module CPU();
  
  wire clkout;
  clock clk(.out(clkout));
  fetch fet(.clk(clkout));
  
  
endmodule
