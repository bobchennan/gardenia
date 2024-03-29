package decency.assemInstr;

import decency.assembler.Util;

public class Reg extends Operand {
	public int reg;
	
	public Reg(int v){
		reg = v;
	}

	@Override
	public String toString() {
		return "$" + reg;
	}

	public String gen() {
		return Util.widen(reg, 6);
	}
}
