package decency.compiler;

import decency.compiler.Symbol;

public class Compound_statement extends Statement {
	public Declarations _x = null;
	public Statements _y = null;
	
	public Compound_statement(Declarations x, Statements y){
		_x = x;
		_y = y;
	}
}