`include "timescale.v"
`include "Newdefine.h"

module alu
	(
		aluop		,
		opA			,
		opB			,
		flagin		,
		result		,
		flag		,
		special
	);
	
	input 	[3:0]					aluop	;
	input 							flagin	;
	input	[`DataWidth-1:0]		opA,opB	;
	output 	[`DataWidth-1:0]		result	;
	output 	[31:0]					special	;
	output 	[3:0]					flag	;
	reg		[3:0]					flag	;
	

	reg [`DataWidth:0]				rResult					;	// Extended Result to n+1 bits for the carry flag
	wire[`DataWidth-1:0]			wResultExt = rResult[`DataWidth-1:0];

	wire						wZero					,
								wOver					,
								wCarry					,
								wNeg					;
	                        	        				
	reg [`DataWidth-1:0] 			rAu						,
								rBu						;
	                        	
	wire						wRn = rResult[`DataWidth-1]	;
	wire 						wAn = opA[`DataWidth-1]		;	// MSB
	wire 						wBn = opB[`DataWidth-1]		;	// MSB
	wire    					wSubt					;
	

	always @(aluop, opA, opB, flagin)
	begin
		rAu = opA;	// Unsigned Operand A
		rBu = opB;	// Unsigned Operand B
		case (aluop)
			`aluop_add		: rResult	<=   opA + opB;					// Arithmetic Operation : Signed ADD
			`aluop_sub		: rResult	<=   opA - opB;					// Arithmetic Operation : Signed SUB
			`aluop_and		: rResult	<=   opA & opB;					// Logic Operation : AND
			`aluop_or		: rResult	<=   opA | opB;					// Logic Operation : OR
			`aluop_xor		: rResult	<=   opA ^ opB;					// Logic Operation : XOR
			default			: rResult	<= 	 opB;						// Transfert
		endcase
		if(flagin)
			flag = {wNeg, wZero, wCarry, wOver};
		else
			flag = flag;
	end
		
	assign wCarry 	= rResult[`DataWidth];						// Carry flag
	assign wNeg		= wResultExt[`DataWidth-1];					// Negate flag
	assign wZero 	= (wResultExt == `ZERO);				// Zero flag
	
	assign wSubt	= (aluop == `aluop_sub);
	assign wOver	= 	(( wRn & ~wAn & ~(wSubt ^ wBn))		// Overflow flag
				  		|(~wRn &  wAn &  (wSubt ^ wBn)));
				  
	//assign flag = {wCarry, wZero, wNeg, wOver};			// The Status flags
	assign result = wResultExt;							// The result
	
endmodule

