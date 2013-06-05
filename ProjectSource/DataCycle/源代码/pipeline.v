`include "timescale.v"
`include "Newdefine.h"

module pipeline
	(
		clk			,
		rst			,
		
		stall		,	//for conflict detecting, but no time left to program...
		flush		,
		
		D			,	// Data in
		Q				// Data Out
	);

	parameter	PIPEWIDTH=`DataWidth;

	input					clk		;
	input					rst		;
	
	input 					stall	,
							flush	;
							
	input	[PIPEWIDTH-1:0]	D		;
	
	output	[PIPEWIDTH-1:0]	Q		;
	
	reg [PIPEWIDTH-1:0] 		RegQ			; 

   // priority of stall over flush
   
	always@(`CLOCK_EDGE clk)
	// Write synchronously in the register
	begin
		if (rst == `RESET_ON)
			RegQ = `LOW;		// reset synchronously
		else if(stall == `HIGH)
			RegQ = RegQ;		// don't update
		else if(flush == `HIGH)//(suppress glitch from the combinatorial calculated flush signal)
			RegQ = `LOW;		// clear
		else
			RegQ = D;		// else update
	end
	
	// Read asynchronously from the register
	assign Q = RegQ;
	
endmodule
