
`define DataWidth		32		// Data Width
`define AddrWidth		32		// Address Width
`define IndxWidth		05		// Index Width
`define FlagWidth		04		// Flag Width

`define ZERO		32'd0
`define ONE			32'd1

`define LOW			1'd0
`define HIGH		1'd1

`define CLEAR		1'b0
`define SET			1'b1

`define RESET_ON	1'b1
`define RESET_OFF	1'b0
`define RESET_EDGE	posedge
`define CLOCK_EDGE	posedge
`define CLOCK_REVER	negedge

// definition for pc
`define pcnext		2'b00
`define	pcjump		2'b01
`define pcint		2'b10

// definition for Sign Expand Module OPERATION Code

`define signbyte	3'b000
`define unsignbyte	3'b001
`define signhalf	3'b010
`define unsignhalf	3'b011
`define andimm		3'b100
`define orimm		3'b101
`define loadhigh	3'b110
`define jump26		3'b111
`define readword	3'b111
`define noexec		3'b110
`define byte		2'b01
`define half		2'b10
`define writeword	2'b11
`define none		2'b00
//

// Memory
`define BYTE		2'd1	
`define HALF		2'd2	
`define WORD		2'd3

// ²Ù×÷Âë

`define RType		6'b000000	

`define b			6'b000001

`define lb			6'b000010
`define lbu			6'b000011
`define sb			6'b000100
`define lh			6'b000101
`define lhu			6'b000110
`define sh			6'b000111
`define lw			6'b001000
`define sw			6'b001001
`define lhi			6'b001010

`define cmp			6'b010000
`define bo			6'b011001
`define bno			6'b011010
`define bgtu		6'b011011
`define bletu		6'b011100
`define bgt			6'b011101
`define blet		6'b011110

`define addi		6'b100000
`define subi		6'b100001
`define muli		6'b100010
`define divi		6'b100011
`define addiu		6'b101000
`define subiu		6'b101001
`define muliu		6'b101010
`define diviu		6'b101011
`define andi		6'b100100
`define ori			6'b100101
//`define noti		6'b100110
`define xori		6'b100111
`define sli			6'b101100
`define srli		6'b101101
`define srai		6'b101110
`define srci		6'b101111

`define call		6'b001111
`define sysint		6'b111111
//`define nop			6'b110000

// RType funct Code

`define add_funct			6'b000000
`define sub_funct			6'b000001
`define mult_funct			6'b000010
`define div_funct			6'b000011
`define addu_funct			6'b001000
`define subu_funct			6'b001001
`define multu_funct			6'b001010
`define divu_funct			6'b001011
`define and_funct			6'b000100
`define or_funct			6'b000101
`define not_funct			6'b000110
`define xor_funct			6'b000111
`define sl_funct			6'b001100
`define srl_funct			6'b001101
`define sra_funct			6'b001110
`define src_funct			6'b001111

// ALU Operation

`define aluop_add			4'b0000
`define aluop_sub			4'b0001
`define aluop_mul			4'b0010
`define aluop_div			4'b0011
`define aluop_addu			4'b1000
`define aluop_subu			4'b1001
`define aluop_mulu			4'b1010
`define aluop_divu			4'b1011
`define aluop_and			4'b0100
`define aluop_or			4'b0101
`define aluop_not			4'b0110
`define aluop_xor			4'b0111
`define aluop_sl			4'b1100
`define aluop_srl			4'b1101
`define aluop_sra			4'b1110
`define aluop_src			4'b1111
	

// Conventional Names of Registers

`define reg0		5'd0	// Always returns 0
`define at			5'd1	// (assembly temporary) Reserved for use by assembly
`define v0			5'd2	// Value returned by subroutine
`define v1			5'd3
`define a0			5'd4	// (arguments) First few parameters for subroutine
`define a1			5'd5
`define a2			5'd6
`define a3			5'd7
`define t0			5'd8	// (temporaries) Subroutines can use without saving
`define t1			5'd9
`define t2			5'd10
`define t3			5'd11
`define t4			5'd12
`define t5			5'd13
`define t6			5'd14
`define t7			5'd15
`define t8			5'd24
`define t9			5'd25
`define s0			5'd16	// Subroutine register variables
`define s1			5'd17
`define s2			5'd18
`define s3			5'd19
`define s4			5'd20
`define s5			5'd21
`define s6			5'd22
`define s7			5'd23
`define k0			5'd26	// Reserved for use by interrupt/trap handler
`define k1			5'd27
`define gp			5'd28	// Global pointer
`define sp			5'd29	// Stack pointer
`define s8			5'd30	// Ninth register variable, ALSO USED TO SAVE SPECIAL RESULTS, I.E. THE HIGH 32 BITS OF A PRODUCT, AND THE REMAINDER OF A DIVISION
`define fp			5'd30	// Frame pointer
`define ra			5'd31	// Return adress for subroutine
                	