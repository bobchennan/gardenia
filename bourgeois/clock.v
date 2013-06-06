`include "define.v"

module clock(out);
  output out;
  reg out;
  
  initial begin
    out = 0;
  end
  
  always begin
    #1 out = ~out;
  end
endmodule