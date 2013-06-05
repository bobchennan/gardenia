/*
TODO:         tested in ModelSim ,ok! 
DATE:         1/20 3:55
AUTHOR:       Li Longyi
*/

module alu
	(
		// Input
		aluop		,
		opA			,
		opB			,
		flagin		,
		 
		// Output
		result		,
		flag		,
		special
      //,watch_p
	);
	
	// parameter
	parameter	ALUWIDTH = `DataWidth;
	parameter	FLAGWIDTH=`FlagWidth;		
	parameter	OVERFLAW = 0;
	
	input	[3:0]			aluop;
	
	input	[ALUWIDTH-1:0]	opA,
							opB;
							
	input flagin;
							
	output	[ALUWIDTH-1:0]	result,
							special;
							
	output	[FLAGWIDTH-1:0]	flag;
	reg [3:0] flag;
	//output [63:0] watch_p;
	//assign watch_p = {special,result};
	
	reg		[ALUWIDTH-1:0]	Reg_result,
							Reg_special;
							
	assign	special	=	Reg_special;
	assign	result	=	Reg_result;
	
	wire	[ALUWIDTH-1:0] Add_result,multi_result1,multi_result2;
	wire 	[ALUWIDTH-1:0] opB_n,opA_abs,opB_abs;
	reg   [ALUWIDTH-2:0] shift_A_reg;
	wire	[ALUWIDTH-2:0] shift_A;
	reg   [ALUWIDTH-1:0] shift_B_reg;
	wire	[ALUWIDTH-1:0] shift_B;
	assign shift_A = shift_A_reg;
	assign shift_B = shift_B_reg;
	assign opB_n = opB^{ALUWIDTH{aluop[0]}};
	wire [ALUWIDTH-1:0] shift_result;
	
	wire t_carry;
	wire AB_neg;
	wire A_neg;
	wire B_neg;
	
	assign AB_neg = (opA[31]^opB[31])&~aluop[3];
	assign A_neg = opA[31]&~aluop[3];
	assign B_neg = opB[31]&~aluop[3];
	wire[31:0] pH,pL;
	wire carry;
	CarryLookahead_Adder_32 CLA1 (opA,opB_n,aluop[0],Add_result,carry);
	
	CarryLookahead_Adder_32 CLA2 (opA^{ALUWIDTH{A_neg}},0,A_neg,opA_abs);
	CarryLookahead_Adder_32 CLA3 (opB^{ALUWIDTH{B_neg}},0,B_neg,opB_abs);
	carry_save_mult CSM0(opA_abs, opB_abs, {pH,pL});
	CarryLookahead_Adder_32 CLA4 (pL^{ALUWIDTH{AB_neg}},0,AB_neg,multi_result1,t_carry);
	CarryLookahead_Adder_32 CLA5 (pH^{ALUWIDTH{AB_neg}},0,t_carry,multi_result2);
	wire[31:0] divi_rest1,divi_result1,divi_result,divi_rest;
	//div_array DA0({{32'b0},opA_abs},opB_abs,divi_rest1,divi_result1);
	divide1 D0({{32'b0},opA_abs},opB_abs,divi_rest1,divi_result1);
	CarryLookahead_Adder_32 CLA6 (divi_rest1,opB_abs&{ALUWIDTH{A_neg^~divi_result1[0]}},0,divi_rest);
	CarryLookahead_Adder_32 CLA7 (divi_result1^{ALUWIDTH{AB_neg}},0,AB_neg,divi_result);
	shifter32 SH0(shift_A,shift_B,opB[4:0]^{5{~(aluop[0]|aluop[1])}},shift_result);
	
	always @(aluop, opA, opB,divi_result,divi_rest,
	         Add_result,multi_result1,multi_result2,shift_result,flagin)
	begin
	    
	    if(flagin)
			flag = {flag_Neg, flag_Zero, flag_Carry, flag_Overflow};
		else
			flag = flag;
		//rAu = opA;	// Unsigned Operand A
		//rBu = opB;	// Unsigned Operand B
		case (aluop)
			`aluop_add	:	Reg_result	<=  Add_result;
			`aluop_sub	: 	Reg_result	<=  Add_result;
			`aluop_mul	: 	begin
							Reg_result	<=  multi_result1;
							Reg_special <= 	multi_result2;
							end
			`aluop_div	: 
			            begin
							Reg_result	<=  divi_result;
							Reg_special <= 	divi_rest;
							//Reg_result	<=  1;
							//Reg_special <= 	1;
							end
			`aluop_addu	:	Reg_result	<=  Add_result;
			`aluop_subu	:	Reg_result	<=  Add_result;
			`aluop_mulu	:	begin
							Reg_result	<=  multi_result1;
							Reg_special <= 	multi_result2;
							end
			`aluop_divu	:	begin
							Reg_result	<=  divi_result;
							Reg_special <= 	divi_rest;
							end
			`aluop_and	: 	Reg_result	<=   opA & opB;					
			`aluop_or	: 	Reg_result	<=   opA | opB;					
			`aluop_not	:	Reg_result	<=	~opA;
			`aluop_xor	: 	Reg_result	<=   opA ^ opB;					
			`aluop_sl	:	begin
							shift_A_reg <= {opA[31:1]};
							shift_B_reg <= {opA[0],{31{1'b0}}};
							Reg_result	<=	shift_result;
							end
			`aluop_srl	:	begin
							shift_A_reg = 31'b0;
							shift_B_reg = opA;
							Reg_result	<=	shift_result;
							end
			`aluop_sra	:	begin
							shift_A_reg = {31{opA[31]}};
							shift_B_reg = opA;
							Reg_result	<=	shift_result;
							end
			`aluop_src	:	begin
							shift_A_reg = opA[30:0];
							shift_B_reg = opA;
							Reg_result	<=	shift_result;
							end
			default		: Reg_result	<= 	 opB;						
		endcase
	end
	assign flag_Carry = carry^aluop[0];
	assign flag_Neg = result[31];
	assign flag_Zero = (result == 0);
	assign flag_Overflow = ( result[31] & ~opA[31] & ~(aluop[0] ^ opB[31]))	
							|( ~result[31] & opA[31] & (aluop[0] ^ opB[31]));
//	assign flag = {flag_Neg, flag_Zero, flag_Carry, flag_Overflow};
	
endmodule
