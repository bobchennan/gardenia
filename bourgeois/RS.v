`include "define.v"
`include "ALU.v"
`include "datacache.v"
`include "RRS.v"

module RS(clk, unit, reg1, reg2, reg3, hasimm, imm, enable, out);
  input clk;
  input[1:0] unit; // 00 - lw, 01 - sw, 10 - add, 11 - mul
  input[`REG_SIZE-1:0] reg1, reg2, reg3;
  input hasimm;
  input signed[`WORD_SIZE-1:0] imm;
  input enable;
  output reg out;
  
  //unit code
  //lw : 10000000 - 11011111
  //sw : 00000000 - 10011111
  //add: 10100000 - 10111111
  //mul: 11000000 - 11011111
  reg[`GENERAL_RS_SIZE-1:0] add[0:32-1], mul[0:32-1], lw[0:96-1];
  reg[`SW_RS_SIZE-1:0] sw[0:32-1];
  
  genvar geni;
  //ALU for add
  generate for (geni = 0; geni < 32; geni = geni + 1) begin:czpadd
    wire[`GENERAL_RS_SIZE-1:0] tmp;
   	wire signed[`WORD_SIZE-1:0] addout;
	  assign tmp = add[geni];
    ADD addd(addout, $signed(tmp[81:50]), $signed(tmp[49:18]));
  end
  endgenerate
  //ALU for mul
  generate for (geni = 0; geni < 32; geni = geni + 1) begin:czpmul
    wire[`GENERAL_RS_SIZE-1:0] tmp;
	  wire signed[`WORD_SIZE-1:0] mulout;
	  assign tmp = mul[geni];
    MUL mull(mulout, $signed(tmp[81:50]), $signed(tmp[49:18]));
  end
  endgenerate
  
  reg[`WORD_SIZE-1:0] cachein;
  reg readable, writable;
  reg[`WORD_SIZE-1:0] write;
  reg[`WORD_SIZE-1:0] cacheout;
  datacache data(clk, cachein, readable, writable, write, cacheout);
  //ALU for lw
  generate for (geni = 0; geni < 32; geni = geni + 1) begin:czplw
    wire[`GENERAL_RS_SIZE-1:0] tmp;
	  reg signed[`WORD_SIZE-1:0] lwout;
    assign tmp = lw[geni];
	  reg[`WORD_SIZE-1:0] addres; // add result
	  ADD addd(addres, $signed(tmp[81:50]), $signed(tmp[49:18]));
	  always begin // need condition
	    if (tmp[1:1] == 1'b1 && tmp[0:0] == 1'b1) begin
	      cachein = addres;
	      readable = 1;
	      lwout = cacheout;
	      readable = 0;
	    end
	  end
  end
  endgenerate
  
  //ALU for sw
  generate for (geni = 0; geni < 32; geni = geni + 1) begin:czpsw
    wire[`GENERAL_RS_SIZE-1:0] tmp;
    assign tmp = lw[geni];
	  reg[`WORD_SIZE-1:0] addres;
	  ADD addd(addres, $signed(tmp[81:50]), $signed(tmp[49:18]));
	  always begin // need condition
	    if (tmp[2:2] == 1'b1 && tmp[1:1] == 1'b1 && tmp[0:0] == 1'b1) begin
	      write = tmp[113:82];
	      cachein = addres;
	      writable = 1;
	      writable = 0;
	    end
	  end
  end
  endgenerate
  
  //Register Result Status
  reg[5:0] rrsr; // 64 registers
  reg rrswritable; // write(1) or read(0)
  reg[`UNIT_SIZE-1:0] rrswrite;
  reg[`UNIT_SIZE-1:0] rrsout; // which unit is using this register
  RRS rrs(clk, rrsr, rrswritable, rrswrite, rrsout);
  initial begin
    rrswritable = 0;
  end
  
  reg[`UNIT_SIZE-1:0] i;
  always @(posedge clk) begin
    if (enable == 1) begin
	  case (unit) 
	    2'b00: begin // lw
		  for (i = 0; i < 96; i = i + 1) 
		    if (lw[i] >> (`GENERAL_RS_SIZE - 1) == 0) 
			  break;
		  if (i >= 96) 
		    out = 0; // full
		  else if (hasimm == 0) 
		    lw[i] = ((2'b10 << 32 << 32 << 8) + reg2 << 8) + reg3 << 2;
		  else
		    lw[i] = (((2'b10 << 32 << 32) + $unsigned(imm) << 8) + reg2 << 8 << 2) + 1'b1;
		  rrsr = reg1;
		  rrswrite = i + 8'b10000000;
		  rrswritable = 1;
		  rrswritable = 0;
		  out = 1;
		end
		2'b01: begin // sw
		  for (i = 0; i < 32; i = i + 1) 
		    if (sw[i] >> (`SW_RS_SIZE - 1) == 0) 
			  break;
		  if (i >= 32) 
		    out = 0; // full
		  else if (hasimm == 0) 
		    sw[i] = (((2'b10 << 32 << 32 << 32 << 8) + reg1 << 8) + reg2 << 8) + reg3 << 3;
		  else
		    sw[i] = ((((2'b10 << 32 << 32 << 32) + $unsigned(imm) << 8) + reg1 << 8) + reg2 << 8 << 3) + 1'b1;
		  out = 1;
		end
		2'b10: begin // add
		  for (i = 0; i < 32; i = i + 1) 
		    if (add[i] >> (`GENERAL_RS_SIZE - 1) == 0) 
			  break;
		  if (i >= 32) 
		    out = 0; // full
		  else if (hasimm == 0) 
		    add[i] = ((2'b10 << 32 << 32 << 8) + reg2 << 8) + reg3 << 2;
		  else
		    add[i] = (((2'b10 << 32 << 32) + $unsigned(imm) << 8) + reg2 << 8 << 2) + 1'b1;
		  rrsr = reg1;
		  rrswrite = i + 8'b10100000;
		  rrswritable = 1;
		  rrswritable = 0;
		  out = 1;
		end
		2'b11: begin // mul
		  for (i = 0; i < 32; i = i + 1) 
		    if (mul[i] >> (`GENERAL_RS_SIZE - 1) == 0) 
			  break;
		  if (i >= 32) 
		    out = 0; // full
		  else if (hasimm == 0) 
		    mul[i] = ((2'b10 << 32 << 32 << 8) + reg2 << 8) + reg3 << 2;
		  else
		    mul[i] = (((2'b10 << 32 << 32) + $unsigned(imm) << 8) + reg2 << 8 << 2) + 1'b1;
		  rrsr = reg1;
		  rrswrite = i + 8'b11000000;
		  rrswritable = 1;
		  rrswritable = 0;
		  out = 1;
		end
	  endcase
	end
  end
endmodule