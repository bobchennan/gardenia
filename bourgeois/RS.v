`include "define.v"
`include "ALU.v"
`include "datacache.v"

module RS(clk, unit, reg1, reg2, reg3, hasimm, imm, enable, out, regread, regin, regout, regoutrf);
  input clk;
  input[2:0] unit; // 000 - lw, 001 - sw, 010 - add, 011 - mul, 100 - mv, 101 - halt
  input[`REG_SIZE-1:0] reg1, reg2, reg3;
  input hasimm;
  input signed[`WORD_SIZE-1:0] imm;
  input enable;
  output reg out;
  input regread;
  input[`REG_SIZE-1:0] regin;
  output [`UNIT_SIZE-1:0] regout;
  output signed[`WORD_SIZE-1:0] regoutrf;
  
  integer k;
  

   
  //unit code
  //lw : 10000000 - 11011111
  //sw : 00000000 - 00011111
  //add: 00100000 - 00111111
  //mul: 01000000 - 01011111
  //mv(register has its value) : 01111111
  reg[`GENERAL_RS_SIZE-1:0] add[0:32-1], mul[0:32-1], lw[0:96-1];
  reg[`SW_RS_SIZE-1:0] sw[0:32-1];
  reg[`UNIT_SIZE + `WORD_SIZE:0 - 1] cdb;
  reg cdbchange;
  initial begin
    cdbchange = 0;
    for (k = 0; k < 32; k = k + 1)
      add[k] = 0;
    for (k = 0; k < 32; k = k + 1)
      mul[k] = 0;
    for (k = 0; k < 96; k = k + 1)
      lw[k] = 0;
    for (k = 0; k < 32; k = k + 1)
      sw[k] = 0;
  end
  
  genvar geni;
  //ALU for add
  generate for (geni = 0; geni < 32; geni = geni + 1) begin:czpadd
    wire[`GENERAL_RS_SIZE-1:0] tmp;
    wire signed[`WORD_SIZE-1:0] addout;
    reg[`GENERAL_RS_SIZE-1:0] tmp2;
    assign tmp = add[geni];
    ADD addd(addout, $signed(tmp[81:50]), $signed(tmp[49:18]));
    always @(posedge clk) begin
      if (tmp[1:1] == 1 && tmp[0:0] == 1) begin
        cdb = ((8'b00100000 + geni) << `WORD_SIZE) + $unsigned(addout);
        add[geni] = 0;
        cdbchange = 1;
        $display("cdb change");
      end
    end
    always @(cdbchange) begin
      if (cdbchange) begin
        if (cdb >> `WORD_SIZE == (tmp >> 10) & 8'b11111111 && (tmp >> 1) & 1'b1 == 0) begin
          tmp2 = add[geni] & ((1 << 50) - 1);
          add[geni] = (((add[geni] >> 82 << 32) + (cdb & `MAX_UNSIGN_INT) << 50) + tmp2) | 2'b10;
        end
        if (cdb >> `WORD_SIZE == (tmp >> 2) & 8'b11111111 && tmp & 1'b1 == 0) begin
          tmp2 = add[geni] & ((1 << 18) - 1);
          add[geni] = (((add[geni] >> 50 << 32) + (cdb & `MAX_UNSIGN_INT) << 18) + tmp2) | 2'b01;
        end
        cdbchange = 0;
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
    always @(posedge clk) begin
      if (tmp[1:1] == 1 && tmp[0:0] == 1) begin
        cdb = ((8'b01000000 + geni) << `WORD_SIZE) + $unsigned(mulout);
        mul[geni] = 0;
        cdbchange = 1;
      end
    end
    always @(cdbchange) begin
      if (cdbchange) begin
        if (cdb >> `WORD_SIZE == (tmp >> 10) & 8'b11111111 && (tmp >> 1) & 1'b1 == 0) begin
          tmp2 = mul[geni] & ((1 << 50) - 1);
          mul[geni] = (((mul[geni] >> 82 << 32) + (cdb & `MAX_UNSIGN_INT) << 50) + tmp2) | 2'b10;
        end
        if (cdb >> `WORD_SIZE == (tmp >> 2) & 8'b11111111 && tmp & 1'b1 == 0) begin
          tmp2 = mul[geni] & ((1 << 18) - 1);
          mul[geni] = (((mul[geni] >> 50 << 32) + (cdb & `MAX_UNSIGN_INT) << 18) + tmp2) | 2'b01;
        end
        cdbchange = 0;
      end
    end
  end
  endgenerate
  
  reg[`WORD_SIZE-1:0] cachein;
  reg readable, writable;
  reg[`WORD_SIZE-1:0] write;
  wire[`WORD_SIZE-1:0] cacheout;
  wire miss;
  reg flush;
  datacache data(clk, cachein, readable, writable, write, cacheout, miss, flush);
  initial begin
    flush = 0;
  end
  //ALU for lw
  generate for (geni = 0; geni < 32; geni = geni + 1) begin:czplw
    wire[`GENERAL_RS_SIZE-1:0] tmp;
    reg signed[`WORD_SIZE-1:0] lwout;
    reg[`GENERAL_RS_SIZE-1:0] tmp2;
    assign tmp = lw[geni];
    wire[`WORD_SIZE-1:0] addres; // add result
    ADD addd(addres, $signed(tmp[81:50]), $signed(tmp[49:18]));
    always @(posedge clk) begin // need condition
      if (tmp[1:1] == 1'b1 && tmp[0:0] == 1'b1) begin
        cachein = addres;
        readable = 1;
        if (miss == 1) begin
          #`CACHE_MISS_TIME lwout = cacheout;
        end else
          lwout = cacheout;
        readable = 0;
        cdb = ((8'b10000000 + geni) << `WORD_SIZE) + $unsigned(lwout);
        lw[geni] = 0;
        cdbchange = 1;
      end
    end
    always @(cdbchange) begin
      if (cdbchange) begin
        if (cdb >> `WORD_SIZE == (tmp >> 10) & 8'b11111111 && (tmp >> 1) & 1'b1 == 0) begin
          tmp2 = lw[geni] & ((1 << 50) - 1);
          lw[geni] = (((lw[geni] >> 82 << 32) + (cdb & `MAX_UNSIGN_INT) << 50) + tmp2) | 2'b10;
        end
        if (cdb >> `WORD_SIZE == (tmp >> 2) & 8'b11111111 && tmp & 1'b1 == 0) begin
          tmp2 = lw[geni] & ((1 << 18) - 1);
          lw[geni] = (((lw[geni] >> 50 << 32) + (cdb & `MAX_UNSIGN_INT) << 18) + tmp2) | 2'b01;
        end
        cdbchange = 0;
      end
    end
  end
  endgenerate
  
  //ALU for sw
  generate for (geni = 0; geni < 32; geni = geni + 1) begin:czpsw
    wire[`SW_RS_SIZE-1:0] tmp;
    reg[`SW_RS_SIZE-1:0] tmp2;
    assign tmp = lw[geni];
    wire[`WORD_SIZE-1:0] addres;
    ADD addd(addres, $signed(tmp[81:50]), $signed(tmp[49:18]));
    always @(posedge clk) begin // need condition
      if (tmp[2:2] == 1'b1 && tmp[1:1] == 1'b1 && tmp[0:0] == 1'b1) begin
        write = tmp[113:82];
        cachein = addres;
        writable = 1;
        if (miss == 1) begin
          #`CACHE_MISS_TIME writable = 0;
        end else
          writable = 0;
        sw[geni] = 0;
      end
    end
    always @(cdbchange) begin
      if (cdbchange) begin
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
        cdbchange = 0;
      end
    end
  end
  endgenerate
  
  //Register Result Status
  reg[`UNIT_SIZE-1:0] rrs[63:0];
  reg[`WORD_SIZE-1:0] rf[63:0];
  assign regout = rrs[regin];
  assign regoutrf = rf[regin];
  initial begin
    for (k = 0; k < 64; k = k + 1) begin
      rrs[k] = 8'b01111111;
      rf[k] = 0;
    end
  end
  reg[`UNIT_SIZE-1:0] rrswrite;
  always @(cdbchange) begin
    if (cdbchange) begin
      rrswrite = cdb >> `WORD_SIZE;
      for (k = 0; k < 64; k = k + 1) 
        if (rrs[k] == rrswrite) begin
          rrs[k] = 8'b01111111;
          rf[k] = cdb & ((1 << `WORD_SIZE) - 1);
        end
    end
  end
  
  reg halt, over;
  reg[`UNIT_SIZE-1:0] j;
  initial begin
    halt = 0;
    over = 0;
  end
  always @(halt) begin
    while (halt == 1) begin
      over = 1;
      for (j = 0; j < 96 && over; j = j + 1)
        if (lw[j] >> (`GENERAL_RS_SIZE - 1) == 0) begin
          over = 0;
          //break;
        end
      for (j = 0; j < 32 && over; j = j + 1)
        if (sw[j] >> (`SW_RS_SIZE - 1) == 0) begin
          over = 0;
          //break;
        end
      for (j = 0; j < 32 && over; j = j + 1)
        if (add[j] >> (`GENERAL_RS_SIZE - 1) == 0) begin
          over = 0;
          //break;
        end
      for (j = 0; j < 32 && over; j = j + 1)
        if (mul[j] >> (`GENERAL_RS_SIZE - 1) == 0) begin
          over = 0;
          //break;
        end
      if (over == 1) begin
        flush = 1;
        halt = 0;
      end else begin
        #1 over = 0;
      end
    end
  end
  
  reg[`UNIT_SIZE-1:0] i;
  reg[`GENERAL_RS_SIZE-1:0] tmp2;
  always @(enable) begin
    if (enable == 1) begin
      $display("%b", unit);
    case (unit) 
      3'b000: begin // lw
      begin:loop1
      for (i = 0; i < 96; i = i + 1) 
        if (lw[i] >> (`GENERAL_RS_SIZE - 1) == 0) 
          disable loop1;
      end
      if (i >= 96) 
        out = 0; // full
      else begin 
        $display("put lw %b", i);
        if (hasimm == 0) begin
          lw[i] = ((2'b10 << 32 << 32 << 8) + reg2 << 8) + reg3 << 2;
          if (rrs[reg2] == 8'b01111111) begin
            tmp2 = lw[i] & ((1 << 50) - 1);
            lw[i] = (((lw[i] >> 82 << 32) + rf[reg2] << 50) + tmp2) | 2'b10;
          end
          if (rrs[reg3] == 8'b01111111) begin
            tmp2 = lw[i] & ((1 << 18) - 1);
            lw[i] = (((lw[i] >> 50 << 32) + rf[reg3] << 18) + tmp2) | 2'b01;
          end
        end else begin
          lw[i] = (((2'b10 << 32 << 32) + $unsigned(imm) << 8) + reg2 << 8 << 2) + 1'b1;
          if (rrs[reg2] == 8'b01111111) begin
            tmp2 = lw[i] & ((1 << 50) - 1);
            lw[i] = (((lw[i] >> 82 << 32) + rf[reg2] << 50) + tmp2) | 2'b10;
          end
        end
        rrs[reg1] = i + 8'b10000000;
        out = 1;
      end
    end
    3'b001: begin // sw
      begin:loop2
      for (i = 0; i < 32; i = i + 1) 
        if (sw[i] >> (`SW_RS_SIZE - 1) == 0) 
          disable loop2;
      end
      if (i >= 32) 
        out = 0; // full
      else begin
                $display("put sw %b", i);
        if (hasimm == 0) begin
          sw[i] = (((2'b10 << 32 << 32 << 32 << 8) + reg1 << 8) + reg2 << 8) + reg3 << 3;
          if (rrs[reg1] == 8'b01111111) begin
            tmp2 = sw[i] & ((1 << 91) - 1);
            sw[i] = (((sw[i] >> 123 << 32) + rf[reg1] << 91) + tmp2) | 3'b100;
          end
          if (rrs[reg2] == 8'b01111111) begin
            tmp2 = sw[i] & ((1 << 59) - 1);
            sw[i] = (((sw[i] >> 91 << 32) + rf[reg2] << 59) + tmp2) | 3'b010;
          end
          if (rrs[reg3] == 8'b01111111) begin
            tmp2 = sw[i] & ((1 << 27) - 1);
            sw[i] = (((sw[i] >> 59 << 32) + rf[reg3] << 27) + tmp2) | 2'b01;
          end
        end else begin
          sw[i] = ((((2'b10 << 32 << 32 << 32) + $unsigned(imm) << 8) + reg1 << 8) + reg2 << 8 << 3) + 1'b1;
          if (rrs[reg1] == 8'b01111111) begin
            tmp2 = sw[i] & ((1 << 91) - 1);
            sw[i] = (((sw[i] >> 123 << 32) + rf[reg1] << 91) + tmp2) | 3'b100;
          end
          if (rrs[reg2] == 8'b01111111) begin
            tmp2 = sw[i] & ((1 << 59) - 1);
            sw[i] = (((sw[i] >> 91 << 32) + rf[reg2] << 59) + tmp2) | 3'b010;
          end
        end
        out = 1;
      end
    end
    3'b010: begin // add
      begin:loop3
      for (i = 0; i < 32; i = i + 1) 
        if (add[i] >> (`GENERAL_RS_SIZE - 1) == 0) 
          disable loop3;
      end
      if (i >= 32) 
        out = 0; // full
      else begin
                $display("put add %b", i);
        if (hasimm == 0) begin
          add[i] = ((2'b10 << 32 << 32 << 8) + reg2 << 8) + reg3 << 2;
          if (rrs[reg2] == 8'b01111111) begin
            tmp2 = add[i] & ((1 << 50) - 1);
            add[i] = (((add[i] >> 82 << 32) + rf[reg2] << 50) + tmp2) | 2'b10;
          end
          if (rrs[reg3] == 8'b01111111) begin
            tmp2 = add[i] & ((1 << 18) - 1);
            add[i] = (((add[i] >> 50 << 32) + rf[reg3] << 18) + tmp2) | 2'b01;
          end
        end else begin
          add[i] = (((2'b10 << 32 << 32) + $unsigned(imm) << 8) + reg2 << 8 << 2) + 1'b1;
          if (rrs[reg2] == 8'b01111111) begin
            tmp2 = add[i] & ((1 << 50) - 1);
            add[i] = (((add[i] >> 82 << 32) + rf[reg2] << 50) + tmp2) | 2'b10;
          end
        end
        rrs[reg1] = i + 8'b10100000;
        out = 1;
      end
    end
    3'b011: begin // mul
      begin:loop4
      for (i = 0; i < 32; i = i + 1) 
        if (mul[i] >> (`GENERAL_RS_SIZE - 1) == 0) 
          disable loop4;
      end
      if (i >= 32) begin
        out = 0; // full
        $display("mul full");
      end
      else begin 
                $display("put mul %b", i);
        if (hasimm == 0) begin
          mul[i] = ((2'b10 << 32 << 32 << 8) + reg2 << 8) + reg3 << 2;
          if (rrs[reg2] == 8'b01111111) begin
            tmp2 = mul[i] & ((1 << 50) - 1);
            mul[i] = (((mul[i] >> 82 << 32) + rf[reg2] << 50) + tmp2) | 2'b10;
          end
          if (rrs[reg3] == 8'b01111111) begin
            tmp2 = mul[i] & ((1 << 18) - 1);
            mul[i] = (((mul[i] >> 50 << 32) + rf[reg3] << 18) + tmp2) | 2'b01;
          end
        end else begin
          mul[i] = (((2'b10 << 32 << 32) + $unsigned(imm) << 8) + reg2 << 8 << 2) + 1'b1;
          if (rrs[reg2] == 8'b01111111) begin
            tmp2 = mul[i] & ((1 << 50) - 1);
            mul[i] = (((mul[i] >> 82 << 32) + rf[reg2] << 50) + tmp2) | 2'b10;
          end
        end
        rrs[reg1] = i + 8'b11000000;
        out = 1;
      end
    end
    3'b100: begin // mv
      if (hasimm == 0) begin
        begin:loop5
          for (i = 0; i < 32; i = i + 1) 
            if (add[i] >> (`GENERAL_RS_SIZE - 1) == 0) 
              disable loop5;
        end
        if (i >= 32) 
          out = 0; // full
        else begin
                  $display("put mv(add) %b", i);
          add[i] = ((2'b10 << 32 << 32) + reg2 << 8 << 2) + 1'b1;
          out = 1;
        end
      end else begin
        $display("imm mv reg1: %g", reg1);
        rrs[reg1] = 8'b01111111;
        rf[reg1] = imm;
        out = 1;
      end
    end
    3'b101: begin // halt
      halt = 1;
    end
    endcase
  end
  end
endmodule