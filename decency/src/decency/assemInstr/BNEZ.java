package decency.assemInstr;

public class BNEZ extends AssemInstr {
	public Reg src;
	public Label label;

	@Override
	public String toString() {
		return "bnez " + src + ", " + label;
	}
}
