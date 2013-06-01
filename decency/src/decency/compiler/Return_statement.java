package decency.compiler;

import decency.compiler.Symbol;

public class Return_statement extends Statement{
	public Primary_expression _exp = null;
	public Return_statement(Primary_expression exp){
		_exp = exp;
	}
}