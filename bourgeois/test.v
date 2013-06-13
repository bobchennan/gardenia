`include "clock.v"

module test();
  wire clkout;
  clock clk(.out(clkout));
  
  reg[2:0] unit; // 000 - lw, 001 - sw, 010 - add, 011 - mul, 100 - mv
  reg[`REG_SIZE-1:0] reg1, reg2, reg3;
  reg hasimm;
  reg signed[`WORD_SIZE-1:0] imm;
  reg enable;
  wire out2;
  reg regread;
  reg[`REG_SIZE-1:0] regin;
  wire[`UNIT_SIZE-1:0] regout;
  wire signed[`WORD_SIZE-1:0] regoutrf;
  RS rs(.clk(clkout), .unit(unit), .reg1(reg1), .reg2(reg2), .reg3(reg3), .hasimm(hasimm), .imm(imm), .enable(enable), .out(out2), .regread(regread), .regin(regin), .regout(regout), .regoutrf(regoutrf));
  
  reg signed[`WORD_SIZE-1:0] va, vb;
  
  initial begin
    $display("start");
    enable = 0;
  end
   
  always begin
    $display("cnx");
    $finish(2);
  end
  
endmodule

