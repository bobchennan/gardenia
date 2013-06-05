`include "timescale.v"
`include "Newdefine.h"

module	branchlogic
	(
		flagin		,
		opin		,
		MP0
	);
	
	input	[`FlagWidth-1:0]	flagin;
	input	[5:0]				opin;
	output						MP0;
	
	reg MP0;

	assign {NG, ZR, CY, OV} = flagin;	//the temp format of flag
	
	always@(opin, flagin)	//MP0
	begin
		if(
			(opin == `b)					||
			(opin == `call)					||
			(opin == `sysint)				||
			(opin == `bo && ZR)				||
			(opin == `bno && ~ZR)			||
			(opin == `bletu && NG|ZR)		||
			(opin == `bgtu && ~(NG|ZR))		||
			(opin == `blet && (NG^OV)|ZR)	||
			(opin == `bgt && ~((NG^OV)|ZR))
			)
			MP0 = 1'b1;
//		else if(opin == `sysint) MP0 = `pcint;
		else MP0 = 1'b0;
	end
	
endmodule
