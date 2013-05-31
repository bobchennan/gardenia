package decency.assemInstr;

public class BNEZ extends AssemInstr {
	public Reg src;
	public String label;

	@Override
	public String toString() {
		return "bnez " + src + ", " + label;
	}
}
