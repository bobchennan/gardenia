package decency.assemInstr;

public class SW extends AssemInstr {
	public Reg dst, src1;
	public Operand src2;

	@Override
	public String toString() {
		return "sw " + dst + ", " + src1 + ", " + src2;
	}
}
