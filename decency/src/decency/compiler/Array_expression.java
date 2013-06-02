package decency.compiler;

public class Array_expression extends Postfix_expression {
	public Postfix_expression _x = null;
	public Primary_expression _y = null;
	
	public Array_expression(Postfix_expression x, Primary_expression y){
		_x = x;
		_y = y;
	}
	
	public Id findName(){
		if(_x instanceof Array_expression)
			return ((Array_expression)_x).findName();
		else
			return (Id)_x;
	}
}
