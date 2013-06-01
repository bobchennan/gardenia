package decency.compiler;

import decency.compiler.Symbol;

public class Expression_statement extends Statement {
	public Assignment_expression _x = null;
	
	public Expression_statement(Assignment_expression x){
		_x = x;
	}
}