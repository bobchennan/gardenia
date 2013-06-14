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
  wire miss;
  
  instcache ins(.clk(clk), .in(newpc), .out(out), .miss(miss));
  
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
  RS rs(.clk(clk), .unit(unit), .reg1(reg1), .reg2(reg2), .reg3(reg3), .hasimm(hasimm), .imm(imm), .enable(enable), .out(out2), .regread(regread), .regin(regin), .regout(regout), .regoutrf(regoutrf));
  
  reg signed[`WORD_SIZE-1:0] va, vb;
  
  initial begin
    finish = 1;
    idx = 992;
    newpc = pc;
    enable = 0;
    //$display("idx %b", idx);
  end
  
  always @(posedge clk)begin
    if(miss)
      #`CACHE_MISS_TIME finish = finish;
    if(finish)begin
      finish = 0;
      begin:loop
        while(1)begin
          inst = out >> idx;
          $display("%b", inst);
          case(inst>>28)
            4'b1000: begin
              unit = 3'b010;
              reg1 = inst[27:22];
              reg2 = inst[21:16];
              if(inst[0:0]==1)begin
                //imm
                hasimm = 1;
                imm = inst[15:1];
                enable = 1;
                while(out2!=0)begin
                  //wait
                end
                idx = idx - `WORD_SIZE;
                enable = 0;
              end else begin
                //reg
                hasimm = 0;
                reg3 = inst[15:10];
                enable = 1;
                while(out2!=0)begin
                  //wait
                end
                idx = idx - `WORD_SIZE;
                enable = 0;
              end
            end
            4'b1001:begin
              unit = 3'b011;
              reg1 = inst[27:22];
              reg2 = inst[21:16];
              if(inst[0:0]==1)begin
                //imm
                hasimm = 1;
                imm = inst[15:1];
                enable = 1;
                while(out2!=0)begin
                  //wait
                end
                idx = idx - `WORD_SIZE;
                enable = 0;
              end else begin
                //reg
                hasimm = 0;
                reg3 = inst[15:10];
                enable = 1;
                while(out2!=0)begin
                  //wait
                end
                idx = idx - `WORD_SIZE;
                enable = 0;
              end
            end
            4'b1010:begin
              reg1 = inst[27:22];
              reg2 = inst[21:16];
              regin = reg1;
              regread = 1;
              va = regoutrf;
              regread = 0;
              if(regout!=8'b01111111)
                disable loop;
              regin = reg2;
              regread = 1;
              vb = regoutrf;
              regread = 0;
              if(regout!=8'b01111111)
                disable loop;
              if(va > vb)begin
                newpc = $unsigned($signed(newpc) + $signed(inst[27:0]));
                if(miss)begin
                  #`CACHE_MISS_TIME idx = 992;
                end
                else
                  idx = 992;
              end
              else
                idx = idx - `WORD_SIZE;
            end
            4'b1011:begin
              //to do
            end
            4'b1100:begin
              unit = 3'b000;
              reg1 = inst[27:22];
              reg2 = inst[21:16];
              if(inst[0:0]==1)begin
                //imm
                hasimm = 1;
                imm = inst[15:1];
                enable = 1;
                while(out2!=0)begin
                  //wait
                end
                idx = idx - `WORD_SIZE;
                enable = 0;
              end else begin
                //reg
                hasimm = 0;
                reg3 = inst[15:10];
                enable = 1;
                while(out2!=0)begin
                  //wait
                end
                idx = idx - `WORD_SIZE;
                enable = 0;
              end
            end
            4'b1101:begin
              unit = 3'b001;
              reg1 = inst[27:22];
              reg2 = inst[21:16];
              if(inst[0:0] == 1)begin
                //imm
                hasimm = 1;
                imm = inst[15:1];
                enable = 1;
                while(out2!=0)begin
                  //wait
                end
                idx = idx - `WORD_SIZE;
                enable = 0;
              end else begin
                //reg
                hasimm = 0;
                reg3 = inst[15:10];
                enable = 1;
                while(out2!=0)begin
                  //wait
                end
                idx = idx - `WORD_SIZE;
                enable = 0;
              end
            end
            4'b1110:begin
              newpc = $unsigned($signed(newpc) + $signed(inst[27:0]));
              if(miss)begin
                  #`CACHE_MISS_TIME idx = 992;
                end
                else
                  idx = 992;
            end
            4'b1111:begin
              unit = 3'b100;
              reg1 = inst[27:22];
              if(inst[0:0] == 1)begin
                //imm
                hasimm = 1;
                imm = inst[21:0];
                enable = 1;
                while(out2!=0)begin
                  //wait
                end
                idx = idx - `WORD_SIZE;
                enable = 0;
              end else begin
                hasimm = 0;
                reg2 = inst[21:16];
                enable = 1;
                while(out2!=0)begin
                  //wait
                end
                idx = idx - `WORD_SIZE;
                enable = 0;
              end
            end
            4'b0000:begin
              //$display("%g idx %g empty", newpc, idx);
              idx = idx - `WORD_SIZE;
              if(idx<0)begin
                newpc=newpc+128;
                if(miss)begin
                  #`CACHE_MISS_TIME idx = 992;
                end
                else
                  idx = 992;
              end
              finish = 1;
              disable loop;
            end
            4'b0001:begin
              unit = 3'b101;
              enable = 1;
              finish = 0;
              $display("finish");
              disable loop;
            end
            4'bxxxx:begin
              finish = 0;
              disable loop;
            end
            default:begin
              idx = idx - `WORD_SIZE;
            end
          endcase
          if(idx<0)begin
            newpc = newpc + 128;
            if(miss)begin
              #`CACHE_MISS_TIME idx = 992;
            end
            else
              idx = 992;
          end
        end
      end
    end
  end
  
endmodule
