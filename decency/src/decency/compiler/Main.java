package decency.compiler;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.*;

import decency.compiler.*;
import decency.assemInstr.*;

public class Main {
	private static final int K = 26;
	public static List<AssemInstr> l = new ArrayList<AssemInstr>();
	private static Dictionary<Symbol, Integer> dict = new Hashtable<Symbol, Integer>();
	private static List<Integer> dimen = new ArrayList<Integer>();
	private static List<Integer> iter = new ArrayList<Integer>();
	private static int reguse = 0;
	private static int offset = 0;
	private static void emit(AssemInstr x){
		l.add(x);
	}
	private static void visit(Program x){
		if(x._link != null)visit(x._link);
		visit(x._v);
	}
	private static void visit(Function_definition x){
		visit(x._st);
	}
	private static void visit(Compound_statement x){
		visit(x._x);
		visit(x._y);
	}
	private static void visit(Declarations x){
		for(int i = 0; i < x._l.size(); ++i)
			visit(x._l.get(i));
	}
	private static void visit(Declaration x){
		visit(x._init);
	}
	private static void visit(Init_declarators x){
		for(int i = 0; i < x._l.size(); ++i)
			visit(x._l.get(i));
	}
	private static void visit(Init_declarator x){
		visit(x._x);
	}
	private static void visit(Declarator x){
		if(x._cexp != null){
			dict.put(x._x._sym, offset);
			int cnt = 1;
			for(int i = 0; i < x._cexp._l.size(); ++i)
				cnt *= ((IntLiteral)x._cexp._l.get(i))._x;
			offset += cnt;
		}
		else{
			dict.put(x._x._sym, reguse);
			reguse+=1;
		}
	}
	private static void visit(Statements x){
		for(int i = 0; i < x._l.size(); ++i)
			visit(x._l.get(i));
	}
	private static void visit(Statement x){
		if(x instanceof Compound_statement){
			visit(((Compound_statement)x)._x);
			visit(((Compound_statement)x)._y);
		}
		if(x instanceof Expression_statement){
			visit(((Expression_statement)x)._x);
		}
		if(x instanceof Iteration_statement){
			if(x instanceof While_statement){
				/*todo*/
			}
			if(x instanceof For_statement){
				if(check((Compound_statement)((For_statement) x)._st)){
					visit(((For_statement) x)._exp1);
					LABEL l2 = LABEL.neww();
					LABEL l3 = LABEL.neww();
					Assignment_expression y =((For_statement)x)._exp2;
					if(y.x.op == 3){
						Integer left = dict.get(((Id)y.x.x)._sym);
						iter.add(left);
						Integer right = ((IntLiteral)y.x.y)._x;
						dimen.add(right);
						int bak = reguse;
						emit(new MV(new Reg(reguse), new Imm(right-1)));
						emit(new BGT(new Reg(left), new Reg(reguse), l2.label));
						++reguse;
						emit(l3);
						visit(((For_statement) x)._st);
						visit(((For_statement) x)._exp3);
						emit(new BGT(new Reg(left), new Reg(bak), l2.label));
						emit(new J(l3.label));
						emit(l2);
					}
					else{
						//to do
					}
				}
				else{
					Assignment_expression y =((For_statement)x)._exp2;
					Assignment_expression z = ((Expression_statement)((Compound_statement)((For_statement)x)._st)._y._l.get(0))._x;
					Symbol c = ((Array_expression)z._uexp).findName()._sym;
					Symbol a = ((Array_expression)z._link.x).findName()._sym;
					Symbol b = ((Array_expression)z._link.y).findName()._sym;
					int n = dimen.get(0);
					int m = dimen.get(1);
					int k = ((IntLiteral)y.x.y)._x;
					int ai = reguse++;
					int bj = reguse++;
					int ci = reguse++;
					int aa = reguse++;
					int bb = reguse++;
					int cc = reguse++;
					int aij = reguse++;
					emit(new MUL(new Reg(ai), new Reg(iter.get(0)), new Imm(m)));
					emit(new MUL(new Reg(bj), new Reg(iter.get(1)), new Imm(k)));
					emit(new MUL(new Reg(ci), new Reg(iter.get(0)), new Imm(k)));
					emit(new MV(new Reg(aa), new Imm(dict.get(a))));
					emit(new MV(new Reg(bb), new Imm(dict.get(b))));
					emit(new MV(new Reg(cc), new Imm(dict.get(c))));
					emit(new LWX(new Reg(aij), new Reg(aa), new Reg(ai), new Reg(iter.get(1))));
					emit(new ADD(new Reg(bb), new Reg(bb), new Reg(bj)));
					emit(new ADD(new Reg(cc), new Reg(cc), new Reg(ci)));
					for(int i = 0; i <= k/K; ++i){
						for(int j = i*K; j<(i+1)*K && j<k; ++j){
							int idx = j-i*K+reguse;
							emit(new LW(new Reg(idx), new Reg(bb), new Imm(j*4)));
						}
						for(int j = i*K; j<(i+1)*K && j<k; ++j){
							int idx = j-i*K+reguse;
							emit(new MUL(new Reg(idx), new Reg(idx), new Reg(aij)));
						}
						for(int j = i*K; j<(i+1)*K && j<k; ++j){
							int idx = j-i*K+reguse+K;
							emit(new LW(new Reg(idx), new Reg(cc), new Imm(j*4)));
						}
						for(int j = i*K; j<(i+1)*K && j<k; ++j){
							int idx = j-i*K+reguse;
							emit(new ADD(new Reg(idx), new Reg(idx), new Reg(idx+K)));
						}
						for(int j = i*K; j<(i+1)*K && j<k; ++j){
							int idx = j-i*K+reguse+K;
							emit(new SW(new Reg(idx), new Reg(cc), new Imm(j*4)));
						}
					}
				}
			}
		}
	}
	private static void visit(Assignment_expression x){
		if(x.x != null){
			//to do
		}
		else{
			switch(x._aop){
				case ASSIGN: makeMove(visit(x._uexp), x._link);break;
				case MULASS: makeMove(visit(x._uexp), new Expression(2, x._uexp, x._link.x));break;
				case ADDASS: makeMove(visit(x._uexp), new Expression(0, x._uexp, x._link.x));break;
				case SUBASS: makeMove(visit(x._uexp), new Expression(1, x._uexp, x._link.x));break;
			}
		}
	}
	private static void makeMove(Operand dest, Expression src){
		if(src.op == -1){
			emit(new MV((Reg)dest, visit(src.x)));
		}
		else{
			if(src.x instanceof IntLiteral && (src.op==0 || src.op==2)){
				Postfix_expression tmp = src.x;
				src.x = src.y;
				src.y = tmp;
			}
			switch(src.op){
				case 0: emit(new ADD((Reg)dest, (Reg)visit(src.x), visit(src.y)));break;
				case 2: emit(new MUL((Reg)dest, (Reg)visit(src.x), visit(src.y)));break;
				//to do
			}
		}
	}
	private static Operand visit(Postfix_expression x){
		if(x instanceof Primary_expression){
			if(x instanceof IntLiteral)
				return new Imm(((IntLiteral) x)._x);
			else
				return new Reg(dict.get(((Id)x)._sym));
		}
		else{
			//to do
			return null;
		}
	}
	private static boolean check(Compound_statement x){
		for(int i = 0; i < x._y._l.size(); ++i)
			if(x._y._l.get(i) instanceof For_statement)
				return true;
		return false;
	}
	private static void compile(String filename) throws IOException {
		InputStream inp = new FileInputStream(filename);
		Parser parser = new Parser(inp);
		java_cup.runtime.Symbol parseTree = null;
		try {
			parseTree = parser.parse();
		} catch (Throwable e) {
			e.printStackTrace();
			throw new Error(e.toString());
		} finally {
			inp.close();
		}
		Program tree = (Program) parseTree.value;
		visit(tree);
	}
	
	public static void main(String argv[]) throws IOException {
		compile(argv[0]);
		for(AssemInstr ll:l)
			System.out.println(ll);
	}
}
