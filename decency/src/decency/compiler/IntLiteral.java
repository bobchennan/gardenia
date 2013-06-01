package decency.compiler;

import decency.compiler.Symbol;

public class IntLiteral extends Primary_expression {
	public int _x = 0;
	
	public IntLiteral(int x){
		_x = x;
	}
}