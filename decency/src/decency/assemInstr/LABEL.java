package decency.assemInstr;

public class LABEL extends AssemInstr {
	public String label;

	@Override
	public String toString() {
		return label + ": ";
	}
}
