package decency.assemInstr;

public class BGT extends AssemInstr {
	public Reg src1, src2;
	public String label;

	@Override
	public String toString() {
		return "bgt " + src1 + ", " + src2 + ", " + label;
	}
}
