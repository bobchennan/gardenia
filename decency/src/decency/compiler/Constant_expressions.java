package decency.compiler;

import decency.compiler.Symbol;
import java.util.*;

public class Constant_expressions {
	public List<Primary_expression> _l;
	
	public Constant_expressions(Primary_expression x){
		_l = new ArrayList<Primary_expression>();
		_l.add(x);
	}
	public Constant_expressions add(Primary_expression x){
		_l.add(x);
		return this;
	}
}