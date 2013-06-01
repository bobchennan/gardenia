package decency.compiler;

import decency.compiler.Symbol;

public class Function_definition {
	public Id _x = null;
	public Compound_statement _st = null;
	
	public Function_definition(Id y, Compound_statement s){
		_x = y;
		_st = s;
	}
}