package decency.compiler;

import decency.compiler.Symbol;

public class Init_declarator {
	public Declarator _x = null;
	public Expression _y = null;
	
	public Init_declarator(Declarator x){
		_x = x;
	}
	
	public Init_declarator(Declarator x, Expression y){
		_x = x;
		_y = y;
	}
}