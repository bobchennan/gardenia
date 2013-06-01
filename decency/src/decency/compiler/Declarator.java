package decency.compiler;

import decency.compiler.Symbol;

public class Declarator {
	public Id _x = null;
	public Constant_expressions _cexp = null;
	
	public Declarator(Id x, Constant_expressions y){
		_x = x;
		_cexp = y;
	}
}