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
  initial begin
    for (k = 0; k < 32; k = k + 1)
      add[k] = 0;
    for (k = 0; k < 32; k = k + 1)
      mul[k] = 0;
    for (k = 0; k < 96; k = k + 1)
      lw[k] = 0;
    for (k = 0; k < 32; k = k + 1)
      sw[k] = 0;
  end
  
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
  
  genvar geni;
  //ALU for add
  generate for (geni = 0; geni < 32; geni = geni + 1) begin:czpadd
    wire[`GENERAL_RS_SIZE-1:0] tmp;
    wire signed[`WORD_SIZE-1:0] addout;
    reg[`GENERAL_RS_SIZE-1:0] tmp2;
    assign tmp = add[geni];
    ADD addd(addout, $signed(tmp[81:50]), $signed(tmp[49:18]));
    integer l;
    always @(posedge clk) begin
      if (tmp[1:1] == 1 && tmp[0:0] == 1) begin
        for (l = 0; l < 32; l = l + 1) 
          if (add[l] >> (`GENERAL_RS_SIZE - 1) == 1) begin
            if (8'b00100000 + geni == (add[l] >> 10) & 8'b11111111 && (add[l] >> 1) & 1'b1 == 0) begin
              tmp2 = add[l] & ((1 << 50) - 1);
              add[l] = (((add[l] >> 82 << 32) + $unsigned(addout) << 50) + tmp2) | 2'b10;
            end
            if (8'b00100000 + geni == (add[l] >> 2) & 8'b11111111 && add[l] & 1'b1 == 0) begin
              tmp2 = add[l] & ((1 << 18) - 1);
              add[l] = (((add[l] >> 50 << 32) + $unsigned(addout) << 18) + tmp2) | 2'b01;
            end
          end
        for (l = 0; l < 32; l = l + 1) 
          if (mul[l] >> (`GENERAL_RS_SIZE - 1) == 1) begin
            if (8'b00100000 + geni == (mul[l] >> 10) & 8'b11111111 && (mul[l] >> 1) & 1'b1 == 0) begin
              tmp2 = add[l] & ((1 << 50) - 1);
              mul[l] = (((mul[l] >> 82 << 32) + $unsigned(addout) << 50) + tmp2) | 2'b10;
            end
            if (8'b00100000 + geni == (mul[l] >> 2) & 8'b11111111 && mul[l] & 1'b1 == 0) begin
              tmp2 = mul[l] & ((1 << 18) - 1);
              mul[l] = (((mul[l] >> 50 << 32) + $unsigned(addout) << 18) + tmp2) | 2'b01;
            end
          end
        for (l = 0; l < 96; l = l + 1) 
          if (lw[l] >> (`GENERAL_RS_SIZE - 1) == 1) begin
            if (8'b00100000 + geni == (lw[l] >> 10) & 8'b11111111 && (lw[l] >> 1) & 1'b1 == 0) begin
              tmp2 = lw[l] & ((1 << 50) - 1);
              lw[l] = (((lw[l] >> 82 << 32) + $unsigned(addout) << 50) + tmp2) | 2'b10;
            end
            if (8'b00100000 + geni == (lw[l] >> 2) & 8'b11111111 && lw[l] & 1'b1 == 0) begin
              tmp2 = lw[l] & ((1 << 18) - 1);
              lw[l] = (((lw[l] >> 50 << 32) + $unsigned(addout) << 18) + tmp2) | 2'b01;
            end
          end
        for (l = 0; l < 32; l = l + 1) 
          if (sw[l] >> (`SW_RS_SIZE - 1) == 1) begin
            if (8'b00100000 + geni == (sw[l] >> 19) & 8'b11111111 && (sw[l] >> 2) & 1'b1 == 0) begin
              tmp2 = sw[l] & ((1 << 91) - 1);
              sw[l] = (((sw[l] >> 123 << 32) + $unsigned(addout) << 91) + tmp2) | 3'b100;
            end
            if (8'b00100000 + geni == (sw[l] >> 11) & 8'b11111111 && (tmp >> 1) & 1'b1 == 0) begin
              tmp2 = sw[l] & ((1 << 59) - 1);
              sw[l] = (((sw[l] >> 91 << 32) + $unsigned(addout) << 59) + tmp2) | 3'b010;
            end
            if (8'b00100000 + geni == (tmp >> 3) & 8'b11111111 && tmp & 1'b1 == 0) begin
              tmp2 = sw[l] & ((1 << 27) - 1);
              sw[l] = (((sw[l] >> 59 << 32) + $unsigned(addout) << 27) + tmp2) | 3'b001;
            end
          end
        for (l = 0; l < 64; l = l + 1) 
          if (rrs[l] == 8'b00100000 + geni) begin
            rrs[l] = 8'b01111111;
            rf[l] = addout;
          end
        add[geni] = 0;
        $display("add over: %b", geni);
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
    integer l;
    MUL mull(mulout, $signed(tmp[81:50]), $signed(tmp[49:18]));
    always @(posedge clk) begin
      if (tmp[1:1] == 1 && tmp[0:0] == 1) begin
        for (l = 0; l < 32; l = l + 1) 
          if (add[l] >> (`GENERAL_RS_SIZE - 1) == 1) begin
            if (8'b01000000 + geni == (add[l] >> 10) & 8'b11111111 && (add[l] >> 1) & 1'b1 == 0) begin
              tmp2 = add[l] & ((1 << 50) - 1);
              add[l] = (((add[l] >> 82 << 32) + $unsigned(mulout) << 50) + tmp2) | 2'b10;
            end
            if (8'b01000000 + geni == (add[l] >> 2) & 8'b11111111 && add[l] & 1'b1 == 0) begin
              tmp2 = add[l] & ((1 << 18) - 1);
              add[l] = (((add[l] >> 50 << 32) + $unsigned(mulout) << 18) + tmp2) | 2'b01;
            end
          end
        for (l = 0; l < 32; l = l + 1) 
          if (mul[l] >> (`GENERAL_RS_SIZE - 1) == 1) begin
            if (8'b01000000 + geni == (mul[l] >> 10) & 8'b11111111 && (mul[l] >> 1) & 1'b1 == 0) begin
              tmp2 = add[l] & ((1 << 50) - 1);
              mul[l] = (((mul[l] >> 82 << 32) + $unsigned(mulout) << 50) + tmp2) | 2'b10;
            end
            if (8'b01000000 + geni == (mul[l] >> 2) & 8'b11111111 && mul[l] & 1'b1 == 0) begin
              tmp2 = mul[l] & ((1 << 18) - 1);
              mul[l] = (((mul[l] >> 50 << 32) + $unsigned(mulout) << 18) + tmp2) | 2'b01;
            end
          end
        for (l = 0; l < 96; l = l + 1) 
          if (lw[l] >> (`GENERAL_RS_SIZE - 1) == 1) begin
            if (8'b01000000 + geni == (lw[l] >> 10) & 8'b11111111 && (lw[l] >> 1) & 1'b1 == 0) begin
              tmp2 = lw[l] & ((1 << 50) - 1);
              lw[l] = (((lw[l] >> 82 << 32) + $unsigned(mulout) << 50) + tmp2) | 2'b10;
            end
            if (8'b01000000 + geni == (lw[l] >> 2) & 8'b11111111 && lw[l] & 1'b1 == 0) begin
              tmp2 = lw[l] & ((1 << 18) - 1);
              lw[l] = (((lw[l] >> 50 << 32) + $unsigned(mulout) << 18) + tmp2) | 2'b01;
            end
          end
        for (l = 0; l < 32; l = l + 1) 
          if (sw[l] >> (`SW_RS_SIZE - 1) == 1) begin
            if (8'b01000000 + geni == (sw[l] >> 19) & 8'b11111111 && (sw[l] >> 2) & 1'b1 == 0) begin
              tmp2 = sw[l] & ((1 << 91) - 1);
              sw[l] = (((sw[l] >> 123 << 32) + $unsigned(mulout) << 91) + tmp2) | 3'b100;
            end
            if (8'b01000000 + geni == (sw[l] >> 11) & 8'b11111111 && (tmp >> 1) & 1'b1 == 0) begin
              tmp2 = sw[l] & ((1 << 59) - 1);
              sw[l] = (((sw[l] >> 91 << 32) + $unsigned(mulout) << 59) + tmp2) | 3'b010;
            end
            if (8'b01000000 + geni == (tmp >> 3) & 8'b11111111 && tmp & 1'b1 == 0) begin
              tmp2 = sw[l] & ((1 << 27) - 1);
              sw[l] = (((sw[l] >> 59 << 32) + $unsigned(mulout) << 27) + tmp2) | 3'b001;
            end
          end
        for (l = 0; l < 64; l = l + 1) 
          if (rrs[l] == 8'b01000000 + geni) begin
            rrs[l] = 8'b01111111;
            rf[l] = mulout;
          end
        mul[geni] = 0;
                $display("mul over: %b", geni);
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
    readable = 0;
    writable = 0;
  end
  //ALU for lw
  generate for (geni = 0; geni < 96; geni = geni + 1) begin:czplw
    wire[`GENERAL_RS_SIZE-1:0] tmp;
    reg signed[`WORD_SIZE-1:0] lwout;
    reg[`GENERAL_RS_SIZE-1:0] tmp2;
    assign tmp = lw[geni];
    wire[`WORD_SIZE-1:0] addres; // add result
    integer l;
    ADD addd(addres, $signed(tmp[81:50]), $signed(tmp[49:18]));
    always @(posedge clk) begin // need condition
      if (tmp[1:1] == 1'b1 && tmp[0:0] == 1'b1) begin
        cachein = addres;
        readable = 1;
        #0 if (miss == 1) begin
          #`CACHE_MISS_TIME lwout = cacheout;
        end else
          lwout = cacheout;
        readable = 0;
        for (l = 0; l < 32; l = l + 1) 
          if (add[l] >> (`GENERAL_RS_SIZE - 1) == 1) begin
            if (8'b10000000 + geni == (add[l] >> 10) & 8'b11111111 && (add[l] >> 1) & 1'b1 == 0) begin
              tmp2 = add[l] & ((1 << 50) - 1);
              add[l] = (((add[l] >> 82 << 32) + $unsigned(lwout) << 50) + tmp2) | 2'b10;
            end
            if (8'b10000000 + geni == (add[l] >> 2) & 8'b11111111 && add[l] & 1'b1 == 0) begin
              tmp2 = add[l] & ((1 << 18) - 1);
              add[l] = (((add[l] >> 50 << 32) + $unsigned(lwout) << 18) + tmp2) | 2'b01;
            end
          end
        for (l = 0; l < 32; l = l + 1) 
          if (mul[l] >> (`GENERAL_RS_SIZE - 1) == 1) begin
            if (8'b10000000 + geni == (mul[l] >> 10) & 8'b11111111 && (mul[l] >> 1) & 1'b1 == 0) begin
              tmp2 = add[l] & ((1 << 50) - 1);
              mul[l] = (((mul[l] >> 82 << 32) + $unsigned(lwout) << 50) + tmp2) | 2'b10;
            end
            if (8'b10000000 + geni == (mul[l] >> 2) & 8'b11111111 && mul[l] & 1'b1 == 0) begin
              tmp2 = mul[l] & ((1 << 18) - 1);
              mul[l] = (((mul[l] >> 50 << 32) + $unsigned(lwout) << 18) + tmp2) | 2'b01;
            end
          end
        for (l = 0; l < 96; l = l + 1) 
          if (lw[l] >> (`GENERAL_RS_SIZE - 1) == 1) begin
            if (8'b10000000 + geni == (lw[l] >> 10) & 8'b11111111 && (lw[l] >> 1) & 1'b1 == 0) begin
              tmp2 = lw[l] & ((1 << 50) - 1);
              lw[l] = (((lw[l] >> 82 << 32) + $unsigned(lwout) << 50) + tmp2) | 2'b10;
            end
            if (8'b10000000 + geni == (lw[l] >> 2) & 8'b11111111 && lw[l] & 1'b1 == 0) begin
              tmp2 = lw[l] & ((1 << 18) - 1);
              lw[l] = (((lw[l] >> 50 << 32) + $unsigned(lwout) << 18) + tmp2) | 2'b01;
            end
          end
        for (l = 0; l < 32; l = l + 1) 
          if (sw[l] >> (`SW_RS_SIZE - 1) == 1) begin
            if (8'b10000000 + geni == (sw[l] >> 19) & 8'b11111111 && (sw[l] >> 2) & 1'b1 == 0) begin
              tmp2 = sw[l] & ((1 << 91) - 1);
              sw[l] = (((sw[l] >> 123 << 32) + $unsigned(lwout) << 91) + tmp2) | 3'b100;
            end
            if (8'b10000000 + geni == (sw[l] >> 11) & 8'b11111111 && (tmp >> 1) & 1'b1 == 0) begin
              tmp2 = sw[l] & ((1 << 59) - 1);
              sw[l] = (((sw[l] >> 91 << 32) + $unsigned(lwout) << 59) + tmp2) | 3'b010;
            end
            if (8'b10000000 + geni == (tmp >> 3) & 8'b11111111 && tmp & 1'b1 == 0) begin
              tmp2 = sw[l] & ((1 << 27) - 1);
              sw[l] = (((sw[l] >> 59 << 32) + $unsigned(lwout) << 27) + tmp2) | 3'b001;
            end
          end
        for (l = 0; l < 64; l = l + 1) 
          if (rrs[l] == 8'b10000000 + geni) begin
            rrs[l] = 8'b01111111;
            rf[l] = lwout;
            $display("lw to register %b: %b %b", l, lwout, cacheout);
          end        
        lw[geni] = 0;
                $display("lw over: %b", geni);
      end
    end
  end
  endgenerate
  
  //ALU for sw
  generate for (geni = 0; geni < 32; geni = geni + 1) begin:czpsw
    wire[`SW_RS_SIZE-1:0] tmp;
    reg[`SW_RS_SIZE-1:0] tmp2;
    assign tmp = sw[geni];
    wire[`WORD_SIZE-1:0] addres;
    ADD addd(addres, $signed(tmp[81:50]), $signed(tmp[49:18]));
    always @(posedge clk) begin // need condition
      if (tmp[2:2] == 1'b1 && tmp[1:1] == 1'b1 && tmp[0:0] == 1'b1) begin
        write = tmp[113:82];
        cachein = addres;
        writable = 1;
        #0 if (miss == 1) begin
          #`CACHE_MISS_TIME writable = 0;
        end else
          writable = 0;
        sw[geni] = 0;
                $display("sw over: %b", geni);
      end
    end
  end
  endgenerate
  
  
  
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
          lw[i] = ((1'b1 << 32 << 32 << 8) + reg2 << 8) + reg3 << 2;
          if (rrs[reg2] == 8'b01111111) begin
            tmp2 = lw[i] & ((1 << 50) - 1);
            lw[i] = (((lw[i] >> 82 << 32) + rf[reg2] << 50) + tmp2) | 2'b10;
          end
          if (rrs[reg3] == 8'b01111111) begin
            tmp2 = lw[i] & ((1 << 18) - 1);
            lw[i] = (((lw[i] >> 50 << 32) + rf[reg3] << 18) + tmp2) | 2'b01;
          end
        end else begin
          lw[i] = (((1'b1 << 32 << 32) + $unsigned(imm) << 8) + reg2 << 8 << 2) + 1'b1;
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
          sw[i] = (((1'b1 << 32 << 32 << 32 << 8) + reg1 << 8) + reg2 << 8) + reg3 << 3;
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
          sw[i] = ((((1'b1 << 32 << 32 << 32) + $unsigned(imm) << 8) + reg1 << 8) + reg2 << 8 << 3) + 1'b1;
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
          add[i] = ((1'b1 << 32 << 32 << 8) + reg2 << 8) + reg3 << 2;
          if (rrs[reg2] == 8'b01111111) begin
            tmp2 = add[i] & ((1 << 50) - 1);
            add[i] = (((add[i] >> 82 << 32) + rf[reg2] << 50) + tmp2) | 2'b10;
          end
          if (rrs[reg3] == 8'b01111111) begin
            tmp2 = add[i] & ((1 << 18) - 1);
            add[i] = (((add[i] >> 50 << 32) + rf[reg3] << 18) + tmp2) | 2'b01;
          end
        end else begin
          add[i] = (((1'b1 << 32 << 32) + $unsigned(imm) << 8) + reg2 << 8 << 2) + 1'b1;
          if (rrs[reg2] == 8'b01111111) begin
            tmp2 = add[i] & ((1 << 50) - 1);
            add[i] = (((add[i] >> 82 << 32) + rf[reg2] << 50) + tmp2) | 2'b10;
          end
        end
        rrs[reg1] = i + 8'b00100000;
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
          mul[i] = ((1'b1 << 32 << 32 << 8) + reg2 << 8) + reg3 << 2;
          if (rrs[reg2] == 8'b01111111) begin
            tmp2 = mul[i] & ((1 << 50) - 1);
            mul[i] = (((mul[i] >> 82 << 32) + rf[reg2] << 50) + tmp2) | 2'b10;
          end
          if (rrs[reg3] == 8'b01111111) begin
            tmp2 = mul[i] & ((1 << 18) - 1);
            mul[i] = (((mul[i] >> 50 << 32) + rf[reg3] << 18) + tmp2) | 2'b01;
          end
        end else begin
          mul[i] = (((1'b1 << 32 << 32) + $unsigned(imm) << 8) + reg2 << 8 << 2) + 1'b1;
          if (rrs[reg2] == 8'b01111111) begin
            tmp2 = mul[i] & ((1 << 50) - 1);
            mul[i] = (((mul[i] >> 82 << 32) + rf[reg2] << 50) + tmp2) | 2'b10;
          end
        end
        rrs[reg1] = i + 8'b01000000;
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
          add[i] = ((1'b1 << 32 << 32) + reg2 << 8 << 2) + 1'b1;
          rrs[reg1] = i + 8'b00100000;
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