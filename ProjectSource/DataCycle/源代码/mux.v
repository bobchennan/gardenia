`include "timescale.v"
`include "Newdefine.h"

//mux2,3,4,5,6,7


module	mux2
	(
		in0			,	// Input A
		in1			,	// Input B
		select			,	// select
		out				// Output
	);
	parameter	MUXWIDTH=`DataWidth;
	input [MUXWIDTH-1:0]	in0	,
							in1	;
	                         	
	input					select	;
                             	
	output [MUXWIDTH-1:0]	out	;

	assign out =	(select == 0) ?	in0:in1;

endmodule

module	mux3
	(
		in0			,	// input A
		in1			,	// input B
		in2			,	// input C
		select		,	// select
		out				// Output
	);
	parameter	MUXWIDTH=`DataWidth;
	input [MUXWIDTH-1:0]	in0	,
							in1	,
							in2	;
	                         	
	input [1:0]				select	;
                             	
	output [MUXWIDTH-1:0]	out	;

	assign out =	(select == 0) ?	in0:
					(select == 1) ?	in1:
									in2;


endmodule

module	mux4
	(
		in0		,	// input A
		in1		,	// input B
		in2		,	// input C
		in3		,	// input D
		select		,	// select
		out			// Output
	);
	parameter	MUXWIDTH=`DataWidth;
	input [MUXWIDTH-1:0]	in0	,
							in1	,
							in2	,
							in3	;
	                         	
	input [1:0]				select	;
                             	
	output [MUXWIDTH-1:0]	out	;
	
	assign out =	(select == 0) ?	in0:
					(select == 1) ?	in1:
					(select == 2) ?	in2:
									in3;

endmodule

module	mux5
	(
		in0		,	// input A
		in1		,	// input B
		in2		,	// input C
		in3		,	// input D
		in4		,	// input E
		select		,	// select
		out			// Output
	);
	parameter	MUXWIDTH=`DataWidth;
	input [MUXWIDTH-1:0]	in0	,
							in1	,
							in2	,
							in3	,
							in4	;
	                         	
	input [2:0]				select	;
                             	
	output [MUXWIDTH-1:0]	out	;

	assign out =	(select == 0) ?	in0:
					(select == 1) ?	in1:
					(select == 2) ?	in2:
					(select == 3) ?	in3:
									in4;

endmodule

module	mux6
	(
		in0		,	// input A
		in1		,	// input B
		in2		,	// input C
		in3		,	// input D
		in4		,	// input E
		in5		,	// input F
		select		,	// select
		out			// Output
	);
	parameter	MUXWIDTH=`DataWidth;
	input [MUXWIDTH-1:0]	in0	,
							in1	,
							in2	,
							in3	,
							in4	,
							in5	;
	                         	
	input [2:0]				select	;
                             	
	output [MUXWIDTH-1:0]	out	;

	assign out =	(select == 0) ?	in0:
					(select == 1) ?	in1:
					(select == 2) ?	in2:
					(select == 3) ?	in3:
					(select == 4) ?	in4:
									in5;

endmodule

module	mux7
	(
		in0			,	// input A
		in1			,	// input B
		in2			,	// input C
		in3			,	// input D
		in4			,	// input E
		in5			,	// input F
		in6			,	// input G
		select			,	// select
		out				// Output
	);
	parameter	MUXWIDTH=`DataWidth;

	input [MUXWIDTH-1:0]	in0	,
							in1	,
							in2	,
							in3	,
							in4	,
							in5	,
							in6	;
	
	input [2:0]				select	;

	output [MUXWIDTH-1:0]	out	;

	assign out =	(select == 0) ?	in0:
					(select == 1) ?	in1:
					(select == 2) ?	in2:
					(select == 3) ?	in3:
					(select == 4) ?	in4:
					(select == 5) ?	in5:
									in6;

endmodule
