`include "define.v"

module ADD(dst, src1, src2);
  input signed[`WORD_SIZE-1:0] src1, src2;
  output signed[`WORD_SIZE-1:0] dst;
  
  assign dst = src1 + src2;
endmodule

module MUL(dst, src1, src2);
  input signed[`WORD_SIZE-1:0] src1, src2;
  output signed[`WORD_SIZE-1:0] dst;
  
  assign dst = src1 * src2;
endmodule

