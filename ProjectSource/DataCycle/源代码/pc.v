`include "timescale.v"
`include "Newdefine.h"
//checked 1.16
module	pc
	(
		clk			,
		rst			,

		mux_pc		,
		stall		,
		PC			,
		PC4
	);
	
	input				clk	;
	input				rst	;
	input				stall	;	//for conflict detecting, but no time left to program...

	input [`AddrWidth-1:0]		mux_pc;  	
                             	
	output [`AddrWidth-1:0]	PC	;
	output [`AddrWidth-1:0]	PC4	;
	
	reg	 [`AddrWidth-1:0]		PC		;
	wire [`AddrWidth-1:0]		PC4		;

	always@(`CLOCK_EDGE clk, `RESET_EDGE rst)
	begin
		if 		(rst == `RESET_ON)	PC = `ZERO;	// RESET
		else if	(stall == `HIGH) 	PC = PC;	// No Move
 		else	PC	= mux_pc;	// pc change
	end
	assign PC4	=	PC + `AddrWidth'd1;

endmodule
