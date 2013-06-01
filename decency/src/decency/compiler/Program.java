package decency.compiler;

import decency.compiler.Symbol;

public class Program {

	public Function_definition _v = null;
	public Program _link = null;

	public Program(Program x, Function_definition y) {
		_link = x;
		_v = y;
	}

	public Program(Function_definition y){
		_link = null;
		_v = y;
	}
}