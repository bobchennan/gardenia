package decency.assemInstr;

public class LABEL extends AssemInstr {
	public Label label;

	@Override
	public String toString() {
		return label + ": ";
	}
}
