package decency.compiler;

import decency.compiler.Symbol;

public class While_statement extends Iteration_statement {
	public Assignment_expression _exp = null;
	public Statement _st = null;
	public While_statement(Assignment_expression x, Statement y){
		_exp = x;
		_st = y;
	}
}