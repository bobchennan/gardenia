package decency.compiler;

import decency.compiler.Symbol;
import java.util.*;

public class Statements {
	public List<Statement> _l;
	
	public Statements(){
		_l = new ArrayList<Statement>();
	}
	public Statements add(Statement x){
		_l.add(x);
		return this;
	}
}