`include "timescale.v"
`include "Newdefine.h"

module DataCycle
	(
		clk					,
		rst					,
		DataShow			,
		MP0_pc				,
		pc_membus,IFIDpipelineOut,
		EXMEMpipelineOut,MEMWBpipelineOut
	);
	
	input						clk;
	input						rst;
	output[`DataWidth-1:0]		DataShow;
	output[1:0]					MP0_pc;
	output[31:0]pc_membus,IFIDpipelineOut;
//	output[108:0]IDEXpipelineOut;
	output[41:0]EXMEMpipelineOut;
	output[33:0]MEMWBpipelineOut;
	
	// IF stage
	wire	[`DataWidth-1:0]	pc_membus;
	wire	[`DataWidth-1:0]	membus_IFIDpipeline;
	wire	[`AddrWidth-1:0]	pc4_pc4pipeline;
	wire	[31:0]				IFIDpipelineOut;
	wire	[31:0]				pc4pipelineOut;
	wire	[4:0]				MEMWBpipeline_Rz;
	wire	[`DataWidth-1:0]	mux3_pc;
	wire	[1:0]				MP0_pc;

	Progmembus membus_inst1
	(
		.MemDataOut		(membus_IFIDpipeline),
		.MemAddr		(pc_membus)
	);

	mux3 # (32) mux3_pc_inst
	(
		.in0			(pc4_pc4pipeline),
		.in1			(mux4_MEMWBpipeline),
		.in2			(SignExpand_IDEXpipeline),
		.select			(MP0_pc),
		.out			(mux3_pc)
	);
		
	pc pc_inst
	(
		.clk			(clk),
		.rst			(rst),
		.mux_pc			(mux3_pc),
		.stall			(),
		.PC				(pc_membus),
		.PC4			(pc4_pc4pipeline)
	);

	pipeline # ( 32) pc4IFIDpipeline 
	(
		.clk			(clk),
		.rst			(rst),
		
		.stall		(),
		.flush		(),//////////////////
		
		.D			(pc4_pc4pipeline),
		.Q			(pc4pipelineOut)
	);	
	
	pipeline #( 32) IFIDpipeline
	(
		.clk			(clk),
		.rst			(rst),
		
		.stall		(),//////////////
		.flush		(),/////////////
		
		.D			(membus_IFIDpipeline),
		.Q			(IFIDpipelineOut)
	);	
	
	// ID stage
	
	wire	[5:0]				IFIDpipeline_decoder;
	wire	[4:0]				IFIDpipeline_Rx;
	wire	[4:0]				IFIDpipeline_Ry;
	wire	[4:0]				IFIDpipeline_Rz;
	wire	[19:0]				IFIDpipeline_IDEXpipeline;
	wire	[15:0]				IFIDpipeline_SignExpand16;
	wire	[25:0]				IFIDpipeline_SignExpand26;
	wire	[5:0]				IFIDpipeline_funct;
	
	wire	[4:0]				mux2_Rz;

	wire	[`DataWidth-1:0]	Rx_IDEXpipeline;
	wire	[`DataWidth-1:0]	Ry_IDEXpipeline;
	wire						MP0_IDEXpipeline;
	wire						MP1_mux2;
	wire	[1:0]				MP2_IDEXpipeline;
	wire	[2:0]				MP3_IDEXpipeline;
	wire	[1:0]				MP4_IDEXpipeline;
	wire	[3:0]				Aluop_IDEXpipeline;
	wire						MemWrite_IDEXpipeline;
	wire						MemRead_IFIDpipeline;
	wire						Rin_IDEXpipeline;
	wire						Fin_IDEXpipeline;
	wire	[`DataWidth-1:0]	SignExpand_IDEXpipeline;
	wire	[25:0]				SignExpand26;
	wire	[`DataWidth-1:0]	SignExpand_pc;			
	wire	[110:0]				IDEXpipelineIn;		
	wire	[110:0]				IDEXpipelineOut;
	wire	[`DataWidth-1:0]	Special_regfile;
	wire	[1:0]				length;
	wire	[5:0]				op_IDEXpipeline;
	
	wire	[2:0]				decoder_se1;
	wire	[2:0]				decoder_se2;
	wire	[2:0]				se2_EXMEMpipeline;
	
	assign {
				IFIDpipeline_decoder, 
				IFIDpipeline_Rx, 
				IFIDpipeline_Ry, 
				IFIDpipeline_Rz
			} = IFIDpipelineOut[31:11]; 
	
	assign IFIDpipeline_funct = IFIDpipelineOut[5:0];
	
			/* forwarding
	
	assign IFIDpipeline_IDEXpipeline = {
											IFIDpipelineOut[25:21], 
											IFIDpipelineOut[20:16], 
											IFIDpipelineOut[20:16], 
											IFIDpipelineOut[15:11]
										};
			*/
			
	assign IFIDpipeline_SignExpand16 = IFIDpipelineOut[15:0];
	assign IFIDpipeline_SignExpand26 = IFIDpipelineOut[25:0];
	
	decoder decoder_inst
	(
		.op						(IFIDpipeline_decoder),
		.funct					(IFIDpipeline_funct),
//		.flag					(),
//		.MP0					(),
		.MP1					(MP1_mux2),
		.MP2					(MP2_IDEXpipeline),
		.MP3					(MP3_IDEXpipeline),
		.MP4					(MP4_IDEXpipeline),
		.Aluop					(Aluop_IDEXpipeline),
		.Memwrite				(MemWrite_IDEXpipeline),
		.Memread				(MemRead_IDEXpipeline),
		.Rin					(Rin_IDEXpipeline),
		.Fin					(Fin_IDEXpipeline),
		.Special_En				(Special_IDEXpipeline),		
		.Seop1					(decoder_se1),
		.Seop2					(decoder_se2),
		.jal_ctrl				(jal_regfile)
	);
	
	mux2 # (5) mux2_inst1
	(
		.in0			(IFIDpipeline_Rz),
		.in1			(IFIDpipeline_Ry),
		.select			(MP1_mux2),
		.out			(mux2_Rz)
	);

	regfile regfile_inst
	(
		// input
		.clk			(clk),
		.reset			(rst),
		.write			(MEMWBpipeline_Rin),	
		.Special_En		(Special_Control),
		.ra_En			(jal_regfile),

		.RxIndex		(IFIDpipeline_Rx),	
		.RyIndex		(IFIDpipeline_Ry),   

		.RzIndex		(MEMWBpipeline_Rz),	
		.Data_i			(MEMWBpipeline_Dz),
		.Special_i		(Special_regfile),

		.jal_i			(pc4pipelineEX),
		// output
		.Datax_o		(Rx_IDEXpipeline)	,
		.Datay_o        (Ry_IDEXpipeline)			
	);

	signexpander signexpander_inst
	(
		.imm8		(),
		.imm16		(IFIDpipeline_SignExpand16),
		.imm26		(IFIDpipeline_SignExpand26),
		.SEop		(decoder_se1),
		.out32		(SignExpand_IDEXpipeline)	
	);
	
	assign IDEXpipelineIn = {
//								MP0_IDEXpipeline,
								MP2_IDEXpipeline, 
								MP3_IDEXpipeline, 
								MP4_IDEXpipeline,
								Aluop_IDEXpipeline,
								MemWrite_IDEXpipeline,
								MemRead_IDEXpipeline,
								Rin_IDEXpipeline,
								Fin_IDEXpipeline,
								Rx_IDEXpipeline,
								Ry_IDEXpipeline,
								SignExpand_IDEXpipeline		//,
//								IFIDpipeline_IDEXpipeline
							};
							
	wire	[31:0]			pc4pipelineEX;
	
	
	
	pipeline # ( 32) pc4IDEXpipeline 
	(
		.clk			(clk),
		.rst			(rst),
		
		.stall		(),
		.flush		(),
		
		.D			(pc4pipelineOut),
		.Q			(pc4pipelineEX)
	);
		
	pipeline # ( 1) SpecialIDEXpipeline 
	(
		.clk			(clk),
		.rst			(rst),
		
		.stall		(),		//////////
		.flush		(),/////////////
		
		.D			(Special_IDEXpipeline),
		.Q			(Special_Control)
	);
		
	pipeline # ( 5) RzIDEXpipeline 
	(
		.clk			(clk),
		.rst			(rst),
		
		.stall		(),		//////////
		.flush		(),/////////////
		
		.D			(mux2_Rz),
		.Q			(Rz_EXMEMpipeline)
	);

	pipeline # ( 3) SEIDEXpipeline 
	(
		.clk			(clk),
		.rst			(rst),
		
		.stall		(),		//////////
		.flush		(),/////////////
		
		.D			(decoder_se2),
		.Q			(se2_EXMEMpipeline)
	);	
	
	pipeline #( 109) IDEXpipeline 
	(
		.clk			(clk),
		.rst			(rst),
		
		.stall		(),/////////////////////
		.flush		(),///////////////////
		
		.D			(IDEXpipelineIn),
		.Q			(IDEXpipelineOut)
	);
	
	pipeline # (6) opIDEXpipeline
	(
		.clk			(clk),
		.rst			(rst),
		
		.stall		(),/////////////////////
		.flush		(),///////////////////
		
		.D			(IFIDpipeline_decoder),
		.Q			(op_IDEXpipeline)
	);
	
	// EX stage
	
	wire	[`DataWidth-1:0]	Rx_ALU;
	wire	[`DataWidth-1:0]	Ry_ALU;
	wire						MP0_EXMEMpipeline;
	wire	[1:0]				MP2_mux3;
	wire	[2:0]				MP3_mux5;
	wire	[1:0]				MP4_EXMEMpipeline;
	wire	[3:0]				Aluop_ALU;
	wire						MemWrite_EXMEMpipeline;
	wire						MemRead_EXMEMpipeline;
	wire						Rin_EXMEMpipeline;
	wire	[`DataWidth-1:0]	SignExpand_mux;
	wire	[19:0]				EXMEMpipelineSpecial;
	wire	[41:0]				EXMEMpipelineIn;
	wire	[41:0]				EXMEMpipelineOut;
	
	wire	[`DataWidth-1:0]	mux3_ALU;
	wire	[`DataWidth-1:0]	mux5_ALU;
	wire	[`DataWidth-1:0]	ALU_EXMEMpipeline;
	wire	[`FlagWidth-1:0]	Flag_EXMEMpipeline;

	wire	[4:0]				Rz_MEMWBpipeline;
	
	wire	[5:0]				op_EXMEMpipeline;
	wire	[31:0]				EXMEMpipeline_mux4;		
	
	wire	[2:0]				se2_se2;	
	
	wire	[`DataWidth-1:0]	Rx_membus;
	
	assign {
//				MP0_EXMEMpipeline,
				MP2_mux3, 
				MP3_mux5, 
				MP4_EXMEMpipeline,
				Aluop_ALU,
				MemWrite_EXMEMpipeline,
				MemRead_EXMEMpipeline,
				Rin_EXMEMpipeline,
				Fin_ALU,
				Rx_ALU,
				Ry_ALU,
				SignExpand_mux,
//				EXMEMpipelineSpecial
			}								= IDEXpipelineOut;
	
	mux3 #(32) mux3_inst1
	(
		.in0			(pc4pipelineEX),	// input A(b, call)
		.in1			(Rx_ALU),	// input B(alu, alui, load, save, bxx)
		.in2			(),	///// input C
		.select			(MP2_mux3),	// select
		.out			(mux3_ALU)	// Output
	);
	
	mux2 #(32) mux2_inst3
	(
		.in0			(SignExpand_mux),
		.in1			(Ry_ALU),
		.select			(MP3_mux5),
		.out			(mux5_ALU)
	);
	
	alu alu_inst
	(
		.aluop			(Aluop_ALU),
		.opA			(mux3_ALU),
		.opB			(mux5_ALU),
		.flagin			(Fin_ALU),
		
		.result			(ALU_EXMEMpipeline),
		.flag			(Flag_EXMEMpipeline),
		.special		(Special_regfile)
	);
	assign EXMEMpipelineIn = {
//								MP0_EXMEMpipeline,
								MP4_EXMEMpipeline,
								MemWrite_EXMEMpipeline,
								MemRead_EXMEMpipeline,
								Rin_EXMEMpipeline,
								ALU_EXMEMpipeline,
								Flag_EXMEMpipeline
							};
	
	pipeline #( 41) EXMEMpipeline 
	(
		.clk			(clk),
		.rst			(rst),
		
		.stall			(),/////
		.flush			(),
		
		.D				(EXMEMpipelineIn),
		.Q				(EXMEMpipelineOut)
	);
	
	pipeline # (6) opEXMEMpipeline
	(
		.clk			(clk),
		.rst			(rst),
		
		.stall		(),/////////////////////
		.flush		(),///////////////////
		
		.D			(op_IDEXpipeline),
		.Q			(op_EXMEMpipeline)
	);

	pipeline # ( 5) RzEXMEMpipeline 
	(
		.clk			(clk),
		.rst			(rst),
		
		.stall		(),		//////////
		.flush		(),/////////////
		
		.D			(Rz_EXMEMpipeline),
		.Q			(Rz_MEMWBpipeline)
	);

	pipeline # ( 3) SEEXMEMpipeline 
	(
		.clk			(clk),
		.rst			(rst),
		
		.stall		(),		//////////
		.flush		(),/////////////
		
		.D			(se2_EXMEMpipeline),
		.Q			(se2_se2)
	);	
	
	pipeline # (32) lhEXMEMpipeline
	(
		.clk			(clk),
		.rst			(rst),
		
		.stall		(),/////////////////////
		.flush		(),///////////////////
		
		.D			(SignExpand_mux),
		.Q			(EXMEMpipeline_mux4)
	);
	
	pipeline # (32) RxEXMEMpipeline
	(
		.clk			(clk),
		.rst			(rst),
		
		.stall		(),/////////////////////
		.flush		(),///////////////////
		
		.D			(Rx_ALU),
		.Q			(Rx_membus)
	);
	
	
	
	//MEM stage
	
	wire	[`DataWidth-1:0]	membus_MEMWBpipeline;
	
	wire	[1:0]				MP4_mux4;
	wire						MemWrite_membus;
	wire						MemRead_mux2;
	wire						Rin_MEMWBpipeline;
	wire	[`DataWidth-1:0]	ALU_membus;
	wire	[`FlagWidth-1:0]	Flag_branchlogic;
	
	wire	[`DataWidth-1:0]	membus_mux4;
	wire	[`DataWidth-1:0]	mux4_MEMWBpipeline;
	
	wire	[33:0]				MEMWBpipelineIn;
	wire	[33:0]				MEMWBpipelineOut;
			
	wire	[`DataWidth-1:0]	membus_se;

	assign {
				MP4_mux4,
				MemWrite_membus,
				MemRead_mux2,
				Rin_MEMWBpipeline,
				ALU_membus,
				Flag_branchlogic
			} = EXMEMpipelineOut;
	
	branchlogic blyh
	(
		.flagin		(Flag_branchlogic),
		.opin		(op_EXMEMpipeline),
		.MP0		(MP0_pc)
	);
	
	mux4 #(32) mux4_inst
	(
		.in0		(EXMEMpipeline_mux4),	// input A(lhi)
		.in1		(ALU_membus),	// input B(alu, alui) (ALU_mux4?)
		.in2		(membus_mux4),	// input C(load)
		.in3		(),	// input D(call, sysint) useless and obsolete
		.select		(MP4_mux4),	// select
		.out		(mux4_MEMWBpipeline)	// Output
	);
	
	Datamembus membus_inst2
	(
		.MemDataIn		(Rx_membus),
		.MemDataOut		(membus_se),
		.MemAddr		(ALU_membus),
		.Write			(MemWrite_membus),
		.MemDataShow	(DataShow)
	);
	
	signexpander1 sefordatamembus
	(
		.imm8		(membus_se[31:24]),
		.imm16		(membus_se[31:16]),
		.imm32		(membus_se),
		.SEop		(se2_se2),
		.out32		(membus_mux4)
	);

	//WB Stage

	wire	[4:0]				Rz_EXMEMpipeline;	
	wire	[`DataWidth-1:0]	MEMWBpipeline_Dz;
	wire						MEMWBpipeline_Rin;
	
	pipeline # ( 5) RzMEMWBpipeline 
	(
		.clk			(clk),
		.rst			(rst),
		
		.stall		(),		//////////
		.flush		(),/////////////
		
		.D			(Rz_MEMWBpipeline),
		.Q			(MEMWBpipeline_Rz)
	);
	
	assign MEMWBpipelineIn = {
								Rin_MEMWBpipeline,
								mux4_MEMWBpipeline
							};
	
	pipeline #( 33 ) MEMWBpipeline 
	(
		.clk			(clk),
		.rst			(rst),
		
		.stall			(),
		.flush			(),
		
		.D				(MEMWBpipelineIn),
		.Q				(MEMWBpipelineOut)
	);	
	
	assign {
				MEMWBpipeline_Dz,
				MEMWBpipeline_Rin
			} = MEMWBpipelineOut;
endmodule
