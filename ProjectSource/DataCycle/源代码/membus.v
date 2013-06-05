`include "timescale.v"
`include "Newdefine.h"

module Progmembus
	(
		MemDataOut		,
		MemAddr		
	);
	
	parameter	ROMLENGTH=32;
	
	output[`DataWidth-1:0]		MemDataOut;
	
	input [`AddrWidth-1:0]		MemAddr;
									
	reg [`DataWidth-1:0] 		ROM[0:ROMLENGTH-1];
	
	initial
	begin
		$readmemb("out.txt",ROM);
	end
	
//	wire [`AddrWidth-1:0] MemAddrdiv4 = MemAddr>>2;
	
	assign MemDataOut = ROM[MemAddr];
	
endmodule

module Datamembus
		(
		clk1,
		MemDataIn		,
		MemDataOut		,
		MemAddr			,
		Read			,
		Write			,
		MemDataShow		
	);
	//Big Endian
	parameter	RAMLENGTH=10;
	
	input clk1;
	input [`DataWidth-1:0]		MemDataIn;
	
	output[`DataWidth-1:0]		MemDataOut;
	
	input [`AddrWidth-1:0]		MemAddr;
	
	input [2:0]					Read;
	
	input [1:0]					Write;
	
	output[`DataWidth-1:0]		MemDataShow;
									
	reg	[`DataWidth-1:0]		MemDataOut;
	
	reg [7:0] 		DataRAM[0:RAMLENGTH-1];
	
//	wire [`AddrWidth-1:0] MemAddrdiv4 = MemAddr>>2;
	
//	assign MemDataOut = DataRAM[MemAddrdiv4];
	wire[7:0] Data0,Data1,Data2,Data3;
	assign Data0 = DataRAM[MemAddr],Data1 = DataRAM[MemAddr+1],Data2 = DataRAM[MemAddr+2],Data3 = DataRAM[MemAddr+3];
	assign MemDataShow[31:0] = {DataRAM[0],DataRAM[1],DataRAM[2],DataRAM[3]};
	
	always@(negedge clk1)
	begin
		case (Read)
			`signbyte		:	MemDataOut	=	{{24{Data0[7]}},Data0};
			`unsignbyte		:	MemDataOut	=	{{24{1'b0}},Data0};
			`signhalf		:	MemDataOut	=	{{16{Data0[7]}},Data0,Data1};
			`unsignhalf		:	MemDataOut	=	{{16{1'b0}},Data0,Data1};
			`readword		:	MemDataOut	=	{Data0,Data1,Data2,Data3}; 
			`noexec			:	MemDataOut	=	0;
		endcase
	end
	
	always@(negedge clk1)
	begin
		if(Write != 2'b00)
		begin
			case (Write)
				`byte		:	DataRAM[MemAddr]	=	MemDataIn[7:0];
				`half		:	{DataRAM[MemAddr],DataRAM[MemAddr+1]}	=	MemDataIn[15:0];
				`writeword	:	{DataRAM[MemAddr],DataRAM[MemAddr+1],DataRAM[MemAddr+2],DataRAM[MemAddr+3]}	=	MemDataIn;
				`none		:	{DataRAM[MemAddr],DataRAM[MemAddr+1],DataRAM[MemAddr+2],DataRAM[MemAddr+3]} = {DataRAM[MemAddr],DataRAM[MemAddr+1],DataRAM[MemAddr+2],DataRAM[MemAddr+3]};
			endcase
		end
	end
	
endmodule
