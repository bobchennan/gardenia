`include "timescale.v"
`include "Newdefine.h"

module decoder
	(
		op					,
		funct				,
		MP1					,
		MP2					,
		MP3					,
		MP4					,
		Aluop				,
		Memwrite			,
		Memread				,
		Rin					,
		Fin					,
		Special_En			,
		Seop				,
		jal_ctrl
	);
	
	input	[5:0]			op;
	input	[5:0]			funct;
	
	output					MP1;
	output					MP2;
	output					MP3;
	output	[1:0]			MP4;
	output	[3:0]			Aluop;
	output	[1:0]			Memwrite;
	output	[2:0]			Memread;
	output					Rin;
	output					Fin;
	output					Special_En;
	output	[2:0]			Seop;
	output					jal_ctrl;
	
	reg						MP1;
	reg						MP2;
	reg						MP3;
	reg		[1:0]			MP4;
	reg		[1:0]			Memwrite;
	reg		[2:0]			Memread;
	reg						Rin;
	reg						Fin;
	reg 					Special_En;
	reg		[2:0]			Seop;
	reg						jal_ctrl;
	
	assign Aluop = 	(op == `RType) 				? 	funct[3:0] 	:	//Aluop
					(op >= `addi && op<=`srci)	?	op[3:0]		:
					(op >=`lb && op <= `sw)		?	`aluop_add	:
//					(op >=`b && op <= `sw)		?	`aluop_add	:
//					(op >=`bo && op <= `blet)	?	`aluop_add	:
//					(op == `call)				?	`aluop_add	:
//					(op == `cmp)				?	`aluop_sub	:
													`aluop_sub	;
	
	always@(op, funct)	//Special_En
	begin
			if(	
				(op == `muli) 	|| 	
				(op == `divi) 	||
				(op == `muliu)	||
				(op == `diviu)	||
				(
					(op == `RType)			&&
					(funct == `mult_funct) 	||
					(funct == `div_funct) 	||
					(funct == `multu_funct)	||
					(funct == `divu_funct)
				)
			)
				Special_En <= `HIGH;
			else Special_En <= `LOW;
	end	
	
	always@(op)	//Fin
	begin
		if(
			(op == `RType)				||
			(op >= `addi && op <=`srci)	||	//the prioty of ~ > relation operator > bit > logic
			(op == `cmp)
			)
			Fin <= `HIGH;
		else Fin <= `LOW;
	end
	
	always@(op)	//Rin
	begin
		if(
			(op == `RType)				||
			(op >= `addi && op<=`srci)	||
			(op == `lb) 				|| 	
			(op == `lbu) 				||
			(op == `lh)					||
			(op == `lhu)				||
			(op == `lw)					||
			(op == `lhi)				
//			(op == `call)				||
	//		(op == `sysint)
			)
			Rin <= `HIGH;
		else Rin <= `LOW;	
	end
	
	always@(op)	//Memread, Memwrite
	begin
		if		(op == `lb)	Memread <= `signbyte;
		else if	(op == `lbu)Memread <= `unsignbyte;
		else if	(op == `lh)	Memread <= `signhalf;
		else if	(op == `lhu)Memread <= `unsignhalf;
		else if	(op == `lw)	Memread <= `readword;
		else				Memread <= `noexec;
		
		if		(op == `sb)	Memwrite <= `byte;
		else if	(op == `sh)	Memwrite <= `half;
		else if	(op == `sw)	Memwrite <= `writeword;
		else				Memwrite <= `none;
	end
	
	always@(op)	//MP4
	begin
		if(
			(op == `lb)	||	
			(op == `lbu)||
			(op == `lh)	||
			(op == `lhu)||
			(op == `lw)
			)
				MP4 <= 2'd2;
		else if(op == `lhi || op == `sysint) MP4 <= 2'd0;
		else MP4 <= 2'd1;
	end
	
	
	always@(op)	//MP3
	begin
		if(op == `RType || op == `cmp) MP3 <= 0;
		else MP3 <= 1;
	end
				
	always@(op) //MP2
	begin
		if(
			(op == `b || op == `call)	||
			(op >= `bo && op <= `blet)
			)
			MP2 <= 1'd0;
		else MP2 <= 1'd1;
	end

	always@(op) //MP1
	begin
		if(op == `RType) MP1 <= `LOW;
		else MP1 <= `HIGH;
	end
		
	always@(op) //Seop, jal_ctrl
	begin
		if	   (op == `b || op == `call) 		Seop <= `jump26;
		else if(op >= `bo && op<=`blet) 		Seop <= `jump26;
		else if(op >= `lb && op <= `sw) 		Seop <= `signhalf;
		else if(op >= `addi && op <= `divi) 	Seop <= `signhalf;
		else if(op >= `addiu && op <= `diviu) 	Seop <= `unsignhalf;
		else if(op >= `sli && op <= `srci) 		Seop <= `unsignhalf;
		else if(op == `andi) 					Seop <= `andimm;
		else if(op == `ori || op == `xori) 		Seop <= `orimm;
		else if(op == `lhi) 					Seop <= `loadhigh;
		else;
		
		if		(op == `call || op == `sysint)	jal_ctrl <= `HIGH;
		else									jal_ctrl <= `LOW;
		
	end
	
endmodule 