`include "timescale.v"
`include "Newdefine.h"
//yh 12.15
//yk 12.16
module regfile
	(
		// input
		clk				,
		reset			,
		write			,	
		Special_En		,
		ra_En			,

		RxIndex			,	
		RyIndex			,   

		RzIndex			,	
		Data_i			,
		Special_i		,
		jal_i			,

		// output
		Datax_o			,
		Datay_o
	);
	integer				i				;
	input [4:0]			RxIndex		,
						RyIndex		,
						RzIndex		;
	input [`DataWidth-1:0]		Data_i			;
	input [`DataWidth-1:0]		Special_i		;
	input [`DataWidth-1:0]		jal_i		;
	
	input				write			;
	input				Special_En			;
	input				ra_En			;
	
	input				clk			;
	input				reset			;
	
	output [`DataWidth-1:0]	Datax_o			,
						Datay_o			;

	reg [`DataWidth-1:0] 		reg_file [0:`DataWidth-1];

	always@(negedge clk, `RESET_EDGE reset)
	begin
		if (reset == `RESET_ON)
		for (i = 1; i < `DataWidth; i = i + 1)
			begin
				reg_file[i] = `ZERO;
			end
		else begin
		if (Special_En)
			reg_file[`s8] = Special_i;
		if (ra_En)
			reg_file[`ra] = jal_i;
		if	(write)
			if (RzIndex != `ZERO)		//r[0] == 0;
				reg_file[RzIndex] = Data_i;
		end

	end
	
	assign Datax_o = reg_file[RxIndex];
	assign Datay_o = reg_file[RyIndex];
	
endmodule
