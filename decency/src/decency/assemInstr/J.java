package decency.assemInstr;

public class J extends AssemInstr {
	public String label;

	public J(String label){
		this.label = label;
	}
	
	@Override
	public String toString() {
		return "j " + label;
	}
}
