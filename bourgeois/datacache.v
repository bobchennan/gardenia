`include "define.v"
`include "datamem.v"
// write back
// if write miss, move out dirty cache, move in new block, write back
module datacache(clk, in, readable, writable, write, out, hit, flush);
  input clk;
  input[`WORD_SIZE-1:0] in; // address
  input readable, writable;
  input[`WORD_SIZE-1:0] write;
  output reg[`WORD_SIZE-1:0] out;
  input flush;

  wire[`CACHE_OFFSET_LEN-1:0] offset;
  assign offset=in[6:0];
  wire[`CACHE_INDEX_LEN-1:0] index;
  assign index=in[9:7];
  wire[`CACHE_TAG_LEN-1:0] tag;
  assign tag=in[31:10];

  reg[`CACHE_TAG_LEN-1:0] Tag[`CACHE_GROUP-1:0];
  reg[`BLOCK_SIZE-1:0] Val[`CACHE_GROUP-1:0];
  reg[`BLOCK_SIZE-1:0] Val2[`CACHE_GROUP-1:0];
  reg[`CACHE_GROUP-1:0] Valid, Dirty;

  output hit;
  assign hit = Tag[index]===tag && Valid[index]; 

  reg[`BLOCK_SIZE-1:0] cachewrite;
  wire[`BLOCK_SIZE-1:0] ou1, ou2;
  reg cachereadable, cachewritable;
  reg[`WORD_SIZE-1:0] cachein;
  reg cacheflush;
  datamem data(clk, cachein, cachereadable, cachewritable, cachewrite, ou1, ou2, cacheflush);
  
  reg[`CACHE_GROUP-1:0] i;
  initial begin
    for (i = 0; i < 8; i = i + 1) begin
      Valid[i] = 0;
      Dirty[i] = 0;
    end
    cachereadable = 0;
    cachewritable = 0;
    cachewrite = 0;
    cacheflush = 0;
  end
  
  reg[`BLOCK_SIZE-1:0] tmp;
  always @(writable) begin:czp
    //$display("aa %b %b %b, %b", in, readable, out, Val[index]);
    if (writable == 1) begin
      if (hit === 1) begin 
        tmp = Val[index];
        Val[index] = (((Val[index] >> (`BLOCK_SIZE - offset * `BYTE_SIZE) << 32) + write) 
         << (`BLOCK_SIZE - offset * `BYTE_SIZE -32))
         + (tmp & ((1 << (`BLOCK_SIZE - offset * `BYTE_SIZE -32)) - 1));
        Dirty[index] = 1;
        //if(write!=0)$display("cache write %g:%b", in, write);
      end else begin
        if (Dirty[index] == 1) begin
          cachein = Tag[index] << 3 + index << 7;
          cachewrite = Val[index];
          cachewritable = 1;
          #0 cachewritable = 0;
          #0 cacheflush = cacheflush;
          //$display("write mem tag %b index %b %g %b", Tag[index], index, cachein, cachewrite);
        end
        cachein = in;
        cachereadable = 1;
        #`CACHE_MISS_TIME Val[index] = ou1;
        cachereadable = 0;
        #0 Tag[index] = tag;
        //$display("read mem %g %b", cachein, ou1);
        Valid[index] = 1;
        tmp = Val[index];
        Val[index] = (((Val[index] >> (`BLOCK_SIZE - offset * `BYTE_SIZE) << 32) + write) 
         << (`BLOCK_SIZE - offset * `BYTE_SIZE -32)) 
         + (tmp & ((1 << (`BLOCK_SIZE - offset * `BYTE_SIZE -32)) - 1));
        Dirty[index] = 1;
        //if(write!=0)$display("cache write %g:%b", in, write);
      end
    end
  end
  always @(readable) begin
    if (readable == 1) begin
      //$display("cache %g:%b", in, out);
      if (hit === 1) begin
          out = (Val[index] >> (`BLOCK_SIZE - offset * `BYTE_SIZE - `WORD_SIZE)) & 32'b11111111_11111111_11111111_11111111;
          //$display("cache hit %g:%b", in, out);
      end else begin
        if (Dirty[index] == 1) begin
          cachein = Tag[index] << 3 + index << 7;
          cachewrite = Val[index];
          cachewritable = 1;
          #0 cachewritable = 0;
          #0 Dirty[index] = 0;
          //$display("write mem tag %b index %b %g %b", Tag[index], index, cachein, cachewrite);
        end
        cachein = in;
        //$display("cachein=%b",in);
        cachereadable = 1;
        #`CACHE_MISS_TIME Val[index] = ou1;
        cachereadable = 0;
        #0 Tag[index] = tag;
        //$display("read mem %g %b", cachein, ou1);
        Valid[index] = 1;
        out = (Val[index] >> (`BLOCK_SIZE - offset * `BYTE_SIZE - `WORD_SIZE)) & 32'b11111111_11111111_11111111_11111111;
        //$display("cache miss %g:%b %b", in, out, Val[index]);
        //$display("## %b %b %b", index, Val[index], ou1);
      end
    end
  end
  
  always @(flush) begin
    //$display("datacache halt %b", flush);
    if (flush == 1) begin
      for (i = 0; i < 8; i = i + 1) 
        if (Valid[i] == 1 && Dirty[i] == 1) begin
          cachein = Tag[i] << 3 + i << 7;
          cachewrite = Val[i];
          cachewritable = 1;
          #`CACHE_MISS_TIME cachewritable = 0;
          #0 Dirty[i] = 0;
        end
      cacheflush = 1;
    end
  end
endmodule
