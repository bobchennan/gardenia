`include "define.v"
`include "instmem.v"

module instcache(clk, in, out, hit);
  input clk;
  input[`WORD_SIZE-1:0] in; // address
  //input writable;
  //input[`BLOCK_SIZE-1:0] write;
  output reg[`BLOCK_SIZE-1:0] out;

  wire[`CACHE_OFFSET_LEN-1:0] offset;
  assign offset=in[4:0];
  wire[`CACHE_INDEX_LEN-1:0] index;
  assign index=in[7:5];
  wire[`CACHE_TAG_LEN-1:0] tag;
  assign tag=in[31:8];

  reg[`CACHE_TAG_LEN-1:0] Tag[`CACHE_GROUP-1:0];
  reg[`BLOCK_SIZE-1:0] Val[`CACHE_GROUP-1:0];
  reg[`BLOCK_SIZE-1:0] Val2[`CACHE_GROUP-1:0];
  reg[`CACHE_GROUP-1:0] Valid;

  output hit;
  assign hit = Tag[index]===tag && Valid[index]===1; 

  wire[`BLOCK_SIZE-1:0] ou1, ou2;
  instmem inst(.clk(clk), .in(in), .readable(1'b1), .writable(1'b0), .write(`BLOCK_SIZE'b0), .out1(ou1), .out2(ou2));
    
  initial begin
    Valid[0]=0;
    Valid[1]=0;
    Valid[2]=0;
    Valid[3]=0;
    Valid[4]=0;
    Valid[5]=0;
    Valid[6]=0;
    Valid[7]=0;
    //$display("cache initial");
  end
        
  always @(posedge clk) begin:cnx
      //$display("%b index:%g tag1:%b tag2:%b valid:%b", hit, index, Tag[index], tag, Valid[index]);
      if(hit !== 1)begin
        $display("warning %g miss store in %g", in, index);
		    #`CACHE_MISS_TIME Val[index] = ou1;
		    Val2[index] = ou2;
        Tag[index] = tag;
        Valid[index] = 1;
      end
	    out=Val[index]<<(offset*`BYTE_SIZE);
	    out=out+(Val2[index]>>(`BLOCK_SIZE-offset*`BYTE_SIZE));
	    //$display("cache finish");
  end
endmodule
