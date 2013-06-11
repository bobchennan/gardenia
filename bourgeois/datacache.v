`include "define.v"
`include "datamem.v"
// write back
// if write miss, move out dirty cache, move in new block, write back
module datacache(clk, in, readable, writable, write, out, miss);
  input clk;
  input[`WORD_SIZE-1:0] in; // address
  input readable, writable;
  input[`WORD_SIZE-1:0] write;
  output reg[`WORD_SIZE-1:0] out;
  output reg miss;

  wire[`CACHE_OFFSET_LEN-1:0] offset;
  assign offset=in[4:0];
  wire[`CACHE_INDEX_LEN-1:0] index;
  assign index=in[6:5];
  wire[`CACHE_TAG_LEN-1:0] tag;
  assign tag=in[31:7];

  reg[`CACHE_TAG_LEN-1:0] Tag[`CACHE_GROUP-1:0];
  reg[`BLOCK_SIZE-1:0] Val[`CACHE_GROUP-1:0];
  reg[`BLOCK_SIZE-1:0] Val2[`CACHE_GROUP-1:0];
  reg[`CACHE_GROUP-1:0] Valid, Dirty;

  wire hit;
  assign hit = Tag[index]==tag && Valid[index]; 

  reg[`BLOCK_SIZE-1:0] cachewrite;
  wire[`BLOCK_SIZE-1:0] ou1, ou2;
  reg cachereadable, cachewritable;
  reg[`WORD_SIZE-1:0] cachein;
  datamem data(.clk(clk), .in(cachein), .readable(cachereadable), .writable(cachewritable), .write(cachewrite), .out1(ou1), .out2(ou2));
    
  initial begin
    Valid[0]=0;
    Valid[1]=0;
    Valid[2]=0;
    Valid[3]=0;
    Dirty[0]=0;
    Dirty[1]=0;
    Dirty[2]=0;
    Dirty[3]=0;
    miss = 0;
    cachereadable = 0;
    cachewritable = 0;
    cachewrite = 0;
  end
  
  reg[`BLOCK_SIZE-1:0] tmp;
  always @(posedge clk) begin:czp
    //$display("aa %b %b %b, %b", in, readable, out, Val[index]);
    if (writable == 1) begin
      if (hit == 1) begin 
        tmp = Val[index];
        Val[index] = (((Val[index] >> (`BLOCK_SIZE - offset * `BYTE_SIZE) << 32) + write) 
         << (`BLOCK_SIZE - offset * `BYTE_SIZE -32))
         + (tmp & ((1 << (`BLOCK_SIZE - offset * `BYTE_SIZE -32)) - 1));
        Dirty[index] = 1;
      end else begin
        miss = 1;
        if (Dirty[index] == 1) begin
          cachein = Tag[index] << 6 + index << 4;
          cachewrite = Val[index];
          cachewritable = 1;
          cachewritable = 0;
        end
        cachein = in;
        cachereadable = 1;
        #`CACHE_MISS_TIME Val[index] = ou1;
        cachereadable = 0;
        Tag[index] = tag;
        Valid[index] = 1;
        tmp = Val[index];
        Val[index] = (((Val[index] >> (`BLOCK_SIZE - offset * `BYTE_SIZE) << 32) + write) 
         << (`BLOCK_SIZE - offset * `BYTE_SIZE -32)) 
         + (tmp & ((1 << (`BLOCK_SIZE - offset * `BYTE_SIZE -32)) - 1));
        Dirty[index] = 1;
      end
    end
    if ((readable == 1) || (writable == 1)) begin
      if (hit == 1) begin
          out = (Val[index] >> (`BLOCK_SIZE - offset * `BYTE_SIZE - `WORD_SIZE)) & 32'b11111111_11111111_11111111_11111111;
      end else begin
        miss = 1;
        if (Dirty[index] == 1) begin
          cachein = Tag[index] << 6 + index << 4;
          cachewrite = Val[index];
          cachewritable = 1;
          cachewritable = 0;
          Dirty[index] = 0;
        end
        cachein = in;
        cachereadable = 1;
        #`CACHE_MISS_TIME
        Val[index] = ou1;
        cachereadable = 0;
        Tag[index] = tag;
        Valid[index] = 1;
        out = (Val[index] >> (`BLOCK_SIZE - offset * `BYTE_SIZE - `WORD_SIZE)) & 32'b11111111_11111111_11111111_11111111;
        //$display("## %b %b %b", index, Val[index], ou1);
      end
    end
    miss = 0;
  end
endmodule
