`include "define.v"
`include "CDB.v"
`include "EX.v"

module RS();
  input clk, unit, dst, src1, src2, imm;
  reg[] add0table[0:`ADD_UNIT_NUM];
  reg[] add1table[0:`ADD_UNIT_NUM];
  reg[] mul0table[0:`MUL_UNIT_NUM];
  reg[] mul1table[0:`MUL_UNIT_NUM];
  reg[] lw0table[0:`LW_UNIT_NUM];
  reg[] lw1table[0:`LW_UNIT_NUM];
  reg[] sw0table[0:`SW_UNIT_NUM];
  reg[] sw1table[0:`SW_UNIT_NUM];
  reg[] mv0table[0:`MV_UNIT_NUM];
  reg[] mv1table[0:`MV_UNIT_NUM];
  always @(posedge clk) begin
    
  end
endmodule