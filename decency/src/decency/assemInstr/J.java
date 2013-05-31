package decency.assemInstr;

public class J extends AssemInstr {
	public String label;

	@Override
	public String toString() {
		return "j " + label;
	}
}
