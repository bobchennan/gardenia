`include "define.v"
`include "instcache.v"

module fetch(clk, pc, newpc);
  input clk;
  input[`WORD_SIZE-1:0] pc;
  output[`WORD_SIZE-1:0] newpc;
  wire[`BLOCK_SIZE-1:0] out;
  reg finish;
  integer idx;
  reg[`WORD_SIZE-1:0] inst;
  
  instcache ins(.clk(clk), .in(pc), .out(out));
  
  initial begin
    finish = 1;
    idx = 992;
    $display("idx %b", idx);
  end
  
  always @(posedge clk)begin
    if(finish)begin
      finish = 0;
      begin:loop
        while(1)begin
          inst = out >> idx;
          idx = idx - `WORD_SIZE;
          $display("%b %b", idx, inst);
          
          if(idx<0)disable loop;
        end
      end
    end
  end
  
endmodule
