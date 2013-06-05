/*
FILE NAME:			carry_save_mult.v
FUNCTION:			A multi-array which constitute with and-gate, half-adder and full-adder.
TO DO:				Finished!
AUTHOR:				LiLongyi
Delay:				about 45ns
DATE(YY/MM/DD):		09/01/18
*/

module carry_save_mult(x_in, y_in, p);
	
	input  [31:0] x_in;
	input  [31:0] y_in;
	output [63:0] p;
	//reg	   [63:0] p;

	//full adder
	wire  Ci[31:2][30:0], Ai[31:2][30:0], Bi[31:2][30:0], Pout[31:2][30:0], Cout[31:2][30:0];
	//half adder
	wire Ai1[31:2], Bi1[31:2], Cout1[31:2],Pout1 [31:2];
	//32bit adder
	wire[31:0] A,B;
	wire and_res[31:0][31:0];
	//assign x_in = 1;
	//assign y_in = 3;
	CarryLookahead_Adder_32 CA0(A,B,1'b0,p[62:31],p[63]);
	assign	Ci[2][30] = 1'b0;
	generate
	genvar ii,jj,i, j;
	

	
	for(jj=0;jj<=30;jj=jj+1)begin :u
	for(ii=2;ii<=31;ii=ii+1)begin :uu
	full_adder FA1 (Ai[ii][jj],Bi[ii][jj],Ci[ii][jj],Pout[ii][jj],Cout[ii][jj]);
	end
	end
		
	for(ii=2;ii<=31;ii=ii+1)begin : v
		half_adder HA (Ai1[ii],Bi1[ii],Pout1[ii],Cout1[ii]);
		
	end
	//assign and_res[][] = 	
	
	for(i=0;i<32;i=i+1)begin :a
		for(j=0;j<32;j=j+1)begin :aa
		assign and_res[i][j] = x_in[i]&y_in[j];
	end
	end


	//and_res row0 
	assign p[0] = and_res[0][0];
	assign Bi1[2]= and_res[0][1] ;
	
	for(i=2;i<=31;i=i+1)begin :aaa
		assign  Ci[2][i-2]= and_res[0][i]; 
	end
	//and_res row1 and_res
	assign Ai1[2] = and_res[1][0];
	for(i=1;i<=31;i=i+1)begin :b
		assign  Ai[2][i-1]= and_res[1][i] ;
	end	
	//and_res row2-31 mid and right
	for(i=2;i<=31;i=i+1)begin:c
		for(j=0;j<=30;j=j+1)begin:cc
		assign Bi[i][j] = and_res[i][j] ;
	end
	end	
	//and_res row2-30 left 
	for(i=2;i<=30;i=i+1)begin:d
		assign Ai[i+1][30] = and_res[i][31]; 
	end
	//and_res row31 left
	assign A[31] = and_res[31][31];
	
	
	//pout right col-1
	for(i=2;i<=31;i=i+1)
	begin:e
		assign p[i-1] = Pout1[i] ;
	end
	
	//pout right row 2-30 col 0
	for(i=2;i<=30;i=i+1)
	begin:f
		assign Ai1[i+1] = Pout[i][0] ;
	end
	
	//pout left mid row 2-30 col 1-31
	for(i=2;i<=30;i=i+1)begin:g
		for(j=1;j<31;j=j+1)begin:gg
		assign Ai[i+1][j-1] =Pout[i][j]  ;
	end
	end	
	//pout bottom row 31
	for(i=0;i<=30;i=i+1)begin:h
		assign A[i] = Pout[31][i] ;
	end	
	//cout
	for(i=2;i<=30;i=i+1)
	begin:k
		assign Bi1[i+1] =Cout1[i] ;
		for(j=0;j<=30;j=j+1)begin:kk
		assign Ci[i+1][j] =Cout[i][j] ;
		end
	end
	
	assign  B[0] = Cout1[31] ;
	
	for(j=0;j<=30;j=j+1)begin:l
	assign B[j+1] = Cout[31][j];
	end
	


	endgenerate
endmodule

module CarryLookahead_Adder_32 (input[31:0] A,B,input C_in,output[31:0] D,output C_out);

//reg[31:0] D;

`ifdef SIMULATING
reg [31:0] G,P;
reg [7:0] G_temp,P_temp;
reg [1:0] G_temp1,P_temp1;
reg G_temp2,P_temp2;
reg [32:1] C_temp;
reg [8:1] C_temp1;
`else
wire [31:0] G,P;
wire [7:0] G_temp,P_temp;
wire [1:0] G_temp1,P_temp1;
wire G_temp2,P_temp2;
wire [32:1] C_temp;
wire [8:1] C_temp1;
`endif

	generate
	
	genvar ii;
	full_adder FA0 (A[0],B[0],C_in,D[0],,P[0],G[0]);
	for(ii=1;ii<=31;ii=ii+1)begin :uu
		full_adder FA (A[ii],B[ii],C_temp[ii],D[ii],,P[ii],G[ii]);
	end
	endgenerate

//assign D = P ^ C;





CarryLookahead CL0 (G[3:0],P[3:0],C_in,C_temp[4:1],G_temp[0],P_temp[0]);
CarryLookahead CL1 (G[7:4],P[7:4],C_temp1[1],C_temp[8:5],G_temp[1],P_temp[1]);
CarryLookahead CL2 (G[11:8],P[11:8],C_temp1[2],C_temp[12:9],G_temp[2],P_temp[2]);
CarryLookahead CL3 (G[15:12],P[15:12],C_temp1[3],C_temp[16:13],G_temp[3],P_temp[3]);
CarryLookahead CL4 (G[19:16],P[19:16],C_temp1[4],C_temp[20:17],G_temp[4],P_temp[4]);
CarryLookahead CL5 (G[23:20],P[23:20],C_temp1[5],C_temp[24:21],G_temp[5],P_temp[5]);
CarryLookahead CL6 (G[27:24],P[27:24],C_temp1[6],C_temp[28:25],G_temp[6],P_temp[6]);
CarryLookahead CL7 (G[31:28],P[31:28],C_temp1[7],C_temp[32:29],G_temp[7],P_temp[7]);

CarryLookahead CL8 (G_temp[3:0],P_temp[3:0],C_in,C_temp1[4:1],G_temp1[0],P_temp1[0]);
CarryLookahead CL9 (G_temp[7:4],P_temp[7:4],C_temp1[4],C_temp1[8:5],G_temp1[1],P_temp1[1]);

assign C_out = C_temp1[8];

endmodule



/*
FILE NAME:			CarryLookahead.v
FUNCTION:			provide CarryLookahead chain module(4bit)
TO DO:				to test in upper module
AUTHOR:				LiLongyi
DATE(YY/MM/DD):		09/01/02
*/



module CarryLookahead (G_in,P_in,C_in,C_overall,G_overall,P_overall);
input [3:0] G_in,P_in;
output [4:1] C_overall;
input C_in;
output G_overall,P_overall;
wire [3:0] G_in,P_in;
wire [4:1] C_overall;
wire C_in;
wire G_overall,P_overall;
assign C_overall[1] = G_in[0] | P_in[0] & C_in;
assign C_overall[2] = G_in[1] | P_in[1] & G_in[0] | P_in[1] & P_in[0] & C_in;
assign C_overall[3] = G_in[2] | P_in[2] & G_in[1] | P_in[2] & P_in[1] & G_in[0] | P_in[2] & P_in[1] & P_in[0] & C_in;
assign C_overall[4] = G_overall | P_overall & C_in;
assign G_overall = G_in[3] | P_in[3] & G_in[2] | P_in[3] & P_in[2] & G_in[1] | P_in[3] & P_in[2] & P_in[1] & G_in[0];
assign P_overall = P_in[3] & P_in[2] & P_in[1] & P_in[0];
endmodule

module full_adder(input a,b,c, output sum,cout, p, g);
	assign g = a & b;
	assign p = a ^ b;
	assign sum = p ^ c;
	assign cout = g |( c & p);


endmodule

	module half_adder(input a,b, output  sum,cout);
	assign cout = a & b;
	assign sum = a ^ b;
endmodule