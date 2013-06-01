package decency.compiler;

import decency.compiler.Symbol;

public class For_statement extends Iteration_statement {
	public Assignment_expression _exp1 = null;
	public Assignment_expression _exp2 = null;
	public Assignment_expression _exp3 = null;
	public Statement _st = null;
	
	public For_statement(Assignment_expression exp1, Assignment_expression exp2, Assignment_expression exp3, Statement x){
		_exp1 = exp1;
		_exp2 = exp2;
		_exp3 = exp3;
		_st = x;
	}
}