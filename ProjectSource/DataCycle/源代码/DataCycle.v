`include "timescale.v"
`include "Newdefine.h"

module DataCycle
	(
		clk					,
		rst					,
		DataShow,IFpc,EXalu_out
	);
	
	input					clk;
	input					rst;
	output[31:0]			IFpc,DataShow,EXalu_out;
//	output [3:0]EXAluop;
//	output [5:0] MEMop,EXop,IDop,WBop;
//	output MP0;
//	output [1:0] MEMMemWrite;
//	output [4:0] mp1_out;

	//IF Stage
	
	wire[31:0] IFinstr32,IFpc,IFpc1,mp0_out;	//pc1 = pc+1, instr32 = INSTRuction (32bits)
	wire MP0;	//MP = MultiPlexer control signal
	
	Progmembus membus_inst1	//program memory
	(	
		.MemDataOut		(IFinstr32),
		.MemAddr		(IFpc)
	);

	pc pc_inst
	(
		.clk			(clk),
		.rst			(rst),
		.mux_pc			(mp0_out),
		.stall			(),
		.PC				(IFpc),
		.PC4			(IFpc1)
	);
	
	mux2 # (32) mux3_pc_inst
	(
		.in0			(IFpc1),
		.in1			(WBmp4_out),
		.select			(MP0),
		.out			(mp0_out)
	);
	
	pipeline #(96) p1	//register of 96 bits
	(
		.clk			(clk),
		.rst			(rst),
		
		.stall		(),
		.flush		(),
		
		.D			({IFinstr32,IFpc,IFpc1}),	//input
		.Q			({IDinstr32,IDpc,IDpc1})	//output
	);
	
	//ID Stage
	
	wire[31:0] IDinstr32,IDpc,IDpc1,IDse_out,Special_data,Dx,IDDy,IDmp2_out,IDmp3_out;
	wire[15:0] Imm16;
	wire[25:0] Imm26;
	wire[5:0] IDop,funct;
	wire[4:0] Rx,Ry,IDRz,IDmp1_out,shamt;	//shamt is useless
	wire[3:0] IDAluop;
	wire[2:0] IDMemRead,Seop;	//Seop = Sign Expander OPrator
	wire[1:0] IDMP4,IDMemWrite;
	wire jal_ctrl,MP1,MP2,MP3,IDRin,IDFin,Special_En;	//jal = jump and link, Rin = Regfile in, Fin = Flag in
	
	assign {IDop,Rx,Ry,IDRz,shamt,funct}=IDinstr32;
	assign Imm16=IDinstr32[15:0];
	assign Imm26=IDinstr32[25:0];
	
	decoder decoder_inst
	(
		//input
		.op						(IDop),
		.funct					(funct),
		
		//output
		.MP1					(MP1),
		.MP2					(MP2),
		.MP3					(MP3),
		.MP4					(IDMP4),
		
		.Aluop					(IDAluop),
		.Memwrite				(IDMemWrite),
		.Memread				(IDMemRead),
		.Rin					(IDRin),
		.Fin					(IDFin),
		.Special_En				(Special_En),		
		.Seop					(Seop),
		.jal_ctrl				(jal_ctrl)
	);

	mux2 # (5) mux2_inst1
	(
		.in0			(IDRz),
		.in1			(Ry),
		.select			(MP1),
		.out			(IDmp1_out)
	);

	regfile regfile_inst
	(
		// input
		.clk			(clk),
		.reset			(rst),
		.write			(WBRin),	
		.Special_En		(Special_En),
		.ra_En			(jal_ctrl),

		.RxIndex		(Rx),	
		.RyIndex		(Ry),   

		.RzIndex		(WBmp1_out),	
		.Data_i			(WBmp4_out),
		.Special_i		(Special_data),

		.jal_i			(IDpc1),
		// output
		.Datax_o		(Dx)	,
		.Datay_o        (IDDy)			
	);

	mux2 #(32) mux2_inst2
	(
		.in0			(IDpc),
		.in1			(Dx),
		.select			(MP2),
		.out			(IDmp2_out)
	);
	
	mux2 #(32) mux2_inst3
	(
		.in0			(IDDy),
		.in1			(IDse_out),
		.select			(MP3),
		.out			(IDmp3_out)
	);
	
	signexpander signexpander_inst
	(
		.imm8		(),
		.imm16		(Imm16),
		.imm26		(Imm26),
		.SEop		(Seop),
		.out32		(IDse_out)	
	);
	
	pipeline #(152) p2
	(
		.clk			(clk),
		.rst			(rst),
		
		.stall		(),
		.flush		(),
		
		.D			({IDMemRead,IDMP4,IDMemWrite,IDFin,IDse_out,IDDy,IDmp2_out,IDmp3_out,IDop,IDAluop,IDRin,IDmp1_out}),
		.Q			({EXMemRead,EXMP4,EXMemWrite,EXFin,EXse_out,EXDy,EXmp2_out,EXmp3_out,EXop,EXAluop,EXRin,EXmp1_out})
	);
	
	//EX Stage
	
	wire[31:0] EXse_out,EXDy,EXmp2_out,EXmp3_out,EXalu_out;
//	wire[15:0] 
//	wire[25:0] 
	wire[5:0] EXop;
	wire[4:0] EXmp1_out;
	wire[3:0] EXflag,EXAluop;
	wire[2:0] EXMemRead;
	wire[1:0] EXMP4,EXMemWrite;
	wire EXFin,EXRin;
	
	alu alu_inst
	(
		.aluop			(EXAluop),
		.opA			(EXmp2_out),
		.opB			(EXmp3_out),
		.flagin			(EXFin),
		
		.result			(EXalu_out),
		.flag			(EXflag),
		.special		(Special_data)
	);

	pipeline #(119) p3
	(
		.clk			(clk),
		.rst			(rst),
		
		.stall		(),
		.flush		(),
		
		.D			({EXflag,EXMemRead,EXMP4,EXMemWrite,EXse_out,EXDy,EXalu_out,EXop,EXRin,EXmp1_out}),
		.Q			({MEMflag,MEMMemRead,MEMMP4,MEMMemWrite,MEMse_out,MEMDy,MEMalu_out,MEMop,MEMRin,MEMmp1_out})
	);

	//MEM Stage
	
	wire[31:0] DataShow,MEMse_out,MEMDy,MEMalu_out,dmem_out,MEMmp4_out;
//	wire[15:0] 
//	wire[25:0] 
	wire[5:0] MEMop;
	wire[4:0] MEMmp1_out;
	wire[3:0] MEMflag;
	wire[2:0] MEMMemRead;
	wire[1:0] MEMMP4,MEMMemWrite;
	wire MEMRin;
	
	mux3 #(32) mux3_inst
	(
		.in0		(MEMse_out),
		.in1		(MEMalu_out),
		.in2		(dmem_out),
		.select		(MEMMP4),
		.out		(MEMmp4_out)
	);
	
	Datamembus membus_inst2	//Data Memory
	(
		.clk1			(clk),
		.MemDataIn		(MEMDy),
		.MemDataOut		(dmem_out),
		.MemAddr		(MEMalu_out),
		.Read			(MEMMemRead),
		.Write			(MEMMemWrite),
		.MemDataShow	(DataShow)	//the first 4 bytes of the memory
	);

	pipeline #(48) p4
	(
		.clk			(clk),
		.rst			(rst),
		
		.stall		(),
		.flush		(),
		
		.D			({MEMflag,MEMop,MEMmp4_out,MEMRin,MEMmp1_out}),
		.Q			({WBflag,WBop,WBmp4_out,WBRin,WBmp1_out})
	);
	
	// WB Stage
	
	wire[31:0] WBmp4_out;
//	wire[15:0] 
//	wire[25:0] 
	wire[5:0] WBop;
	wire[4:0] WBmp1_out; 
	wire[3:0] WBflag;
//	wire[2:0]
//	wire[1:0] 
	wire WBRin;

	branchlogic blyh
	(
		.flagin		(WBflag),
		.opin		(WBop),
		.MP0		(MP0)
	);

endmodule

	