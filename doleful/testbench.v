`timescale 1ns/10ps        
`include "full_addder.v"
module testbench ();       
wire sum_out, cout;
reg a_input, b_input, cin; 
full_adder fa1(    .a(a_input)
                           ,.b(b_input)
                           ,.ci(cin)
                           ,.s(sum_out)
                           ,.co(cout));
initial fork                  
        a_input=0;b_input=0;cin=0;
#10  a_input=1;
#15  b_input=1;
#25   $stop;                
join
endmodule
