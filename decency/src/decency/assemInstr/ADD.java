package decency.assemInstr;

public class ADD extends AssemInstr {
	public Reg dst, src1;
	public Operand src2;
	
	public ADD(Reg dest, Reg x, Operand y){
		dst = dest;
		src1 = x;
		src2 = y;
	}

	@Override
	public String toString() {
		return "add " + dst + ", " + src1 + ", " + src2;
	}
}
