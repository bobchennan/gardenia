module full_adder ( a, b, ci, s, co);

input a,b,ci;
output s;
output co;

wire a,b,ci,s,co;
wire p;

assign     p=a^b;
assign     s=p^ci;
assign     co=(p & ci) | (!p  &  a);

endmodule    
