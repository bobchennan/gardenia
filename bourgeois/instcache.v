`include "define.v"
`include "instmem.v"

module instcache(clk, in, out);
  input clk;
  input[`WORD_SIZE-1:0] in; // address
  //input writable;
  //input[`BLOCK_SIZE-1:0] write;
  output reg[`BLOCK_SIZE-1:0] out;

  wire[`CACHE_OFFSET_LEN-1:0] offset;
  assign offset=in[4:0];
  wire[`CACHE_INDEX_LEN-1:0] index;
  assign index=in[6:5];
  wire[`CACHE_TAG_LEN-1:0] tag;
  assign tag=in[31:7];

  reg[`CACHE_TAG_LEN-1:0] Tag[`CACHE_GROUP-1:0];
  reg[`BLOCK_SIZE-1:0] Val[`CACHE_GROUP-1:0];
  reg[`BLOCK_SIZE-1:0] Val2[`CACHE_GROUP-1:0];
  reg[`CACHE_GROUP-1:0] Valid;

  wire hit;
  assign hit = Tag[index]==tag && Valid[index]; 

  wire[`BLOCK_SIZE-1:0] ou1, ou2;
  instmem inst(.clk(clk), .in(in), .readable(1'b1), .writable(1'b0), .write(`BLOCK_SIZE'b0), .out1(ou1), .out2(ou2));
    
  initial begin
    Valid[0]=0;
    Valid[1]=0;
    Valid[2]=0;
    Valid[3]=0;
  end
        
  always @(posedge clk) begin:cnx
	/*if(writable == 1`b1 && hit == 1`b0)begin
		if(Valid[index]==1`b1)
			instmem(.clk(clk), .in(((Tag[index]<<2)+index)<<10), .writable(1`b1), .write(Val[index]), .out1(out1), .out2(out2));
		Val[index] = write;
		Tag[index] = tag;
		Valid[index] = 1'b0;
	end	else begin
		if(writable==1'b1 && hit == 1'b1)begin
			Val[index] = write;
			Valid[index] = 1'b1;
		end else begin*/
		  //$display("cache tag1 %b tag2 %b", Tag[index], tag);
		  if(hit == 0)begin
		    Val[index] = ou1;
		    Val2[index] = ou2;
        Tag[index] = tag;
        Valid[index] = 1;
      end
	    out=Val[index]<<(offset*`BYTE_SIZE);
	    out=out+(Val2[index]>>(`BLOCK_SIZE-offset*`BYTE_SIZE));
	/*end
	end*/
  end
endmodule
