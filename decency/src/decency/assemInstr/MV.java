package decency.assemInstr;

public class MV extends AssemInstr {
	public Reg dst;
	public Operand src;

	@Override
	public String toString() {
		return "mv " + dst + ", " + src;
	}
}
