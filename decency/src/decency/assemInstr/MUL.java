package decency.assemInstr;

public class MUL extends AssemInstr {
	public Reg dst, src1;
	public Operand src2;
	
	public MUL(Reg dest, Reg x, Operand y){
		dst = dest;
		src1 = x;
		src2 = y;
	}

	@Override
	public String toString() {
		return "mul " + dst + ", " + src1 + ", " + src2;
	}
}
