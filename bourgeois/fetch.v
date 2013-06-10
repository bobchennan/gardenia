`include "define.v"
`include "instcache.v"

module fetch(clk, pc, newpc);
  input clk;
  input[`WORD_SIZE-1:0] pc;
  output reg[`WORD_SIZE-1:0] newpc;
  wire[`BLOCK_SIZE-1:0] out;
  reg finish;
  integer idx;
  reg[`WORD_SIZE-1:0] inst;
  
  instcache ins(.clk(clk), .in(newpc), .out(out));
  
  reg[1:0] unit; // 00 - lw, 01 - sw, 10 - add, 11 - mul
  reg[`REG_SIZE-1:0] reg1, reg2, reg3;
  reg hasimm;
  reg signed[`WORD_SIZE-1:0] imm;
  reg enable, out2;
  
  RS rs(.clk(clk), .unit(unit), .reg1(reg1), .reg2(reg2), .reg3(reg3), .hasimm(hasimm), .imm(imm), .enable(enable), .out(out2));
  
  initial begin
    finish = 1;
    idx = 992;
    newpc = pc;
    enable = 0;
    //$display("idx %b", idx);
  end
  
  always @(posedge clk)begin
    if(finish)begin
      finish = 0;
      begin:loop
        while(1)begin
          inst = out >> idx;
          case(inst>>28)
            4'b1000: begin
              unit = 2'b10;
              reg1 = inst[27:22];
              reg2 = inst[21:16];
              if(inst[0:0]==0)begin
                //reg
                hasimm = 1;
                imm = inst[15:1];
                enable = 1;
                if(out2!=0)idx = idx - `WORD_SIZE;
                enable = 0;
              end else begin
                //imm
                hasimm = 0;
                reg3 = inst[15:10];
                enable = 1;
                if(out2!=0)idx = idx - `WORD_SIZE;
                enable = 0;
              end
            end
            4'b1001:begin
              unit = 2'b11;
              reg1 = inst[27:22];
              reg2 = inst[21:16];
              if(inst[0:0]==0)begin
                //reg
                hasimm = 1;
                imm = inst[15:1];
                enable = 1;
                if(out2!=0)idx = idx - `WORD_SIZE;
                enable = 0;
              end else begin
                //imm
                hasimm = 0;
                reg3 = inst[15:10];
                enable = 1;
                if(out2!=0)idx = idx - `WORD_SIZE;
                enable = 0;
              end
            end
            4'b1100:begin
              unit = 2'b00;
              reg1 = inst[27:22];
              reg2 = inst[21:16];
              if(inst[0:0]==0)begin
                //reg
                hasimm = 1;
                imm = inst[15:1];
                enable = 1;
                if(out2!=0)idx = idx - `WORD_SIZE;
                enable = 0;
              end else begin
                //imm
                hasimm = 0;
                reg3 = inst[15:10];
                enable = 1;
                if(out2!=0)idx = idx - `WORD_SIZE;
                enable = 0;
              end
            end
            4'b1101:begin
              unit = 2'b01;
              reg1 = inst[27:22];
              reg2 = inst[21:16];
              if(inst[0:0]==0)begin
                //reg
                hasimm = 1;
                imm = inst[15:1];
                enable = 1;
                if(out2!=0)idx = idx - `WORD_SIZE;
                enable = 0;
              end else begin
                //imm
                hasimm = 0;
                reg3 = inst[15:10];
                enable = 1;
                if(out2!=0)idx = idx - `WORD_SIZE;
                enable = 0;
              end
            end
            4'b1110:begin
              newpc = inst[27:0];
              idx = 992;
            end
            4'b0000:begin
              //$display("%g idx %g empty", newpc, idx);
              finish = 1;
              if(idx<0)begin
                newpc=newpc+128;
                //$display("%g change2 %g", idx, newpc);
                idx=992;
              end
              disable loop;
            end
          endcase
          if(idx<0)begin
            newpc = newpc + 128;
            idx = 992;
          end
        end
      end
    end
  end
  
endmodule
