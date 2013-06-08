`include "define.v"
`include "instcache.v"

module fetch(clk, pc, newpc);
  input clk;
  input[`BYTE_SIZE-1:0] pc;
  output[`BYTE_SIZE-1:0] newpc;
  reg[`WORD_SIZE-1:0] out[`MULTIPLE_ISSUE-1:0];
  
  generate
    genvar i;
    begin:loop
      for(i=0;i<`MULTIPLE_ISSUE;i=i+1)
      begin
        instcache inst(.clk(clk), .in(pc+`WORD_SIZE*i), .out(out[i]));
        if(out[i]==32'b00000000000000000000000000000000)
          disable loop;
        else begin
          assign cnt=cnt+1;
        end
      end
    end
    
  endgenerate
  
  always @(posedge clk)begin
    
  end
  
endmodule
