package decency.assemInstr;

public class Reg extends Operand {
	public int reg;

	@Override
	public String toString() {
		return "$" + reg;
	}
}
