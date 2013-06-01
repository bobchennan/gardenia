package decency.compiler;

import decency.compiler.Symbol;

public class Assignment_expression {
	public Expression x = null;
	public Postfix_expression _uexp = null;
	public Assignment_operator _aop = null;
	public Expression _link = null;
	
	public Assignment_expression(Expression x){
		this.x = x;
	}
	
	public Assignment_expression(Postfix_expression uexp, Assignment_operator aop, Expression x){
		_uexp = uexp;
		_aop = aop;
		_link = x;
	}
}