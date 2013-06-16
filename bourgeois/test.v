`include "clock.v"
`include "RS.v"

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
  
  initial begin
    unit = 5'b1000;
    enable = 0;
    $display("initial");
  end
  
  always @(posedge clkout) begin
    enable = 1;
    #0 $display("posedge %b", unit);
    enable = 0;
    unit = unit + 1;
  end
  
endmodule

