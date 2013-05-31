package decency.assemInstr;
import decency.util.*;
public class ADD extends AssemInstr {
	public Reg dst, src1;
	public Operand src2;

	@Override
	public String toString() {
		return "add " + dst + ", " + src1 + ", " + src2;
	}

	@Override
	public String gen() {
		if (src2 instanceof Reg)
			return "1000" + dst.reg + src1.reg + ((Reg) src2).reg;
		else
			return "1000"+dst.reg+src1.reg+Util.trim(((Imm)src2).imm, 15)+"1";
	}
}
