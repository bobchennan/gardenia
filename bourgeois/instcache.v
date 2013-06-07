`include "define.v"

module instcache(clk, in, hit, out);
  input clk;
  input[`BYTE_SIZE-1:0] in; // address
  //input writable;
  //input[`BLOCK_SIZE-1:0] write;
  output wire hit;
  output reg[31:0] out;

  wire[`CACHE_OFFSET_LEN-1:0] offset;
  assign offset=in[4:0];
  wire[`CACHE_INDEX_LEN-1:0] index;
  assign index=in[6:5];
  wire[`CACHE_TAG_LEN-1:0] tag;
  assign tag=in[31:7];

  reg[`CACHE_TAG_len-1:0] Tag[`CACHE_GROUP-1:0];
  reg[`BLOCK_SIZE-1:0] Val[`CACHE_GROUP-1:0];
  //reg[`CACHE_GROUP-1:0] Valid;

  assign hit = Tag[index]==tag; 

  initial begin
  	//Valid <= `CACHE_GROUP`b0;
  end

  wire[`BLOCK_SIZE-1:0] out1, out2;

  always @(posedge clk) begin
	/*if(writable == 1`b1 && hit == 1`b0)begin
		if(Valid[index]==1`b1)
			instmem(.clk(clk), .in(((Tag[index]<<2)+index)<<10), .writable(1`b1), .write(Val[index]), .out1(out1), .out2(out2));
		Val[index] = write;
		Tag[index] = tag;
		Valid[index] = 1`b0;
	end	else begin
		if(writable==1`b1 && hit == 1`b1)begin
			Val[index] = write;
			Valid[index] = 1`b1;
		end else begin*/
			if(hit == 1`b1)begin
				out = Val[index][offset+31,offset];
			end
			else begin
				instmem(.clk(clk), .in(in), .writable(1`b0), .write(`BLOCK_SIZE`b0), .out1(out1), .out2(out2));
        Val[index] = out1;
        Tag[index] = tag;
        Valid[index] = 1`b0;
        out = Val[index][offset+31,offset];
			end/*
		end
	end*/
  end