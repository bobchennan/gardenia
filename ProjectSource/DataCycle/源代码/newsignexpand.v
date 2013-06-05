`include "timescale.v"
`include "Newdefine.h"

module signexpander
	(
		imm8		,
		imm16		,
		imm26		,
		SEop		,
		out32		
	);
	
	input	[7:0]			imm8;
	input	[15:0]			imm16;
	input	[25:0]			imm26;
	input	[2:0]			SEop;
	output	[31:0]			out32;
	reg		[31:0]			out32;
	
	always@(SEop)
	begin
		case (SEop)
			`signbyte		:	out32	=	{{24{imm8[7]}},imm8}; 		// signed byte
			`unsignbyte		:	out32	=	{{24{1'b0}},imm8}; 			// unsigned byte
			`signhalf		:	out32	=	{{16{imm16[15]}},imm16}; 	// signed half word
			`unsignhalf		:	out32	=	{{16{1'b0}},imm16}; 		// unsigned half word
			`andimm			:	out32	=	{{16{1'b1}},imm16};			// for the operation "and", Imm16 should be expanded by 1
			`orimm			:	out32	=	{{16{1'b0}},imm16}; 		// for the operation "or","xor", Imm16 should be expanded by 0
			`loadhigh		:	out32	=	{imm16,{16{1'b0}}};			// for LHI
			`jump26			:	out32	=	{{6{imm26[25]}},imm26};		// for call, bxx
			default			:	out32	=	{{24{1'b0}},imm8};		 	// default is unsigned byte
		endcase
	end
endmodule

*/