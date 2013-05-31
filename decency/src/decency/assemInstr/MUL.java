package decency.assemInstr;

public class MUL extends AssemInstr {
	public Reg dst, src1;
	public Operand src2;

	@Override
	public String toString() {
		return "mul " + dst + ", " + src1 + ", " + src2;
	}
}
