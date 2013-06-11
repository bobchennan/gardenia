`include "clock.v"

module test();
  wire clkout;
  clock clk(.out(clkout));
  reg [10:0] i,abc;
  initial begin
        abc=0;
  end
  always @(negedge abc)  begin
    abc=abc+1;
    $display("%g",abc);
    
  end
endmodule
