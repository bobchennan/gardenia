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
      //$display("empty %g", i);
    end
    cachereadable = 0;
    cachewritable = 0;
    cachewrite = 0;
    cacheflush = 0;
  end
  
  reg[`BLOCK_SIZE-1:0] tmp;
  always @(writable) begin:czp
    if (writable == 1) begin
      if (hit === 1) begin 
        tmp = Val[index];
        Val[index] = (((Val[index] >> (`BLOCK_SIZE - offset * `BYTE_SIZE) << 32) + write) 
         << (`BLOCK_SIZE - offset * `BYTE_SIZE -32))
         + (tmp & ((1 << (`BLOCK_SIZE - offset * `BYTE_SIZE -32)) - 1));
        Dirty[index] = 1;
        $display("cache write %g:%b", in, write);
      end else begin
        #`CACHE_MISS_TIME 
        if (Dirty[index] == 1) begin
          cachein = Tag[index] << 10 + index << 7;
          cachewrite = Val[index];
          cachewritable = 1;
          #0 cachewritable = 0;
        end
        cachein = in;
        cachereadable = 1;
        Val[index] = ou1;
        cachereadable = 0;
        Tag[index] = tag;
        Valid[index] = 1;
        tmp = Val[index];
        Val[index] = (((Val[index] >> (`BLOCK_SIZE - offset * `BYTE_SIZE) << 32) + write) 
         << (`BLOCK_SIZE - offset * `BYTE_SIZE -32)) 
         + (tmp & ((1 << (`BLOCK_SIZE - offset * `BYTE_SIZE -32)) - 1));
        Dirty[index] = 1;
        $display("cache write %g:%b", in, write);
      end
    end
  end
  always @(posedge clk) begin
    $display("cache Tag[0]:%b", Tag[0]);
    if (readable == 1) begin
      
      if (hit === 1) begin
          out = (Val[index] >> (`BLOCK_SIZE - offset * `BYTE_SIZE - `WORD_SIZE)) & 32'b11111111_11111111_11111111_11111111;
          $display("cache hit %g", in, out);
      end else begin
        if (Dirty[index] == 1) begin
          cachein = Tag[index] << 10 + index << 7;
          cachewrite = Val[index];
          cachewritable = 1;
          #0 cachewritable = 0;
          Dirty[index] = 0;
        end
        cachein = in;
        cachereadable = 1;
        $display("datacache begin wait");
        #`CACHE_MISS_TIME Val[index] = ou1;
        $display("datacache end wait");
        cachereadable = 0;
        Tag[index] = tag;
        Valid[index] = 1;
        out = (Val[index] >> (`BLOCK_SIZE - offset * `BYTE_SIZE - `WORD_SIZE)) & 32'b11111111_11111111_11111111_11111111;
        $display("cache miss %g:%b index %g Tag %b tag %b", in, out, index, Tag[index], tag);
        //$display("## %b %b %b", index, Val[index], ou1);
      end
    end
  end
  
  always @(flush) begin
    $display("datacache halt %b", flush);
    if (flush == 1) begin
      for (i = 0; i < 8; i = i + 1) 
        if (Valid[i] == 1 && Dirty[i] == 1) begin
          cachein = Tag[i] << 10 + i << 7;
          cachewrite = Val[i];
          cachewritable = 1;
          #0 cachewritable = 0;
          Dirty[i] = 0;
        end
      cacheflush = 1;
    end
  end
endmodule