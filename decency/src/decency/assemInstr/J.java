package decency.assemInstr;

public class J extends AssemInstr {
	public Label label;

	@Override
	public String toString() {
		return "j " + label;
	}
}
