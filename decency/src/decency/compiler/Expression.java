package decency.compiler;

public class Expression {
	public int op = -1;
	public Postfix_expression x;
	public Postfix_expression y;
	
	public Expression(Postfix_expression x){
		this.x = x;
	}
	public Expression(int op, Postfix_expression x, Postfix_expression y){
		this.op = op;
		this.x = x;
		this.y = y;
	}
}
