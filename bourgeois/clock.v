`include "define.v"

module clock(out);
  output out;
  reg out;
  always begin
    #1 out = ~out;
  end
endmodule