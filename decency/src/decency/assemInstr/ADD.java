package decency.assemInstr;

public class ADD extends AssemInstr {
	public Reg dst, src1;
	public Operand src2;

	@Override
	public String toString() {
		return "add " + dst + ", " + src1 + ", " + src2;
	}
}
