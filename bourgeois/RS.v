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
  //sw : 00000000 - 00011111
  //add: 00100000 - 00111111
  //mul: 01000000 - 01011111
  reg[`GENERAL_RS_SIZE-1:0] add[0:32-1], mul[0:32-1], lw[0:96-1];
  reg[`SW_RS_SIZE-1:0] sw[0:32-1];
  reg[`UNIT_SIZE + `WORD_SIZE - 1:0] cdb;
  
  genvar geni;
  //ALU for add
  generate for (geni = 0; geni < 32; geni = geni + 1) begin:czpadd
    wire[`GENERAL_RS_SIZE-1:0] tmp;
    wire signed[`WORD_SIZE-1:0] addout;
    reg[`GENERAL_RS_SIZE-1:0] tmp2;
    assign tmp = add[geni];
    ADD addd(addout, $signed(tmp[81:50]), $signed(tmp[49:18]));
    always begin
      if (tmp[1:1] == 1 && tmp[0:0] == 1) begin
        cdb = ((8'b00100000 + geni) << `WORD_SIZE) + $unsigned(addout);
        add[geni] = 0;
      end
      if (cdb >> `WORD_SIZE == (tmp >> 10) & 8'b11111111 && (tmp >> 1) & 1'b1 == 0) begin
        tmp2 = add[geni] & ((1 << 50) - 1);
        add[geni] = (((add[geni] >> 82 << 32) + (cdb & `MAX_UNSIGN_INT) << 50) + tmp2) | 2'b10;
      end
      if (cdb >> `WORD_SIZE == (tmp >> 2) & 8'b11111111 && tmp & 1'b1 == 0) begin
        tmp2 = add[geni] & ((1 << 18) - 1);
        add[geni] = (((add[geni] >> 50 << 32) + (cdb & `MAX_UNSIGN_INT) << 18) + tmp2) | 2'b01;
      end
    end
  end
  endgenerate
  
  //ALU for mul
  generate for (geni = 0; geni < 32; geni = geni + 1) begin:czpmul
    wire[`GENERAL_RS_SIZE-1:0] tmp;
    wire signed[`WORD_SIZE-1:0] mulout;
    reg[`GENERAL_RS_SIZE-1:0] tmp2;
    assign tmp = mul[geni];
    MUL mull(mulout, $signed(tmp[81:50]), $signed(tmp[49:18]));
    always begin
      if (tmp[1:1] == 1 && tmp[0:0] == 1) begin
        cdb = ((8'b01000000 + geni) << `WORD_SIZE) + $unsigned(mulout);
        mul[geni] = 0;
      end
      if (cdb >> `WORD_SIZE == (tmp >> 10) & 8'b11111111 && (tmp >> 1) & 1'b1 == 0) begin
        tmp2 = mul[geni] & ((1 << 50) - 1);
        mul[geni] = (((mul[geni] >> 82 << 32) + (cdb & `MAX_UNSIGN_INT) << 50) + tmp2) | 2'b10;
      end
      if (cdb >> `WORD_SIZE == (tmp >> 2) & 8'b11111111 && tmp & 1'b1 == 0) begin
        tmp2 = mul[geni] & ((1 << 18) - 1);
        mul[geni] = (((mul[geni] >> 50 << 32) + (cdb & `MAX_UNSIGN_INT) << 18) + tmp2) | 2'b01;
      end
    end
  end
  endgenerate
  
  reg[`WORD_SIZE-1:0] cachein;
  reg readable, writable;
  reg[`WORD_SIZE-1:0] write;
  reg[`WORD_SIZE-1:0] cacheout;
  reg over;
  datacache data(clk, cachein, readable, writable, write, cacheout, over);
  //ALU for lw
  generate for (geni = 0; geni < 32; geni = geni + 1) begin:czplw
    wire[`GENERAL_RS_SIZE-1:0] tmp;
    reg signed[`WORD_SIZE-1:0] lwout;
    reg[`GENERAL_RS_SIZE-1:0] tmp2;
    assign tmp = lw[geni];
    reg[`WORD_SIZE-1:0] addres; // add result
    ADD addd(addres, $signed(tmp[81:50]), $signed(tmp[49:18]));
    always begin // need condition
      if (tmp[1:1] == 1'b1 && tmp[0:0] == 1'b1) begin
        cachein = addres;
        readable = 1;
        lwout = cacheout;
        readable = 0;
		lw[geni] = lw[geni] | (1 << (`GENERAL_RS_SIZE - 2));
      end
    end
    always begin
      if (tmp[`GENERAL_RS_SIZE - 2:`GENERAL_RS_SIZE - 2] == 1) begin
        cdb = ((8'b10000000 + geni) << `WORD_SIZE) + $unsigned(lwout);
        lw[geni] = 0;
      end
      if (cdb >> `WORD_SIZE == (tmp >> 10) & 8'b11111111 && (tmp >> 1) & 1'b1 == 0) begin
        tmp2 = lw[geni] & ((1 << 50) - 1);
        lw[geni] = (((lw[geni] >> 82 << 32) + (cdb & `MAX_UNSIGN_INT) << 50) + tmp2) | 2'b10;
      end
      if (cdb >> `WORD_SIZE == (tmp >> 2) & 8'b11111111 && tmp & 1'b1 == 0) begin
        tmp2 = lw[geni] & ((1 << 18) - 1);
        lw[geni] = (((lw[geni] >> 50 << 32) + (cdb & `MAX_UNSIGN_INT) << 18) + tmp2) | 2'b01;
      end
    end
  end
  endgenerate
  
  //ALU for sw
  generate for (geni = 0; geni < 32; geni = geni + 1) begin:czpsw
    wire[`GENERAL_RS_SIZE-1:0] tmp;
    reg[`GENERAL_RS_SIZE-1:0] tmp2;
    assign tmp = lw[geni];
    reg[`WORD_SIZE-1:0] addres;
    ADD addd(addres, $signed(tmp[81:50]), $signed(tmp[49:18]));
    always begin // need condition
      if (tmp[2:2] == 1'b1 && tmp[1:1] == 1'b1 && tmp[0:0] == 1'b1) begin
        write = tmp[113:82];
        cachein = addres;
        writable = 1;
        writable = 0;
		sw[geni] = 0;
      end
    end
    always begin
      if (cdb >> `WORD_SIZE == (tmp >> 19) & 8'b11111111 && (tmp >> 2) & 1'b1 == 0) begin
        tmp2 = sw[geni] & ((1 << 91) - 1);
        sw[geni] = (((sw[geni] >> 123 << 32) + (cdb & `MAX_UNSIGN_INT) << 91) + tmp2) | 3'b100;
      end
	  if (cdb >> `WORD_SIZE == (tmp >> 11) & 8'b11111111 && (tmp >> 1) & 1'b1 == 0) begin
        tmp2 = sw[geni] & ((1 << 59) - 1);
        sw[geni] = (((sw[geni] >> 91 << 32) + (cdb & `MAX_UNSIGN_INT) << 59) + tmp2) | 3'b010;
      end
      if (cdb >> `WORD_SIZE == (tmp >> 3) & 8'b11111111 && tmp & 1'b1 == 0) begin
        tmp2 = sw[geni] & ((1 << 27) - 1);
        sw[geni] = (((sw[geni] >> 59 << 32) + (cdb & `MAX_UNSIGN_INT) << 27) + tmp2) | 3'b001;
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