/*
FILE NAME:			div_adder.v
FUNCTION:			a div-array built with CAS module. 
TO DO:				如果Q[0]==0 最后一位不够减则： R 需要取补
AUTHOR:				LiLongyi
DATE(YY/MM/DD):		09/01/19
*/

module div_array (input[63:0] A,input[31:0] B,output[31:0] R,Q);
	wire a[31:0][31:0], ci[31:0][31:0], cout[31:0][31:0], sum[31:0][31:0];
	wire p[31:0];
	
	generate	
	genvar i,j; 
	for(j=0;j<32;j=j+1)begin : aaaa
		for(i=0;i<32;i=i+1)begin :aa
		CAS C (a[i][j], B[31-j], p[i], ci[i][j], cout[i][j], sum[i][j]);
	end
	end
	
	//a
	for(i=0;i<32;i=i+1)begin :bb
		assign a[0][i] = A[62-i];
	end
	for(i=1;i<32;i=i+1)begin :c
		assign a[i][31] = A[31-i];
	end
	
	for(i=1;i<32;i=i+1)begin :d
		for(j=0;j<31;j=j+1)begin :dd
		assign a[i][j] = sum[i-1][j+1];
	end
	end
	//p
	
	assign p[0] = A[63]^{1'b1};
	for(i=1;i<=31;i=i+1)begin :e
		assign p[i] = cout[i-1][0];
	end
	
	//ci
	for(i=0;i<32;i=i+1)begin:f
		for(j=0;j<31;j=j+1)begin :ff
		assign ci[i][j] = cout[i][j+1];
		end
	assign ci[i][31] = p[i];
	end
	
	//cout
	for(i=0;i<=31;i=i+1)begin :g
	assign Q[31-i] = cout[i][0];
	end

	for(j=0;j<32;j=j+1)begin :iiii
	assign R[j] = sum[31][31-j];
	end
	endgenerate
	

endmodule




	
module CAS(input a, b, p1, c, output cout, sum);
	wire t,p,g;
	assign t = b ^ p1;
	assign g = t & a;
	assign p = t ^ a;
	assign sum = p ^ c;
	assign cout = g |( c & p);
endmodule