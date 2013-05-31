package decency.assemInstr;

import decency.util.Util;

public class BGT extends AssemInstr {
	public Reg src1, src2;
	public Label label;

	@Override
	public String toString() {
		return "bgt " + src1 + ", " + src2 + ", " + label;
	}

	@Override
	public String gen() {
		return "1010" + src1.reg + src2.reg + ;
	}
}
