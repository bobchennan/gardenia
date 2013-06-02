package decency.assemInstr;

public class Imm extends Operand {
	public int imm;

	public Imm(int x){
		imm = x;
	}
	@Override
	public String toString() {
		return "" + imm;
	}
}
