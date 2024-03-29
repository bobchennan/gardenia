`include "define.v"
`include "instcache.v"

module fetch(clk);
  input clk;
  wire[`BLOCK_SIZE-1:0] out;
  reg unfinish;
  reg[`WORD_SIZE-1:0] inst;
  wire hit;
  
  integer idx;
  reg[`WORD_SIZE-1:0] newpc;
  
  instcache ins(.clk(clk), .in(newpc), .out(out), .hit(hit));
  
  reg[2:0] unit; // 000 - lw, 001 - sw, 010 - add, 011 - mul, 100 - mv
  reg[`REG_SIZE-1:0] reg1, reg2, reg3;
  reg hasimm;
  reg signed[`WORD_SIZE-1:0] imm;
  reg enable;
  reg signed[`WORD_SIZE-1:0] cnt;
  wire out2;
  reg regread;
  reg[`REG_SIZE-1:0] regin;
  wire[`UNIT_SIZE-1:0] regout;
  wire signed[`WORD_SIZE-1:0] regoutrf;
  RS rs(.clk(clk), .unit(unit), .reg1(reg1), .reg2(reg2), .reg3(reg3), .hasimm(hasimm), .imm(imm), .enable(enable), .out(out2), .regread(regread), .regin(regin), .regout(regout), .regoutrf(regoutrf));
  
  reg signed[`WORD_SIZE-1:0] va, vb;
  
  initial begin
    unfinish = 1;
    idx = 992;
    newpc = 0;
    enable = 0;
    cnt = 0;
    //$display("idx %b cache %b newpc %b", idx, hit, newpc);
  end
  
  always @(posedge clk)begin
    cnt=cnt+1;
    if(hit === 1 && unfinish)begin
      unfinish = 0;
      begin:loop
        while(1)begin
          inst = out >> idx;
          $display("%g,%b", newpc+(992-idx)/8,inst);
          case(inst>>28)
            4'b1000: begin
              unit = 3'b010;
              reg1 = inst[27:22];
              reg2 = inst[21:16];
              if(inst[0:0]==1)begin
                //imm
                hasimm = 1;
                imm = $signed(inst[15:1]);
                enable = 1;
                #0 if(out2==0)begin
                    enable = 0;
                    #0 unfinish = 1;
                    disable loop;
                end
                enable = 0;
                #0 idx = idx - `WORD_SIZE;
              end else begin
                //reg
                hasimm = 0;
                reg3 = inst[15:10];
                enable = 1;
                #0 if(out2==0)begin
                    enable = 0;
                    #0 unfinish = 1;
                    disable loop;
                end
                enable = 0;
                #0 idx = idx - `WORD_SIZE;
              end
            end
            4'b1001:begin
              unit = 3'b011;
              reg1 = inst[27:22];
              reg2 = inst[21:16];
              //$display("begin mul %b", inst);
              if(inst[0:0]==1)begin
                //imm
                hasimm = 1;
                imm = $signed(inst[15:1]);
                enable = 1;
                #0 if(out2==0)begin
                    //$display("mul full");
                    enable = 0;
                    #0 unfinish = 1;
                    disable loop;
                end
                enable = 0;
                #0 idx = idx - `WORD_SIZE;
              end else begin
                //reg
                hasimm = 0;
                reg3 = inst[15:10];
                enable = 1;
                #0 if(out2==0)begin
                    enable = 0;
                    #0 unfinish = 1;
                    disable loop;
                end
                enable = 0;
                #0 idx = idx - `WORD_SIZE;
              end
              //$display("end mul");
            end
            4'b1010:begin
              reg1 = inst[27:22];
              reg2 = inst[21:16];
              regin = reg1;
              regread = 1;
              //enable = 1;
              #0 if(regout!==8'b01111111)begin
                //$display("bgt not ready, %b", regout);
                        regread = 0;
                    #0 unfinish = 1;
                        disable loop;
                    end
              va = regoutrf;
              //$display("reg1: %g, va : %g", reg1, va);
              regread = 0;
              //enable = 0;
              #0 regin = reg2;
              regread = 1;
              //enable = 1;
              #0 if(regout!==8'b01111111)begin
                //$display("bgt not ready, %b", regout);
                        regread = 0;
                    #0 unfinish = 1;
                        disable loop;
                    end
              vb = regoutrf;
              //$display("reg2: %g, vb : %g", reg2, vb);
              regread = 0;
              //enable = 0;
              //$display("%g:%g %g:%g", reg1, va, reg2, vb);
              #0 if(va > vb)begin
                //$display("bgt pc %g idx %g offset %g", $signed(newpc), $signed((992-idx)/8), $signed(inst[15:0]));
                newpc = $unsigned($signed(newpc) + $signed((992-idx)/8) + $signed(inst[15:0]));
                idx = 992;
                unfinish = 1;
                disable loop;
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
                imm = $signed(inst[15:1]);
                enable = 1;
                #0 if(out2==0)begin
                    //$display("lw full");
                    enable = 0;
                    #0 unfinish = 1;
                    disable loop;
                end
                enable = 0;
                #0 idx = idx - `WORD_SIZE;
              end else begin
                //reg
                hasimm = 0;
                reg3 = inst[15:10];
                enable = 1;
                #0 if(out2==0)begin
                  //$display("lw full");
                    enable = 0;
                    #0 unfinish = 1;
                    disable loop;
                end
                enable = 0;
                #0 idx = idx - `WORD_SIZE;
              end
            end
            4'b1101:begin
              unit = 3'b001;
              reg1 = inst[27:22];
              reg2 = inst[21:16];
              if(inst[0:0] == 1)begin
                //imm
                hasimm = 1;
                imm = $signed(inst[15:1]);
                enable = 1;
                #0 if(out2==0)begin
                  //$display("sw full");
                    enable = 0;
                    #0 unfinish = 1;
                    disable loop;
                end
                enable = 0;
                #0 idx = idx - `WORD_SIZE;
              end else begin
                //reg
                hasimm = 0;
                reg3 = inst[15:10];
                enable = 1;
                #0 if(out2==0)begin
                  $display("sw full");
                    enable = 0;
                    #0 unfinish = 1;
                    disable loop;
                end
                enable = 0;
                #0 idx = idx - `WORD_SIZE;
              end
            end
            4'b1110:begin
              //$display("J pc %g idx %g offset %g", $signed(newpc) , $signed((992-idx)/8) , $signed(inst[27:0]));
              newpc = $unsigned($signed(newpc) + $signed((992-idx)/8) + $signed(inst[27:0]));
              idx = 992;
              unfinish = 1;
              disable loop;
            end
            4'b1111:begin
              unit = 3'b100;
              reg1 = inst[27:22];
              if(inst[0:0] == 1)begin
                //imm
                hasimm = 1;
                imm = $signed(inst[21:1]);
                //$display("cnx %g:%g", reg1, imm);
                enable = 1;
                #0 if(out2==0)begin
                    enable = 0;
                    #0 unfinish = 1;
                    disable loop;
                end
                enable = 0;
                #0 idx = idx - `WORD_SIZE;
              end else begin
                hasimm = 0;
                reg2 = inst[21:16];
                enable = 1;
                #0 if(out2==0)begin
                    enable = 0;
                    #0 unfinish = 1;
                    disable loop;
                end
                enable = 0;
                #0 idx = idx - `WORD_SIZE;
              end
            end
            4'b0000:begin
              //$display("%g idx %g empty", newpc, idx);
              idx = idx - `WORD_SIZE;
              if(idx<0)begin
                newpc=newpc+128;
                idx = 992;
                unfinish = 1;
                disable loop;
              end
            end
            4'b0001:begin
              unit = 3'b101;
              #0 enable = 1;
              #0 unfinish = 0;
              $display("finish fetch in cycle %g", cnt);
              disable loop;
            end
            default:begin
              idx = idx - `WORD_SIZE;
            end
          endcase
          if(idx<0)begin
            newpc = newpc + 128;
            idx = 992;
            unfinish = 1;
            disable loop;
          end
        end
      end
    end
  end
  
endmodule
